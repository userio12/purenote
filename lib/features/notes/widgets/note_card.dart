import 'package:flutter/material.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/utils/delta_utils.dart';


class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onPin;
  final VoidCallback? onDelete;
  final List<Label>? labels;
  final int attachmentCount;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onPin,
    this.onDelete,
    this.labels,
    this.attachmentCount = 0,
  });

  Color? _backgroundColor() {
    if (note.color == null) return null;
    return Color(note.color!);
  }

  @override
  Widget build(BuildContext context) {
    final color = _backgroundColor();
    final theme = Theme.of(context);
    final preview = stripQuillDelta(note.content);

    return Card(
      color: color?.withValues(alpha: 0.15) ?? theme.colorScheme.surfaceContainerHigh,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title.isEmpty ? 'Untitled' : note.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (note.isPinned)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.push_pin, size: 16),
                    ),
                  if (note.isLocked)
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.lock_outline, size: 16),
                    ),
                ],
              ),
              if (note.isLocked) ...[
                const SizedBox(height: 6),
                Text(
                  'Locked note',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ] else if (preview.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  preview,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
              if (labels != null && labels!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 2,
                  children: [
                    for (final label in labels!.take(2))
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: label.color != null ? Color(label.color!).withValues(alpha: 0.15) : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          label.name,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontSize: 11,
                            color: label.color != null ? Color(label.color!) : null,
                          ),
                        ),
                      ),
                    if (labels!.length > 2)
                      Text(
                        '+${labels!.length - 2}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    _formatDate(note.updatedAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  if (attachmentCount > 0) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.attach_file, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                    const SizedBox(width: 2),
                    Text(
                      '$attachmentCount',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (onDelete != null)
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: onDelete,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  if (onPin != null)
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: onPin,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          note.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                          size: 18,
                          color: note.isPinned
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                ],
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

class NoteCardSkeleton extends StatelessWidget {
  const NoteCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 160,
              height: 16,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 200,
              height: 12,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
