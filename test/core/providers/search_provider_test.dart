import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/providers/database_provider.dart';
import 'package:purenote/features/search/providers/search_provider.dart';

void main() {
  group('RecentSearches', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    ProviderContainer createContainer() {
      return ProviderContainer(
        overrides: [
          databaseProvider.overrideWith((ref) => db),
        ],
      );
    }

    test('default state is empty list', () async {
      final container = createContainer();
      addTearDown(() => container.dispose());

      final state = await container.read(recentSearchesProvider.future);
      expect(state, isEmpty);
    });

    test('add persists a search query', () async {
      final container = createContainer();
      addTearDown(() => container.dispose());

      final notifier = container.read(recentSearchesProvider.notifier);
      await notifier.add('flutter');

      final state = await container.read(recentSearchesProvider.future);
      expect(state, ['flutter']);
    });

    test('add ignores empty queries', () async {
      final container = createContainer();
      addTearDown(() => container.dispose());

      final notifier = container.read(recentSearchesProvider.notifier);
      await notifier.add('');
      await notifier.add('  ');

      final state = await container.read(recentSearchesProvider.future);
      expect(state, isEmpty);
    });

    test('add trims whitespace from query', () async {
      final container = createContainer();
      addTearDown(() => container.dispose());

      final notifier = container.read(recentSearchesProvider.notifier);
      await notifier.add('  hello  ');

      final state = await container.read(recentSearchesProvider.future);
      expect(state, ['hello']);
    });

    test('add moves duplicate to front', () async {
      final container = createContainer();
      addTearDown(() => container.dispose());

      final notifier = container.read(recentSearchesProvider.notifier);
      await notifier.add('a');
      await notifier.add('b');
      await notifier.add('a');

      final state = await container.read(recentSearchesProvider.future);
      expect(state, ['a', 'b']);
    });

    test('add enforces max 10 items', () async {
      final container = createContainer();
      addTearDown(() => container.dispose());

      final notifier = container.read(recentSearchesProvider.notifier);
      for (var i = 0; i < 15; i++) {
        await notifier.add('query$i');
      }

      final state = await container.read(recentSearchesProvider.future);
      expect(state.length, 10);
    });

    test('remove deletes a specific query', () async {
      final container = createContainer();
      addTearDown(() => container.dispose());

      final notifier = container.read(recentSearchesProvider.notifier);
      await notifier.add('keep');
      await notifier.add('remove');
      await notifier.remove('remove');

      final state = await container.read(recentSearchesProvider.future);
      expect(state, ['keep']);
    });

    test('clearAll empties the list', () async {
      final container = createContainer();
      addTearDown(() => container.dispose());

      final notifier = container.read(recentSearchesProvider.notifier);
      await notifier.add('a');
      await notifier.add('b');
      await notifier.clearAll();

      final state = await container.read(recentSearchesProvider.future);
      expect(state, isEmpty);
    });

    test('persists across provider recreation', () async {
      final container = createContainer();
      addTearDown(() => container.dispose());

      final notifier = container.read(recentSearchesProvider.notifier);
      await notifier.add('persisted');

      container.invalidate(recentSearchesProvider);

      final state = await container.read(recentSearchesProvider.future);
      expect(state, ['persisted']);
    });
  });
}
