import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/export.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/services/encryption_service.dart';

String _sha256Hex(String data) {
  final digest = SHA256Digest();
  final hash = digest.process(Uint8List.fromList(utf8.encode(data)));
  return hash.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}

class BackupService {
  final AppDatabase _db;
  BackupService(this._db);

  Future<String> get _backupDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'backups'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }

  Future<String> get _attachmentsDir async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'attachments'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }

  Future<Map<String, String>> _exportData() async {
    final notes = await _db.select(_db.notes).get();
    final labels = await _db.select(_db.labels).get();
    final noteLabels = await _db.select(_db.noteLabels).get();
    final attachments = await _db.select(_db.attachments).get();
    final taskItems = await _db.select(_db.taskItems).get();
    final settings = await _db.select(_db.settings).get();

    final data = <String, String>{
      'notes.json': jsonEncode(notes.map((n) => {
        'id': n.id,
        'type': n.type,
        'title': n.title,
        'content': n.content,
        'color': n.color,
        'isPinned': n.isPinned,
        'isLocked': n.isLocked,
        'isArchived': n.isArchived,
        'reminderAt': n.reminderAt,
        'createdAt': n.createdAt,
        'updatedAt': n.updatedAt,
        'orderIndex': n.orderIndex,
      }).toList()),
      'labels.json': jsonEncode(labels.map((l) => {
        'id': l.id,
        'name': l.name,
        'color': l.color,
      }).toList()),
      'note_labels.json': jsonEncode(noteLabels.map((nl) => {
        'noteId': nl.noteId,
        'labelId': nl.labelId,
      }).toList()),
      'attachments.json': jsonEncode(attachments.map((a) => {
        'id': a.id,
        'noteId': a.noteId,
        'filePath': a.filePath,
        'mimeType': a.mimeType,
        'fileName': a.fileName,
        'fileSize': a.fileSize,
      }).toList()),
      'task_items.json': jsonEncode(taskItems.map((t) => {
        'id': t.id,
        'noteId': t.noteId,
        'content': t.content,
        'isChecked': t.isChecked,
        'parentId': t.parentId,
        'orderIndex': t.orderIndex,
      }).toList()),
      'settings.json': jsonEncode({for (final s in settings) s.key: s.value}),
    };

    final checksums = <String, String>{};
    for (final entry in data.entries) {
      checksums[entry.key] = _sha256Hex(entry.value);
    }

    data['manifest.json'] = jsonEncode({
      'version': 1,
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'appVersion': '1.0.0',
      'noteCount': notes.length,
      'attachmentCount': attachments.length,
      'checksums': checksums,
    });

    return data;
  }

  Future<String> createBackup({bool includeFiles = false, String? password}) async {
    final data = await _exportData();

    final archive = Archive();

    for (final entry in data.entries) {
      String content = entry.value;
      if (password != null && password.isNotEmpty) {
        content = EncryptionService.encrypt(content, password);
      }
      archive.addFile(ArchiveFile(entry.key, content.length, utf8.encode(content)));
    }

    if (includeFiles) {
      final attachmentsDir = await _attachmentsDir;
      final dir = Directory(attachmentsDir);
      if (await dir.exists()) {
        final files = await dir.list().toList();
        for (final file in files) {
          if (file is File) {
            final bytes = await file.readAsBytes();
            archive.addFile(ArchiveFile('files/${p.basename(file.path)}', bytes.length, bytes));
          }
        }
      }
    }

    final encoded = ZipEncoder().encode(archive);
    final backupDir = await _backupDir;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupPath = p.join(backupDir, 'backup_$timestamp.zip');
    await File(backupPath).writeAsBytes(encoded);

    await _logBackup(backupPath, encoded.length, 0, null);
    await _pruneOldBackups();

    Sentry.addBreadcrumb(Breadcrumb(
      message: 'Backup created',
      category: 'backup',
      level: SentryLevel.info,
      data: {'path': backupPath, 'size': encoded.length, 'passwordProtected': password != null},
    ));

    return backupPath;
  }

  Future<RestoreData> loadBackup(String zipPath, {String? password}) async {
    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    String readEntry(String name) {
      final entry = archive.findFile(name);
      if (entry == null) return '';
      String content = utf8.decode(entry.content);
      if (password != null && password.isNotEmpty) {
        try {
          content = EncryptionService.decrypt(content, password);
        } catch (_) {}
      }
      return content;
    }

    final manifestRaw = readEntry('manifest.json');
    if (manifestRaw.isEmpty) throw Exception('Invalid backup: missing manifest');

    final manifest = jsonDecode(manifestRaw) as Map<String, dynamic>;

    final checksums = manifest['checksums'] as Map<String, dynamic>?;
    if (checksums != null) {
      for (final entry in ['notes.json', 'labels.json', 'note_labels.json', 'attachments.json', 'task_items.json', 'settings.json']) {
        final content = readEntry(entry);
        final expectedHash = checksums[entry] as String?;
        if (expectedHash != null && _sha256Hex(content) != expectedHash) {
          throw Exception('Backup integrity check failed for $entry');
        }
      }
    }

    final notesRaw = readEntry('notes.json');

    return RestoreData(
      noteCount: (jsonDecode(notesRaw) as List).length,
      attachmentCount: manifest['attachmentCount'] as int? ?? 0,
      timestamp: DateTime.fromMillisecondsSinceEpoch(manifest['createdAt'] as int),
      passwordProtected: password == null && archive.findFile('notes.json')?.content.isNotEmpty == false,
    );
  }

  Future<void> restoreBackup(String zipPath, {String? password}) async {
    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    String readEntry(String name) {
      final entry = archive.findFile(name);
      if (entry == null) throw Exception('Missing entry: $name');
      String content = utf8.decode(entry.content);
      if (password != null && password.isNotEmpty) {
        content = EncryptionService.decrypt(content, password);
      }
      return content;
    }

    final manifestRaw = readEntry('manifest.json');
    final manifest = jsonDecode(manifestRaw) as Map<String, dynamic>;
    if ((manifest['version'] as int? ?? 0) > 1) {
      throw Exception('Backup format version ${manifest['version']} is newer than supported (1)');
    }

    final checksums = manifest['checksums'] as Map<String, dynamic>?;
    if (checksums != null) {
      for (final entry in ['notes.json', 'labels.json', 'note_labels.json', 'attachments.json', 'task_items.json', 'settings.json', 'manifest.json']) {
        if (entry == 'manifest.json') continue;
        final content = readEntry(entry);
        final expectedHash = checksums[entry] as String?;
        if (expectedHash != null && _sha256Hex(content) != expectedHash) {
          throw Exception('Backup integrity check failed for $entry');
        }
      }
    }

    final notes = jsonDecode(readEntry('notes.json')) as List;
    final labels = jsonDecode(readEntry('labels.json')) as List;
    final noteLabels = jsonDecode(readEntry('note_labels.json')) as List;
    final attachmentsRaw = jsonDecode(readEntry('attachments.json')) as List;
    final taskItems = jsonDecode(readEntry('task_items.json')) as List;
    final settingsRaw = jsonDecode(readEntry('settings.json')) as Map<String, dynamic>;

    await _db.batch((batch) {
      batch.deleteAll(_db.notes);
      batch.deleteAll(_db.labels);
      batch.deleteAll(_db.noteLabels);
      batch.deleteAll(_db.attachments);
      batch.deleteAll(_db.taskItems);
      batch.deleteAll(_db.settings);

      for (final n in notes) {
        batch.insert(_db.notes, NotesCompanion.insert(
          id: n['id'] as String,
          createdAt: n['createdAt'] as int,
          updatedAt: n['updatedAt'] as int,
        ).copyWith(
          type: Value(n['type'] as int? ?? 0),
          title: Value(n['title'] as String? ?? ''),
          content: Value(n['content'] as String? ?? ''),
          color: Value(n['color'] as int?),
          isPinned: Value(n['isPinned'] as bool? ?? false),
          isLocked: Value(n['isLocked'] as bool? ?? false),
          isArchived: Value(n['isArchived'] as bool? ?? false),
          reminderAt: Value(n['reminderAt'] as int?),
          orderIndex: Value((n['orderIndex'] as num?)?.toDouble() ?? 0.0),
        ));
      }

      for (final l in labels) {
        batch.insert(_db.labels, LabelsCompanion.insert(
          id: l['id'] as String,
          name: l['name'] as String,
        ).copyWith(color: Value(l['color'] as int?)));
      }

      for (final nl in noteLabels) {
        batch.insert(_db.noteLabels, NoteLabelsCompanion.insert(
          noteId: nl['noteId'] as String,
          labelId: nl['labelId'] as String,
        ));
      }

      for (final a in attachmentsRaw) {
        batch.insert(_db.attachments, AttachmentsCompanion.insert(
          id: a['id'] as String,
          noteId: a['noteId'] as String,
          filePath: a['filePath'] as String,
          mimeType: a['mimeType'] as String,
          fileName: a['fileName'] as String,
          fileSize: a['fileSize'] as int,
        ));
      }

      for (final t in taskItems) {
        batch.insert(_db.taskItems, TaskItemsCompanion.insert(
          id: t['id'] as String,
          noteId: t['noteId'] as String,
        ).copyWith(
          content: Value(t['content'] as String? ?? ''),
          isChecked: Value(t['isChecked'] as bool? ?? false),
          parentId: Value(t['parentId'] as String?),
          orderIndex: Value((t['orderIndex'] as num?)?.toDouble() ?? 0.0),
        ));
      }

      for (final entry in settingsRaw.entries) {
        batch.insert(_db.settings, SettingsCompanion.insert(
          key: entry.key,
          value: entry.value as String,
        ), mode: InsertMode.insertOrReplace);
      }
    });

    await _logBackup(zipPath, await File(zipPath).length(), 0, null);
  }

  Future<List<BackupLogData>> getHistory() async {
    return (_db.select(_db.backupLog)
      ..orderBy([(b) => OrderingTerm(expression: b.timestamp, mode: OrderingMode.desc)])
      ..limit(20))
      .get();
  }

  Future<void> _logBackup(String path, int size, int status, String? error) async {
    await _db.into(_db.backupLog).insert(BackupLogCompanion.insert(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      filePath: path,
      status: status,
    )..copyWith(fileSize: Value(size), errorMessage: Value(error)));
  }

  Future<void> _pruneOldBackups() async {
    final all = await (_db.select(_db.backupLog)
      ..orderBy([(b) => OrderingTerm(expression: b.timestamp, mode: OrderingMode.desc)]))
      .get();

    if (all.length <= 5) return;

    for (final log in all.skip(5)) {
      try {
        final file = File(log.filePath);
        if (await file.exists()) await file.delete();
      } catch (_) {}
      await (_db.delete(_db.backupLog)..where((b) => b.id.equals(log.id))).go();
    }
  }
}

class RestoreData {
  final int noteCount;
  final int attachmentCount;
  final DateTime timestamp;
  final bool passwordProtected;

  RestoreData({
    required this.noteCount,
    required this.attachmentCount,
    required this.timestamp,
    required this.passwordProtected,
  });
}
