import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'connection.dart';

part 'database.g.dart';

class Notes extends Table {
  TextColumn get id => text()();
  IntColumn get type => integer().withDefault(const Constant(0))();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  IntColumn get color => integer().nullable()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get reminderAt => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  RealColumn get orderIndex => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Labels extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get color => integer().nullable()();
  RealColumn get orderIndex => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

class NoteLabels extends Table {
  TextColumn get noteId => text().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get labelId => text().references(Labels, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {noteId, labelId};
}

class Attachments extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get filePath => text()();
  TextColumn get mimeType => text()();
  TextColumn get fileName => text()();
  IntColumn get fileSize => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class TaskItems extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get content => text().withDefault(const Constant(''))();
  BoolColumn get isChecked => boolean().withDefault(const Constant(false))();
  TextColumn get parentId => text().nullable()();
  RealColumn get orderIndex => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class BackupLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get timestamp => integer()();
  TextColumn get filePath => text()();
  IntColumn get fileSize => integer().nullable()();
  IntColumn get status => integer()();
  TextColumn get errorMessage => text().nullable()();
}

@DriftDatabase(
  tables: [
    Notes,
    Labels,
    NoteLabels,
    Attachments,
    TaskItems,
    Settings,
    BackupLog,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.noDb() : super(openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
        try {
          await customStatement('CREATE INDEX IF NOT EXISTS notes_updated_at_idx ON notes(updatedAt)');
          await customStatement('CREATE INDEX IF NOT EXISTS notes_is_pinned_idx ON notes(isPinned)');
          await customStatement('CREATE INDEX IF NOT EXISTS note_labels_note_id_idx ON note_labels(noteId)');
        } catch (_) {}
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(labels, labels.orderIndex);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA journal_mode=WAL');
        await customStatement('PRAGMA foreign_keys=ON');
        if (kDebugMode) {
          final result = await customSelect('PRAGMA foreign_key_check').get();
          assert(result.isEmpty, 'Foreign key violations: $result');
        }
        if (!details.wasCreated) {
          try {
            await customStatement('CREATE INDEX IF NOT EXISTS notes_updated_at_idx ON notes(updatedAt)');
            await customStatement('CREATE INDEX IF NOT EXISTS notes_is_pinned_idx ON notes(isPinned)');
            await customStatement('CREATE INDEX IF NOT EXISTS note_labels_note_id_idx ON note_labels(noteId)');
          } catch (_) {}
        }
      },
    );
  }
}
