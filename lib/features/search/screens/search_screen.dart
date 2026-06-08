import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/database/note_type.dart';
import 'package:purenote/core/theme/app_colors.dart';
import 'package:purenote/core/theme/app_spacing.dart';
import 'package:purenote/core/theme/app_shapes.dart';
import 'package:purenote/core/widgets/empty_state_widget.dart';
import 'package:purenote/features/search/providers/search_provider.dart';
import 'package:purenote/features/search/widgets/search_result_tile.dart';
import 'package:purenote/l10n/app_localizations.dart';

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
    if (note.isTaskList) {
      context.push('/task-list/${note.id}');
    } else {
      context.push('/note/${note.id}/view');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final results = ref.watch(searchResultsProvider(_query));
    final recentAsync = ref.watch(recentSearchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Container(
          height: 48,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            borderRadius: AppShapes.lg,
          ),
          child: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            style: TextStyle(color: colors.textPrimary),
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.searchNotesHint,
              hintStyle: TextStyle(color: colors.textTertiary),
              prefixIcon: Icon(Icons.search, color: colors.textSecondary),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: colors.textSecondary),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
            ),
            onChanged: _onSearchChanged,
            onSubmitted: _submit,
          ),
        ),
      ),
      body: _query.isEmpty
          ? _buildRecent(colors, recentAsync)
          : _buildResults(colors, results),
    );
  }

  Widget _buildRecent(AppColors colors, AsyncValue<List<String>> recentAsync) {
    return recentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, _) => const SizedBox.shrink(),
      data: (recent) {
        if (recent.isEmpty) {
          return EmptyStateWidget(
            lottieAsset: 'assets/lottie/empty_search.json',
            title: AppLocalizations.of(context)!.searchYourNotes,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.recentSearches,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => ref.read(recentSearchesProvider.notifier).clearAll(),
                    child: Text(AppLocalizations.of(context)!.clearAll),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: recent.map((q) {
                  return ActionChip(
                    label: Text(
                      q,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.accentPrimary,
                      ),
                    ),
                    backgroundColor: colors.accentPrimaryLight.withValues(alpha: 0.2),
                    side: BorderSide.none,
                    onPressed: () {
                      _controller.text = q;
                      _submit(q);
                    },
                    avatar: Icon(
                      Icons.history,
                      size: 16,
                      color: colors.accentPrimary,
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResults(AppColors colors, AsyncValue<List<Note>> results) {
    return results.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Center(
        child: Text(
          AppLocalizations.of(context)!.somethingWentWrong,
          style: TextStyle(color: colors.textSecondary),
        ),
      ),
      data: (notes) {
        if (notes.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.search_off,
            title: AppLocalizations.of(context)!.noResults(_query),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          itemCount: notes.length,
          separatorBuilder: (_, _) => const Divider(
            height: 1,
            indent: AppSpacing.lg,
            endIndent: 0,
          ),
          itemBuilder: (context, index) {
            final note = notes[index];
            return SearchResultTile(
              key: ValueKey(note.id),
              note: note,
              query: _query,
              onTap: () => _openNote(note),
            ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, duration: 300.ms);
          },
        );
      },
    );
  }
}
