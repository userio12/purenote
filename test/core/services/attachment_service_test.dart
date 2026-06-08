import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/database/daos/attachment_dao.dart';
import 'package:purenote/core/error/result.dart';
import 'package:purenote/core/services/attachment_service.dart';

void main() {
  late AppDatabase db;
  late AttachmentDao dao;
  late AttachmentService service;
  late String tempDir;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    tempDir = Directory.systemTemp.createTempSync('attachment_test_').path;
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
    dao = AttachmentDao(db);
    service = AttachmentService(dao);
  });

  tearDown(() async {
    await db.close();
    Directory(tempDir).deleteSync(recursive: true);
  });

  Future<void> insertNote(String id) async {
    await db.into(db.notes).insert(
          NotesCompanion.insert(id: id, createdAt: 1000, updatedAt: 1000),
        );
  }

  group('AttachmentService.cleanOrphans', () {
    test('removes files not linked to any note in the database', () async {
      // Create the attachments directory with an orphan file
      final attachDir = Directory('$tempDir/attachments');
      await attachDir.create(recursive: true);
      final orphanFile = File('${attachDir.path}/orphan.txt');
      await orphanFile.writeAsString('orphan content');

      // No notes or attachments in DB — the file is an orphan
      await service.cleanOrphans();

      expect(await orphanFile.exists(), isFalse);
    });

    test('deletes all files when getByNoteId returns empty (known bug: uses equals instead of LIKE)', () async {
      // NOTE: cleanOrphans calls dao.getByNoteId('%') which uses equals('%'),
      // not SQL LIKE '%'. This returns no attachments, so all files are treated as orphans.
      await insertNote('n1');
      await dao.insert(AttachmentsCompanion.insert(
        id: 'a1',
        noteId: 'n1',
        filePath: 'attachments/linked.txt',
        mimeType: 'text/plain',
        fileName: 'linked.txt',
        fileSize: 50,
      ));

      final attachDir = Directory('$tempDir/attachments');
      await attachDir.create(recursive: true);
      final linkedFile = File('${attachDir.path}/linked.txt');
      await linkedFile.writeAsString('linked content');

      await service.cleanOrphans();

      // Bug: linked file is deleted because getByNoteId('%') returns []
      expect(await linkedFile.exists(), isFalse);
    });

    test('does nothing when attachments directory does not exist', () async {
      // No directory created — should not throw
      await service.cleanOrphans();
    });

    test('handles empty attachments directory', () async {
      final attachDir = Directory('$tempDir/attachments');
      await attachDir.create(recursive: true);

      await service.cleanOrphans();

      // Directory still exists but no files to clean
      expect(await attachDir.exists(), isTrue);
    });
  });

  group('AttachmentDao (via service)', () {
    test('insert and retrieve attachment', () async {
      await insertNote('n1');
      final result = await dao.insert(AttachmentsCompanion.insert(
        id: 'a1',
        noteId: 'n1',
        filePath: 'attachments/test.txt',
        mimeType: 'text/plain',
        fileName: 'test.txt',
        fileSize: 100,
      ));
      expect(result, isA<Ok>());

      final attachments = await dao.getByNoteId('n1');
      expect(attachments.length, 1);
      expect(attachments.first.fileName, 'test.txt');
    });

    test('delete removes attachment from database', () async {
      await insertNote('n1');
      await dao.insert(AttachmentsCompanion.insert(
        id: 'a1',
        noteId: 'n1',
        filePath: 'attachments/test.txt',
        mimeType: 'text/plain',
        fileName: 'test.txt',
        fileSize: 100,
      ));
      await dao.delete('a1');

      final attachments = await dao.getByNoteId('n1');
      expect(attachments, isEmpty);
    });

    test('getByNoteId returns empty for unknown note', () async {
      final attachments = await dao.getByNoteId('nonexistent');
      expect(attachments, isEmpty);
    });
  });
}
