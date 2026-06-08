import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/database/daos/settings_dao.dart';

void main() {
  late AppDatabase db;
  late SettingsDao dao;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dao = SettingsDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('SettingsDao', () {
    test('set and get a setting', () async {
      await dao.set('theme', 'dark');
      final value = await dao.get('theme');
      expect(value, 'dark');
    });

    test('get returns null for missing key', () async {
      final value = await dao.get('nonexistent');
      expect(value, isNull);
    });

    test('getAll returns all settings', () async {
      await dao.set('theme', 'dark');
      await dao.set('language', 'en');
      await dao.set('fontSize', '14');

      final all = await dao.getAll();
      expect(all.length, 3);
      expect(all['theme'], 'dark');
      expect(all['language'], 'en');
      expect(all['fontSize'], '14');
    });

    test('set overwrites existing value', () async {
      await dao.set('theme', 'dark');
      await dao.set('theme', 'light');

      final value = await dao.get('theme');
      expect(value, 'light');

      final all = await dao.getAll();
      expect(all.length, 1);
    });

    test('remove deletes a setting', () async {
      await dao.set('theme', 'dark');
      await dao.remove('theme');

      final value = await dao.get('theme');
      expect(value, isNull);

      final all = await dao.getAll();
      expect(all, isEmpty);
    });

    test('remove is no-op for missing key', () async {
      await dao.remove('nonexistent');
      final all = await dao.getAll();
      expect(all, isEmpty);
    });
  });
}
