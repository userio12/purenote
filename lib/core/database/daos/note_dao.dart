import 'package:drift/drift.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/error/result.dart';
import 'package:purenote/core/error/app_error.dart';
import 'package:purenote/core/error/error_logger.dart';

class NoteDao {
  final AppDatabase _db;
  NoteDao(this._db);

  Stream<List<Note>> watchAll() {
    return _db.select(_db.notes).watch();
  }

  Stream<Note?> watchById(String id) {
    return (_db.select(_db.notes)..where((n) => n.id.equals(id))).watchSingleOrNull();
  }

  Stream<List<Note>> watchPinned() {
    return (_db.select(_db.notes)
          ..where((n) => n.isPinned.equals(true))
          ..orderBy([(n) => OrderingTerm(expression: n.updatedAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<Note>> watchByLabel(String labelId) {
    final query = _db.select(_db.notes).join(
      [
        innerJoin(
          _db.noteLabels,
          _db.noteLabels.noteId.equalsExp(_db.notes.id),
        ),
      ],
    )
      ..where(_db.noteLabels.labelId.equals(labelId))
      ..orderBy([OrderingTerm(expression: _db.notes.updatedAt, mode: OrderingMode.desc)]);
    return query.watch().map((rows) => rows.map((r) => r.readTable(_db.notes)).toList());
  }

  Future<Result<Note>> insert({required String id, required int createdAt, required int updatedAt}) async {
    try {
      final note = await _db.into(_db.notes).insertReturning(NotesCompanion.insert(
        id: id,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ));
      Sentry.addBreadcrumb(Breadcrumb(message: 'Note created', category: 'note', level: SentryLevel.info));
      return Ok(note);
    } catch (e, s) {
      ErrorLogger.logError('Failed to insert note', error: e, stackTrace: s);
      return Err(DatabaseError('Failed to create note'));
    }
  }

  Future<Result<void>> updateNote(Note note) async {
    try {
      await (_db.update(_db.notes)..where((n) => n.id.equals(note.id))).write(note.toCompanion(false));
      return const Ok(null);
    } catch (e, s) {
      ErrorLogger.logError('Failed to update note', error: e, stackTrace: s);
      return Err(DatabaseError('Failed to update note'));
    }
  }

  Future<Result<void>> updateFields(NotesCompanion companion) async {
    try {
      await (_db.update(_db.notes)..where((n) => n.id.equals(companion.id.value))).write(companion);
      return const Ok(null);
    } catch (e, s) {
      ErrorLogger.logError('Failed to update note fields', error: e, stackTrace: s);
      return Err(DatabaseError('Failed to update note'));
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      await (_db.delete(_db.notes)..where((n) => n.id.equals(id))).go();
      Sentry.addBreadcrumb(Breadcrumb(message: 'Note deleted', category: 'note', level: SentryLevel.info));
      return const Ok(null);
    } catch (e, s) {
      ErrorLogger.logError('Failed to delete note', error: e, stackTrace: s);
      return Err(DatabaseError('Failed to delete note'));
    }
  }

  Stream<List<Note>> watchByType(int type) {
    return (_db.select(_db.notes)
          ..where((n) => n.type.equals(type))
          ..orderBy([(n) => OrderingTerm(expression: n.updatedAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Stream<List<Note>> search(String query) {
    final pattern = '%$query%';
    return (_db.select(_db.notes)
          ..where((n) => n.title.like(pattern) | n.content.like(pattern))
          ..orderBy([(n) => OrderingTerm(expression: n.updatedAt, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<List<Note>> getAll() {
    return _db.select(_db.notes).get();
  }

  Future<Note?> getById(String id) async {
    return (_db.select(_db.notes)..where((n) => n.id.equals(id))).getSingleOrNull();
  }

  Future<Result<void>> togglePin(String id) async {
    try {
      final note = await getById(id);
      if (note == null) return Err(DatabaseError('Note not found'));
      await (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(
        NotesCompanion(isPinned: Value(!note.isPinned)),
      );
      return const Ok(null);
    } catch (e, s) {
      ErrorLogger.logError('Failed to toggle pin', error: e, stackTrace: s);
      return Err(DatabaseError('Failed to toggle pin'));
    }
  }
}
