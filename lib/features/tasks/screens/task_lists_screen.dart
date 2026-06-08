import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/utils/delta_utils.dart';
import 'package:purenote/core/widgets/empty_state_widget.dart';
import 'package:purenote/features/tasks/providers/task_items_provider.dart';
import 'package:purenote/features/tasks/providers/task_lists_provider.dart';
import 'package:purenote/l10n/app_localizations.dart';
import 'package:purenote/core/theme/app_colors.dart';

class TaskListsScreen extends ConsumerWidget {
  const TaskListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskListsAsync = ref.watch(taskListNotesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.tasks)),
      body: taskListsAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return const _EmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              return _TaskListCard(note: notes[index])
                  .animate(delay: (index * 50).ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.05, duration: 300.ms);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(onRetry: () => ref.invalidate(taskListNotesProvider)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          context.push('/task-list/new');
        },
        tooltip: AppLocalizations.of(context)!.newTaskList,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TaskListCard extends ConsumerWidget {
  final Note note;
  const _TaskListCard({required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskItemsByNoteProvider(note.id));
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;

    return tasksAsync.when(
      data: (items) {
        final total = items.length;
        final checked = items.where((t) => t.isChecked).length;
        final progress = total > 0 ? checked / total : 0.0;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push('/task-list/${note.id}'),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _ProgressCircle(progress: progress),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.title.isEmpty ? AppLocalizations.of(context)!.untitled : note.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '$checked / $total',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: colors.textTertiary),
                    ],
                  ),
                  if (total > 0) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                  if (_previewItems(items).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...(_previewItems(items).take(3).map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              item.isChecked
                                  ? Icons.check_box
                                  : Icons.check_box_outline_blank,
                              size: 16,
                              color: item.isChecked ? colors.accentSuccess : colors.textTertiary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _itemPreview(item.content, context),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  decoration:
                                      item.isChecked ? TextDecoration.lineThrough : null,
                                  color: item.isChecked
                                      ? colors.textTertiary
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: const SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  List<TaskItem> _previewItems(List<TaskItem> items) {
    final unchecked = items.where((t) => !t.isChecked).toList();
    final checked = items.where((t) => t.isChecked).toList();
    return [...unchecked, ...checked];
  }

  String _itemPreview(String content, BuildContext context) {
    final text = stripQuillDelta(content);
    return text.isNotEmpty ? text : AppLocalizations.of(context)!.emptyItem;
  }
}

class _ProgressCircle extends StatelessWidget {
  final double progress;
  const _ProgressCircle({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      lottieAsset: 'assets/lottie/empty_tasks.json',
      title: AppLocalizations.of(context)!.noTaskListsYet,
      subtitle: AppLocalizations.of(context)!.createFirstTaskList,
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: colors.textSecondary),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }
}
