import 'package:drift/drift.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/error/result.dart';
import 'package:purenote/core/error/app_error.dart';
import 'package:purenote/core/error/error_logger.dart';

class LabelDao {
  final AppDatabase _db;
  LabelDao(this._db);

  Stream<List<Label>> watchAll() {
    final query = _db.select(_db.labels)
      ..orderBy([(l) => OrderingTerm(expression: l.orderIndex, mode: OrderingMode.asc)]);
    return query.watch();
  }

  Future<Result<void>> reorderLabels(List<String> labelIds) async {
    try {
      for (var i = 0; i < labelIds.length; i++) {
        await (_db.update(_db.labels)..where((l) => l.id.equals(labelIds[i])))
          .write(LabelsCompanion(orderIndex: Value(i.toDouble())));
      }
      return const Ok(null);
    } catch (e, s) {
      ErrorLogger.logError('Failed to reorder labels', error: e, stackTrace: s);
      return Err(DatabaseError('Failed to reorder labels'));
    }
  }

  Future<Result<Label>> insert(LabelsCompanion companion) async {
    try {
      final label = await _db.into(_db.labels).insertReturning(companion);
      return Ok(label);
    } catch (e, s) {
      ErrorLogger.logError('Failed to insert label', error: e, stackTrace: s);
      return Err(DatabaseError('Failed to create label'));
    }
  }

  Future<Result<void>> update(LabelsCompanion companion) async {
    try {
      await (_db.update(_db.labels)..where((l) => l.id.equals(companion.id.value))).write(companion);
      return const Ok(null);
    } catch (e, s) {
      ErrorLogger.logError('Failed to update label', error: e, stackTrace: s);
      return Err(DatabaseError('Failed to update label'));
    }
  }

  Future<Result<void>> delete(String id) async {
    try {
      await (_db.delete(_db.labels)..where((l) => l.id.equals(id))).go();
      return const Ok(null);
    } catch (e, s) {
      ErrorLogger.logError('Failed to delete label', error: e, stackTrace: s);
      return Err(DatabaseError('Failed to delete label'));
    }
  }

  Future<List<Label>> getAll() => _db.select(_db.labels).get();

  Future<List<String>> getNoteIdsForLabel(String labelId) async {
    final query = _db.select(_db.noteLabels)
      ..where((n) => n.labelId.equals(labelId));
    final rows = await query.get();
    return rows.map((r) => r.noteId).toList();
  }

  Future<List<Label>> getLabelsForNote(String noteId) async {
    final query = _db.select(_db.labels).join(
      [
        innerJoin(
          _db.noteLabels,
          _db.noteLabels.labelId.equalsExp(_db.labels.id),
        ),
      ],
    )
      ..where(_db.noteLabels.noteId.equals(noteId));
    final rows = await query.get();
    return rows.map((r) => r.readTable(_db.labels)).toList();
  }

  Future<Result<void>> assignLabelToNote(String noteId, String labelId) async {
    try {
      await _db.into(_db.noteLabels).insert(
        NoteLabelsCompanion.insert(noteId: noteId, labelId: labelId),
      );
      return const Ok(null);
    } catch (e, s) {
      ErrorLogger.logError('Failed to assign label', error: e, stackTrace: s);
      return Err(DatabaseError('Failed to assign label'));
    }
  }

  Future<Result<void>> removeLabelFromNote(String noteId, String labelId) async {
    try {
      await (_db.delete(_db.noteLabels)..where((n) => n.noteId.equals(noteId))..where((n) => n.labelId.equals(labelId))).go();
      return const Ok(null);
    } catch (e, s) {
      ErrorLogger.logError('Failed to remove label', error: e, stackTrace: s);
      return Err(DatabaseError('Failed to remove label'));
    }
  }
}
