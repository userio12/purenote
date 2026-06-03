import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/services/backup_service.dart';

void main() {
  late AppDatabase db;
  late BackupService backupService;
  late String tempDir;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = Directory.systemTemp.createTempSync('backup_test_').path;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return tempDir;
        }
        return null;
      },
    );
    db = AppDatabase(NativeDatabase.memory());
    backupService = BackupService(db);
  });

  tearDown(() async {
    await db.close();
    Directory(tempDir).deleteSync(recursive: true);
  });

  Future<void> insertNote({
    required String id,
    required int createdAt,
    required int updatedAt,
    String title = '',
    String content = '',
  }) async {
    await db.into(db.notes).insert(NotesCompanion.insert(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt,
    ).copyWith(
      title: Value(title),
      content: Value(content),
    ));
  }

  group('BackupService', () {
    test('createBackup produces a valid ZIP file', () async {
      await insertNote(id: 'n1', createdAt: 1000, updatedAt: 1000);

      final path = await backupService.createBackup();

      final file = File(path);
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(0));

      final bytes = await file.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      expect(archive.findFile('manifest.json'), isNotNull);
      expect(archive.findFile('notes.json'), isNotNull);
      expect(archive.findFile('labels.json'), isNotNull);
      expect(archive.findFile('note_labels.json'), isNotNull);
      expect(archive.findFile('attachments.json'), isNotNull);
      expect(archive.findFile('task_items.json'), isNotNull);
      expect(archive.findFile('settings.json'), isNotNull);
    });

    test('createBackup with password encrypts entries', () async {
      await insertNote(id: 'n1', createdAt: 1000, updatedAt: 1000);

      final path = await backupService.createBackup(password: 'secret123');

      final bytes = await File(path).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      final notesEntry = archive.findFile('notes.json')!;
      final content = utf8.decode(notesEntry.content);
      expect(() => jsonDecode(content), throwsA(anything));
    });

    test('createBackup and restore roundtrip preserves data', () async {
      await insertNote(
        id: 'n1',
        createdAt: 1000,
        updatedAt: 1000,
        title: 'Hello',
        content: 'World',
      );
      await insertNote(
        id: 'n2',
        createdAt: 2000,
        updatedAt: 2000,
        title: 'Foo',
        content: 'Bar',
      );

      final path = await backupService.createBackup();

      await db.delete(db.notes).go();
      expect(await db.select(db.notes).get(), isEmpty);

      await backupService.restoreBackup(path);

      final notes = await db.select(db.notes).get();
      expect(notes.length, 2);
      expect(notes.map((n) => n.id).toSet(), equals({'n1', 'n2'}));
      expect(notes.where((n) => n.id == 'n1').first.title, 'Hello');
      expect(notes.where((n) => n.id == 'n2').first.title, 'Foo');
    });

    test('password-protected backup roundtrip', () async {
      const password = 'my-password';
      await insertNote(
        id: 'n1',
        createdAt: 1000,
        updatedAt: 1000,
        title: 'Secret',
        content: 'This is encrypted',
      );

      final path = await backupService.createBackup(password: password);

      await db.delete(db.notes).go();
      await backupService.restoreBackup(path, password: password);

      final notes = await db.select(db.notes).get();
      expect(notes.length, 1);
      expect(notes.first.id, 'n1');
      expect(notes.first.title, 'Secret');
      expect(notes.first.content, 'This is encrypted');
    });

    test('restoreBackup with wrong password fails', () async {
      await insertNote(id: 'n1', createdAt: 1000, updatedAt: 1000);

      final path = await backupService.createBackup(password: 'correct');

      expect(
        () => backupService.restoreBackup(path, password: 'wrong'),
        throwsA(isA<Exception>()),
      );
    });

    test('loadBackup returns correct RestoreData', () async {
      await insertNote(id: 'n1', createdAt: 1000, updatedAt: 1000);

      final path = await backupService.createBackup();
      final data = await backupService.loadBackup(path);

      expect(data.noteCount, 1);
      expect(data.passwordProtected, isFalse);
      expect(data.attachmentCount, 0);
    });

    test('getHistory returns backup log', () async {
      await insertNote(id: 'n1', createdAt: 1000, updatedAt: 1000);

      final path = await backupService.createBackup();
      final history = await backupService.getHistory();

      expect(history.length, 1);
      expect(history.first.filePath, path);
      expect(history.first.status, 0);
    });
  });
}
