import 'package:flutter/material.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/services/attachment_service.dart';

class AttachmentChips extends StatelessWidget {
  final List<Attachment> attachments;
  final AttachmentService service;
  final VoidCallback onAdd;
  final VoidCallback onAddImage;
  final VoidCallback onAddCamera;
  final ValueChanged<Attachment> onDelete;

  const AttachmentChips({
    super.key,
    required this.attachments,
    required this.service,
    required this.onAdd,
    required this.onAddImage,
    required this.onAddCamera,
    required this.onDelete,
  });

  IconData _iconFor(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.startsWith('audio/')) return Icons.audiotrack;
    if (mimeType.startsWith('video/')) return Icons.videocam;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf;
    return Icons.attach_file;
  }

  @override
  Widget build(BuildContext context) {
    if (attachments.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Attachments', style: theme.textTheme.labelSmall),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ...attachments.map(
                (a) => InputChip(
                  avatar: Icon(_iconFor(a.mimeType), size: 18),
                  label: Text(
                    _shortName(a.fileName),
                    style: const TextStyle(fontSize: 13),
                  ),
                  onDeleted: () => onDelete(a),
                  deleteIconColor: theme.colorScheme.error,
                ),
              ),
              ActionChip(
                avatar: const Icon(Icons.add, size: 18),
                label: const Text('Add', style: TextStyle(fontSize: 13)),
                onPressed: onAdd,
              ),
              ActionChip(
                avatar: const Icon(Icons.image, size: 18),
                label: const Text('Image', style: TextStyle(fontSize: 13)),
                onPressed: onAddImage,
              ),
              ActionChip(
                avatar: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Camera', style: TextStyle(fontSize: 13)),
                onPressed: onAddCamera,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _shortName(String name) {
    if (name.length <= 24) return name;
    return '${name.substring(0, 20)}...';
  }
}
