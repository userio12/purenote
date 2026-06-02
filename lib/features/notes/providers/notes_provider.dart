import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/providers/database_provider.dart';

part 'notes_provider.g.dart';

@Riverpod(keepAlive: true)
class NotesStream extends _$NotesStream {
  @override
  Stream<List<Note>> build() {
    final dao = ref.watch(noteDaoProvider);
    return dao.watchAll();
  }
}

@riverpod
Future<List<Label>> allLabels(AllLabelsRef ref) {
  final dao = ref.watch(labelDaoProvider);
  return dao.getAll();
}

@riverpod
Stream<List<Note>> notesByLabel(NotesByLabelRef ref, String labelId) {
  final dao = ref.watch(noteDaoProvider);
  return dao.watchByLabel(labelId);
}

@riverpod
Stream<Note?> noteById(NoteByIdRef ref, String id) {
  final dao = ref.watch(noteDaoProvider);
  return dao.watchById(id);
}

@riverpod
Future<List<Label>> labelsForNote(LabelsForNoteRef ref, String noteId) {
  final dao = ref.watch(labelDaoProvider);
  return dao.getLabelsForNote(noteId);
}

@riverpod
Future<List<Attachment>> attachmentsForNote(
    AttachmentsForNoteRef ref, String noteId) {
  final dao = ref.watch(attachmentDaoProvider);
  return dao.getByNoteId(noteId);
}

@riverpod
Document? noteDocument(NoteDocumentRef ref, String content) {
  try {
    final delta = jsonDecode(content);
    return Document.fromJson(delta as List<dynamic>);
  } catch (_) {
    return Document()..insert(0, content);
  }
}
