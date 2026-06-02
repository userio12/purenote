import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:purenote/core/database/daos/note_dao.dart';
import 'package:purenote/core/database/daos/label_dao.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/error/result.dart';
import 'package:purenote/core/services/attachment_service.dart';
import 'package:purenote/features/import/services/keep_parser.dart';
import 'package:purenote/features/import/services/evernote_parser.dart';
import 'package:purenote/features/import/services/quillpad_parser.dart';

enum ImportSource { keep, evernote, quillpad }

enum DuplicateHandling { import, skip }

class ImportResult {
  final int imported;
  final int skipped;
  final int failed;
  final List<String> errors;

  ImportResult({
    required this.imported,
    required this.skipped,
    required this.failed,
    required this.errors,
  });
}

class ImportProgress {
  final int current;
  final int total;
  final String message;

  ImportProgress({required this.current, required this.total, required this.message});
}

class ImportService {
  final NoteDao _noteDao;
  final LabelDao _labelDao;
  final AttachmentService? _attachmentService;

  ImportService(this._noteDao, this._labelDao, [this._attachmentService]);

  Stream<ImportProgress> importFile(
    String filePath,
    ImportSource source, {
    DuplicateHandling duplicateHandling = DuplicateHandling.import,
  }) async* {
    final file = File(filePath);
    if (!await file.exists()) {
      yield* Stream.error('File not found');
      return;
    }

    final content = await file.readAsString();
    var imported = 0;
    var skipped = 0;
    var failed = 0;
    final errors = <String>[];

    try {
      switch (source) {
        case ImportSource.keep:
          final notes = KeepParser.parse(content);
          for (var i = 0; i < notes.length; i++) {
            yield ImportProgress(current: i, total: notes.length, message: 'Importing Keep note ${i + 1}...');
            try {
              final success = await _importNote(
                title: notes[i].title,
                delta: KeepParser.keepToDelta(notes[i]),
                tags: notes[i].tags,
                createdAt: notes[i].createdAt,
                updatedAt: notes[i].updatedAt,
                duplicateHandling: duplicateHandling,
              );
              if (success) { imported++; } else { skipped++; }
            } catch (e) {
              failed++;
              errors.add('Error: $e');
            }
          }
          break;

        case ImportSource.evernote:
          final notes = EvernoteParser.parse(content);
          for (var i = 0; i < notes.length; i++) {
            yield ImportProgress(current: i, total: notes.length, message: 'Importing Evernote note ${i + 1}...');
            try {
              final note = notes[i];
              final noteId = const Uuid().v4();
              final success = await _importNote(
                id: noteId,
                title: note.title,
                delta: EvernoteParser.enmlToDelta(note.content),
                tags: note.tags,
                createdAt: note.createdAt,
                updatedAt: note.updatedAt,
                duplicateHandling: duplicateHandling,
              );
              if (success && note.resources.isNotEmpty && _attachmentService != null) {
                final attachDir = Directory(await _getAttachmentsDir());
                if (!await attachDir.exists()) await attachDir.create(recursive: true);
                for (final res in note.resources) {
                  if (res.dataBase64.isEmpty) continue;
                  try {
                    final bytes = base64Decode(res.dataBase64);
                    final ext = res.fileName.contains('.')
                        ? '.${res.fileName.split('.').last}'
                        : '';
                    final fileName = '${const Uuid().v4()}$ext';
                    final filePath = '${attachDir.path}/$fileName';
                    await File(filePath).writeAsBytes(bytes);
                    await _attachmentService.dao.insert(AttachmentsCompanion(
                      id: Value(const Uuid().v4()),
                      noteId: Value(noteId),
                      filePath: Value('attachments/$fileName'),
                      mimeType: Value(res.mimeType),
                      fileName: Value(res.fileName),
                      fileSize: Value(bytes.length),
                    ));
                  } catch (_) {}
                }
              }
              if (success) { imported++; } else { skipped++; }
            } catch (e) {
              failed++;
              errors.add('Error: $e');
            }
          }
          break;

        case ImportSource.quillpad:
          final notes = QuillpadParser.parse(content);
          for (var i = 0; i < notes.length; i++) {
            yield ImportProgress(current: i, total: notes.length, message: 'Importing note ${i + 1}...');
            try {
              final success = await _importNote(
                title: notes[i].title,
                delta: QuillpadParser.quillpadToDelta(notes[i]),
                tags: notes[i].tags,
                createdAt: notes[i].createdAt,
                updatedAt: notes[i].updatedAt,
                duplicateHandling: duplicateHandling,
              );
              if (success) { imported++; } else { skipped++; }
            } catch (e) {
              failed++;
              errors.add('Error: $e');
            }
          }
          break;
      }
    } catch (e) {
      yield* Stream.error('Import failed: $e');
      return;
    }

    yield ImportProgress(
      current: imported + skipped + failed,
      total: imported + skipped + failed,
      message: 'Done: $imported imported, $skipped skipped, $failed failed',
    );
  }

  Future<String> _getAttachmentsDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final attachDir = Directory('${dir.path}/attachments');
    if (!await attachDir.exists()) await attachDir.create(recursive: true);
    return attachDir.path;
  }

  Future<bool> _importNote({
    String? id,
    required String title,
    required List<Map<String, dynamic>> delta,
    required List<String> tags,
    required int createdAt,
    required int updatedAt,
    DuplicateHandling duplicateHandling = DuplicateHandling.import,
  }) async {
    if (duplicateHandling == DuplicateHandling.skip) {
      final all = await _noteDao.getAll();
      final json = jsonEncode(delta);
      final match = all.where((n) => n.title == title && n.content == json).firstOrNull;
      if (match != null) return false;
    }

    final noteId = id ?? const Uuid().v4();
    final json = jsonEncode(delta);
    final result = await _noteDao.insert(id: noteId, createdAt: createdAt, updatedAt: updatedAt);
    if (result case Ok(:final value)) {
      await _noteDao.updateFields(NotesCompanion(
        id: Value(value.id),
        title: Value(title),
        content: Value(json),
      ));
      await _importTags(tags, value.id);
      return true;
    }
    return false;
  }

  Future<void> _importTags(List<String> tagNames, String noteId) async {
    for (final name in tagNames) {
      if (name.trim().isEmpty) continue;
      final existingLabels = await _labelDao.getAll();
      var label = existingLabels.where((l) => l.name.toLowerCase() == name.trim().toLowerCase()).firstOrNull;

      if (label == null) {
        final id = const Uuid().v4();
        final result = await _labelDao.insert(LabelsCompanion.insert(id: id, name: name.trim()));
        if (result case Ok(:final value)) label = value;
      }

      if (label != null) {
        await _labelDao.assignLabelToNote(noteId, label.id);
      }
    }
  }
}
