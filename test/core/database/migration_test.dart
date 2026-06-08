import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:purenote/core/database/database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('AppDatabase schema', () {
    test('schema version is 3', () {
      expect(db.schemaVersion, 3);
    });

    test('all tables are created', () async {
      final tables = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type='table' ORDER BY name")
          .get();
      final names = tables.map((r) => r.read<String>('name')).toList();

      expect(names, contains('notes'));
      expect(names, contains('labels'));
      expect(names, contains('note_labels'));
      expect(names, contains('attachments'));
      expect(names, contains('task_items'));
      expect(names, contains('settings'));
      expect(names, contains('backup_log'));
    });

    test('notes table has expected columns', () async {
      final cols = await db
          .customSelect("PRAGMA table_info(notes)")
          .get();
      final names = cols.map((r) => r.read<String>('name')).toList();

      expect(names, contains('id'));
      expect(names, contains('type'));
      expect(names, contains('title'));
      expect(names, contains('content'));
      expect(names, contains('color'));
      expect(names, contains('is_pinned'));
      expect(names, contains('is_locked'));
      expect(names, contains('is_archived'));
      expect(names, contains('reminder_at'));
      expect(names, contains('created_at'));
      expect(names, contains('updated_at'));
      expect(names, contains('order_index'));
    });

    test('labels table has orderIndex column', () async {
      final cols = await db
          .customSelect("PRAGMA table_info(labels)")
          .get();
      final names = cols.map((r) => r.read<String>('name')).toList();

      expect(names, contains('id'));
      expect(names, contains('name'));
      expect(names, contains('color'));
      expect(names, contains('order_index'));
    });

    test('basic CRUD works on notes', () async {
      await db.into(db.notes).insert(
        NotesCompanion.insert(
          id: 'note1',
          createdAt: 1000,
          updatedAt: 1000,
        ),
      );

      final inserted = await (db.select(db.notes)..where((n) => n.id.equals('note1'))).getSingle();
      expect(inserted.id, 'note1');
      expect(inserted.title, '');
      expect(inserted.isPinned, false);

      await (db.update(db.notes)..where((n) => n.id.equals('note1'))).write(
        NotesCompanion(title: const Value('Updated')),
      );
      final updated = await (db.select(db.notes)..where((n) => n.id.equals('note1'))).getSingle();
      expect(updated.title, 'Updated');

      await (db.delete(db.notes)..where((n) => n.id.equals('note1'))).go();
      final remaining = await db.select(db.notes).get();
      expect(remaining, isEmpty);
    });

    test('basic CRUD works on settings', () async {
      await db.into(db.settings).insert(
        SettingsCompanion.insert(key: 'k', value: 'v'),
      );
      final row = await (db.select(db.settings)..where((s) => s.key.equals('k'))).getSingle();
      expect(row.value, 'v');

      await (db.delete(db.settings)..where((s) => s.key.equals('k'))).go();
      final remaining = await db.select(db.settings).get();
      expect(remaining, isEmpty);
    });

    test('foreign key cascade delete works', () async {
      await db.into(db.notes).insert(
        NotesCompanion.insert(id: 'n1', createdAt: 1, updatedAt: 1),
      );
      await db.into(db.labels).insert(
        LabelsCompanion.insert(id: 'l1', name: 'label'),
      );
      await db.into(db.noteLabels).insert(
        NoteLabelsCompanion.insert(noteId: 'n1', labelId: 'l1'),
      );

      final linkBefore = await db.select(db.noteLabels).get();
      expect(linkBefore.length, 1);

      await (db.delete(db.notes)..where((n) => n.id.equals('n1'))).go();

      final linkAfter = await db.select(db.noteLabels).get();
      expect(linkAfter, isEmpty);
    });
  });
}
