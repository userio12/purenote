import 'dart:convert';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/database/daos/note_dao.dart';
import 'package:purenote/core/providers/database_provider.dart';
import 'package:purenote/core/services/auth_service.dart';
import 'package:purenote/core/services/notification_service.dart';
import 'package:purenote/core/utils/delta_utils.dart';
import 'package:purenote/features/notes/providers/notes_provider.dart';
import 'package:purenote/features/labels/widgets/label_chip.dart';
import 'package:purenote/features/audio/widgets/audio_player_widget.dart';
import 'package:purenote/l10n/app_localizations.dart';

class NoteViewerScreen extends ConsumerStatefulWidget {
  final String noteId;
  const NoteViewerScreen({super.key, required this.noteId});

  @override
  ConsumerState<NoteViewerScreen> createState() => _NoteViewerScreenState();
}

class _NoteViewerScreenState extends ConsumerState<NoteViewerScreen> {
  Document? _document;

  void _buildDocument(String content) {
    try {
      final delta = jsonDecode(content);
      _document = Document.fromJson(delta as List<dynamic>);
    } catch (_) {
      _document = Document()..insert(0, content);
    }
  }

  Future<void> _toggleLock(Note note, NoteDao dao) async {
    if (note.isLocked) {
      final authService = AuthService();
      final verified = await authService.authenticateWithContext(context);
      if (!verified || !mounted) return;
      await dao.updateFields(NotesCompanion(
        id: Value(note.id),
        isLocked: const Value(false),
      ));
    }
  }

  Future<void> _deleteNote(Note note, NoteDao dao) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteNote),
        content: Text(AppLocalizations.of(context)!.deleteNoteConfirm(note.title.isEmpty ? AppLocalizations.of(context)!.untitled : note.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context)!.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppLocalizations.of(context)!.delete)),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await NotificationService.cancel(note.id);
      await dao.delete(note.id);
      if (mounted) context.pop();
    }
  }

  Future<void> _shareNote(Note note) async {
    final text = '${note.title}\n\n${stripQuillDelta(note.content)}';
    await Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final noteAsync = ref.watch(noteByIdProvider(widget.noteId));

    return noteAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.notes)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(AppLocalizations.of(context)!.notes)),
        body: Center(child: Text('Error: $e')),
      ),
      data: (note) {
        if (note == null) {
          return Scaffold(
            appBar: AppBar(title: Text(AppLocalizations.of(context)!.notes)),
            body: Center(child: Text(AppLocalizations.of(context)!.noteNotFound)),
          );
        }

        if (note.content.isNotEmpty && (_document == null || _document!.length == 0)) {
          _buildDocument(note.content);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(note.title.isNotEmpty ? note.title : AppLocalizations.of(context)!.notes),
            actions: [
              IconButton(
                icon: Icon(note.isLocked ? Icons.lock : Icons.lock_open),
                onPressed: () => _toggleLock(note, ref.read(noteDaoProvider)),
                tooltip: note.isLocked ? AppLocalizations.of(context)!.unlock : AppLocalizations.of(context)!.lock,
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareNote(note),
                tooltip: AppLocalizations.of(context)!.share,
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/note/${note.id}'),
                tooltip: AppLocalizations.of(context)!.edit,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _deleteNote(note, ref.read(noteDaoProvider)),
                tooltip: AppLocalizations.of(context)!.delete,
              ),
            ],
          ),
          body: _buildNoteBody(note),
        );
      },
    );
  }

  Widget _buildNoteBody(Note note) {
    if (note.isLocked) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.lockedNote, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => _toggleLock(note, ref.read(noteDaoProvider)),
              child: Text(AppLocalizations.of(context)!.unlock),
            ),
          ],
        ),
      );
    }

    final labelsAsync = ref.watch(labelsForNoteProvider(note.id));
    final attachmentsAsync = ref.watch(attachmentsForNoteProvider(note.id));
    final dateFormat = DateFormat.yMMMd().add_jm();
    final bgColor = note.color != null ? Color(note.color!).withValues(alpha: 0.08) : null;

    return Container(
      color: bgColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title.isNotEmpty ? note.title : AppLocalizations.of(context)!.untitled,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context)!.createdLabel(dateFormat.format(DateTime.fromMillisecondsSinceEpoch(note.createdAt))),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.update, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context)!.updatedLabel(dateFormat.format(DateTime.fromMillisecondsSinceEpoch(note.updatedAt))),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                ),
              ],
            ),
            if (note.reminderAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.notifications, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(
                    AppLocalizations.of(context)!.reminderLabel(dateFormat.format(DateTime.fromMillisecondsSinceEpoch(note.reminderAt!))),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ],
            if (note.isPinned) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.push_pin, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(AppLocalizations.of(context)!.pinned, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
                ],
              ),
            ],
            const SizedBox(height: 12),
            labelsAsync.when(
              data: (labels) => labels.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: labels.map((l) => LabelChip(label: l, selected: false)).toList(),
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            const Divider(),
            if (_document != null && _document!.length > 0)
              QuillEditor.basic(
                controller: QuillController(
                  document: _document!,
                  selection: const TextSelection.collapsed(offset: 0),
                ),
                config: QuillEditorConfig(
                  padding: EdgeInsets.all(4),
                  onLaunchUrl: (url) async {
                    final uri = Uri.tryParse(url.toString());
                    if (uri != null && await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    }
                  },
                ),
              ),
            attachmentsAsync.when(
              data: (attachments) => attachments.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        const Divider(),
                        Text(AppLocalizations.of(context)!.attachments, style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 8),
                        ...attachments.map((a) {
                          if (a.mimeType.startsWith('audio/')) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.audiotrack, size: 20, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: NoteAudioPlayer(
                                      filePath: a.filePath,
                                      dense: true,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListTile(
                            leading: Icon(_iconForMime(a.mimeType)),
                            title: Text(a.fileName),
                            subtitle: Text(_formatSize(a.fileSize)),
                            dense: true,
                            onTap: () => _openAttachment(a),
                          );
                        }),
                      ],
                    ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAttachment(Attachment attachment) async {
    final result = await OpenFilex.open(attachment.filePath);
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.couldNotOpenFile(result.message))),
      );
    }
  }

  IconData _iconForMime(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.startsWith('audio/')) return Icons.audiotrack;
    if (mimeType.startsWith('video/')) return Icons.videocam;
    if (mimeType.startsWith('text/')) return Icons.description;
    return Icons.attach_file;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
