import 'package:flutter/material.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/theme/app_colors.dart';
import 'package:purenote/core/theme/app_spacing.dart';
import 'package:purenote/core/theme/app_shapes.dart';
import 'package:purenote/core/utils/date_formatter.dart';
import 'package:purenote/core/utils/delta_utils.dart';
import 'package:purenote/l10n/app_localizations.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onPin;
  final VoidCallback? onDelete;
  final List<Label>? labels;
  final int attachmentCount;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
    this.onPin,
    this.onDelete,
    this.labels,
    this.attachmentCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final preview = stripQuillDelta(note.content);
    final hasContent = !note.isLocked && preview.isNotEmpty;
    final hasLabels = labels != null && labels!.isNotEmpty;

    return Hero(
      tag: 'note-color-${note.id}',
      child: Card(
        color: appColors.surfaceElevated,
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: InkWell(
          borderRadius: AppShapes.md,
          onTap: onTap,
          onLongPress: onLongPress,
          child: Row(
            children: [
              if (note.color != null)
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: Color(AppColors.noteColorValues[note.color! % 12]),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              note.title.isEmpty
                                  ? AppLocalizations.of(context)!.untitled
                                  : note.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (note.isPinned)
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.xs),
                            child: Icon(
                              Icons.push_pin,
                              size: 16,
                              color: appColors.accentPrimary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (hasContent)
                      Text(
                        preview,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: appColors.textSecondary,
                        ),
                      ),
                    if (note.isLocked)
                      Text(
                        AppLocalizations.of(context)!.lockedNote,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: appColors.textTertiary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    if (hasLabels) ...[
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          for (final label in labels!.take(3))
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: appColors.accentPrimaryLight
                                    .withValues(alpha: 0.2),
                                borderRadius: AppShapes.full,
                              ),
                              child: Text(
                                label.name,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: appColors.accentPrimary,
                                ),
                              ),
                            ),
                          if (labels!.length > 3)
                            Text(
                              '+${labels!.length - 3}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: appColors.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Text(
                          DateFormatter.formatRelative(note.updatedAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: appColors.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        if (attachmentCount > 0) ...[
                          Icon(
                            Icons.attach_file,
                            size: 14,
                            color: appColors.textTertiary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$attachmentCount',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: appColors.textTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class NoteCardSkeleton extends StatelessWidget {
  const NoteCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    return Card(
      color: appColors.surfaceElevated,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 160,
              height: 16,
              decoration: BoxDecoration(
                color: appColors.textTertiary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                color: appColors.textTertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 200,
              height: 12,
              decoration: BoxDecoration(
                color: appColors.textTertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
