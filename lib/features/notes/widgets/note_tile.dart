import 'package:flutter/material.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/utils/delta_utils.dart';

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

  Color? _backgroundColor() {
    if (note.color == null) return null;
    return Color(note.color!);
  }

  @override
  Widget build(BuildContext context) {
    final color = _backgroundColor();
    final theme = Theme.of(context);
    final preview = note.isLocked ? '' : stripQuillDelta(note.content);

    return Card(
      color: isSelected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
          : color?.withValues(alpha: 0.15) ?? theme.colorScheme.surfaceContainerHigh,
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (isSelected)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 22),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            note.title.isEmpty ? 'Untitled' : note.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (note.isPinned)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.push_pin, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                        if (note.isLocked)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.lock_outline, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                      ],
                    ),
                    if (!note.isLocked && preview.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          preview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    if (note.isLocked)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Locked note',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          _formatDate(note.updatedAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                        if (attachmentCount > 0) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.attach_file, size: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                          const SizedBox(width: 1),
                          Text(
                            '$attachmentCount',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                        if (labels != null && labels!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          ...labels!.take(2).map((l) => Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: l.color != null ? Color(l.color!).withValues(alpha: 0.15) : theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Text(
                                l.name,
                                style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                              ),
                            ),
                          )),
                          if (labels!.length > 2)
                            Text(
                              '+${labels!.length - 2}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                  onPressed: onDelete,
                  tooltip: 'Delete',
                ),
              if (onPin != null)
                IconButton(
                  icon: Icon(
                    note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                    size: 18,
                    color: note.isPinned
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  onPressed: onPin,
                  tooltip: note.isPinned ? 'Unpin' : 'Pin',
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(int epochMs) {
    final dt = DateTime.fromMillisecondsSinceEpoch(epochMs);
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) return 'Just now';
      return '${diff.inHours}h ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (dt.year == now.year) return '${months[dt.month]} ${dt.day}';
    return '${months[dt.month]} ${dt.day}, ${dt.year}';
  }
}
