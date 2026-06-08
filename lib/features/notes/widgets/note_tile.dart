import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/theme/app_colors.dart';
import 'package:purenote/core/theme/app_spacing.dart';
import 'package:purenote/core/theme/app_shapes.dart';
import 'package:purenote/core/utils/date_formatter.dart';
import 'package:purenote/core/utils/delta_utils.dart';
import 'package:purenote/l10n/app_localizations.dart';

class NoteTile extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onPin;
  final VoidCallback? onDelete;
  final List<Label>? labels;
  final int attachmentCount;
  final bool isSelected;

  const NoteTile({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
    this.onPin,
    this.onDelete,
    this.labels,
    this.attachmentCount = 0,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final preview = note.isLocked ? '' : stripQuillDelta(note.content);
    final hasContent = preview.isNotEmpty;

    final tile = Card(
      color: isSelected
          ? appColors.accentPrimary.withValues(alpha: 0.1)
          : appColors.surfaceElevated,
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
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
                  color: isSelected
                      ? appColors.accentPrimary
                      : Color(AppColors.noteColorValues[note.color! % 12]),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            if (note.color == null && isSelected)
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: appColors.accentPrimary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
              ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.md),
                child: Icon(Icons.check_circle, color: appColors.accentPrimary, size: 22),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (note.isPinned)
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.xs),
                            child: Icon(
                              Icons.push_pin,
                              size: 14,
                              color: appColors.accentPrimary,
                            ),
                          ),
                        if (note.isLocked)
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.xs),
                            child: Icon(
                              Icons.lock_outline,
                              size: 14,
                              color: appColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                    if (!note.isLocked && hasContent)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: appColors.textSecondary,
                          ),
                        ),
                      ),
                    if (note.isLocked)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          AppLocalizations.of(context)!.lockedNote,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: appColors.textTertiary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Text(
                          DateFormatter.formatRelative(note.updatedAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: appColors.textTertiary,
                          ),
                        ),
                        if (attachmentCount > 0) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Icon(
                            Icons.attach_file,
                            size: 12,
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
                        if (labels != null && labels!.isNotEmpty) ...[
                          const SizedBox(width: AppSpacing.sm),
                          ...labels!.take(2).map((l) => Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.xs),
                            child: Container(
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
                                l.name,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: appColors.accentPrimary,
                                ),
                              ),
                            ),
                          )),
                          if (labels!.length > 2)
                            Text(
                              '+${labels!.length - 2}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: appColors.textTertiary,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (onDelete != null)
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: appColors.textTertiary,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onDelete!();
                },
                tooltip: AppLocalizations.of(context)!.delete,
              ),
            if (onPin != null)
              IconButton(
                icon: Icon(
                  note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                  size: 18,
                  color: note.isPinned
                      ? appColors.accentPrimary
                      : appColors.textTertiary,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onPin!();
                },
                tooltip: note.isPinned
                    ? AppLocalizations.of(context)!.unpin
                    : AppLocalizations.of(context)!.pin,
              ),
          ],
        ),
      ),
    );

    if (onDelete == null) return tile;

    return Dismissible(
      key: ValueKey(note.id),
      direction: onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
      confirmDismiss: (_) async {
        onDelete?.call();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        decoration: BoxDecoration(
          color: appColors.accentDanger,
          borderRadius: AppShapes.md,
        ),
        child: Icon(Icons.delete_outline, color: appColors.surfaceElevated),
      ),
      child: tile,
    );
  }
}
