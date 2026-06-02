import 'dart:io';
import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/database/daos/attachment_dao.dart';
import 'package:purenote/core/error/result.dart';
import 'package:purenote/core/error/app_error.dart';

class AttachmentService {
  final AttachmentDao dao;
  AttachmentService(this.dao);

  Future<String> _getAttachmentsDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final attachDir = Directory(p.join(dir.path, 'attachments'));
    if (!await attachDir.exists()) {
      await attachDir.create(recursive: true);
    }
    return attachDir.path;
  }

  Future<Result<Attachment>> attachFile({
    required String noteId,
    required File sourceFile,
    String? mimeType,
  }) async {
    try {
      final fileSize = await sourceFile.length();
      if (fileSize > 50 * 1024 * 1024) {
        return Err(FileSystemError('File exceeds 50MB limit'));
      }

      final attachDir = await _getAttachmentsDir();
      final ext = p.extension(sourceFile.path);
      final newName = '${const Uuid().v4()}$ext';
      final destPath = p.join(attachDir, newName);
      await sourceFile.copy(destPath);

      final attachment = await dao.insert(AttachmentsCompanion(
        id: Value(const Uuid().v4()),
        noteId: Value(noteId),
        filePath: Value('attachments/$newName'),
        mimeType: Value(mimeType ?? 'application/octet-stream'),
        fileName: Value(p.basename(sourceFile.path)),
        fileSize: Value(fileSize),
      ));

      return attachment;
    } catch (e) {
      return Err(FileSystemError('Failed to attach file'));
    }
  }

  Future<Result<void>> deleteAttachment(Attachment attachment) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, attachment.filePath));
      if (await file.exists()) {
        await file.delete();
      }
      return await dao.delete(attachment.id);
    } catch (e) {
      return Err(FileSystemError('Failed to delete attachment'));
    }
  }

  Future<File> getFile(Attachment attachment) async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, attachment.filePath));
  }

  Future<void> cleanOrphans() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final attachDir = Directory(p.join(dir.path, 'attachments'));
      if (!await attachDir.exists()) return;

      final files = await attachDir.list().toList();
      final all = await dao.getByNoteId('%');

      for (final file in files) {
        if (file is! File) continue;
        final relativePath = 'attachments/${p.basename(file.path)}';
        final exists = all.any((a) => a.filePath == relativePath);
        if (!exists) {
          await file.delete();
        }
      }
    } catch (_) {}
  }
}
