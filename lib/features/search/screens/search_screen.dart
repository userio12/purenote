import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/features/search/providers/search_provider.dart';
import 'package:purenote/features/search/widgets/search_result_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => _query = value.trim());
    });
  }

  void _submit(String value) {
    _debounce?.cancel();
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) {
      ref.read(recentSearchesProvider.notifier).add(trimmed);
    }
    setState(() => _query = trimmed);
  }

  void _clearSearch() {
    _controller.clear();
    _debounce?.cancel();
    setState(() => _query = '');
  }

  void _openNote(Note note) {
    if (note.type == 1) {
      context.push('/task-list/${note.id}');
    } else {
      context.push('/note/${note.id}/view');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = ref.watch(searchResultsProvider(_query));
    final recentAsync = ref.watch(recentSearchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Search notes...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
          onSubmitted: _submit,
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSearch,
              tooltip: 'Clear',
            ),
        ],
      ),
      body: _query.isEmpty ? _buildRecent(theme, recentAsync) : _buildResults(theme, results),
    );
  }

  Widget _buildRecent(ThemeData theme, AsyncValue<List<String>> recentAsync) {
    return recentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, _) => const SizedBox.shrink(),
      data: (recent) {
        if (recent.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text(
                  'Search your notes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent searches', style: theme.textTheme.labelLarge),
                  TextButton(
                    onPressed: () => ref.read(recentSearchesProvider.notifier).clearAll(),
                    child: const Text('Clear all'),
                  ),
                ],
              ),
            ),
            ...recent.map(
              (q) => ListTile(
                leading: const Icon(Icons.history, size: 20),
                title: Text(q, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => ref.read(recentSearchesProvider.notifier).remove(q),
                  tooltip: 'Remove',
                ),
                onTap: () {
                  _controller.text = q;
                  _submit(q);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResults(ThemeData theme, AsyncValue<List<Note>> results) {
    return results.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(
        child: Text('Something went wrong', style: theme.textTheme.bodyMedium),
      ),
      data: (notes) {
        if (notes.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search_off, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text(
                  'No results for "$_query"',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: notes.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
          itemBuilder: (context, index) {
            final note = notes[index];
            return SearchResultTile(
              key: ValueKey(note.id),
              note: note,
              query: _query,
              onTap: () => _openNote(note),
            );
          },
        );
      },
    );
  }
}
