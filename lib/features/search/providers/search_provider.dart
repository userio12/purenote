import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/providers/database_provider.dart';

part 'search_provider.g.dart';

@riverpod
Stream<List<Note>> searchResults(SearchResultsRef ref, String query) {
  if (query.trim().isEmpty) return Stream.value([]);
  final dao = ref.watch(noteDaoProvider);
  return dao.searchFts5(query.trim());
}

@Riverpod(keepAlive: true)
class RecentSearches extends _$RecentSearches {
  static const _key = 'recent_searches';
  static const _maxItems = 10;

  @override
  Future<List<String>> build() async {
    final dao = ref.watch(settingsDaoProvider);
    final raw = await dao.get(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      return (jsonDecode(raw) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  Future<void> add(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final dao = ref.watch(settingsDaoProvider);
    final current = [...(await future)];
    current.remove(trimmed);
    current.insert(0, trimmed);
    final updated = current.take(_maxItems).toList();

    await dao.set(_key, jsonEncode(updated));
    ref.invalidateSelf();
  }

  Future<void> remove(String query) async {
    final dao = ref.watch(settingsDaoProvider);
    final current = [...(await future)];
    current.remove(query.trim());
    await dao.set(_key, jsonEncode(current));
    ref.invalidateSelf();
  }

  Future<void> clearAll() async {
    final dao = ref.watch(settingsDaoProvider);
    await dao.remove(_key);
    ref.invalidateSelf();
  }
}
