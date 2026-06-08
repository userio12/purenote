import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/error/result.dart';
import 'package:purenote/core/providers/database_provider.dart';
import 'package:purenote/core/services/attachment_service.dart';
import 'package:purenote/core/services/auth_service.dart';
import 'package:purenote/core/services/encryption_service.dart';
import 'package:purenote/core/services/notification_service.dart';
import 'package:purenote/core/theme/app_colors.dart';
import 'package:purenote/core/theme/app_theme.dart';
import 'package:purenote/core/utils/delta_utils.dart';
import 'package:purenote/features/editor/providers/editor_state_provider.dart';
import 'package:purenote/features/editor/widgets/attachment_chips.dart';
import 'package:purenote/features/labels/widgets/label_picker_sheet.dart';
import 'package:purenote/l10n/app_localizations.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  const NoteEditorScreen({super.key, this.noteId});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> with WidgetsBindingObserver {
  late QuillController _quillController;
  late TextEditingController _titleController;
  bool _isNew = true;
  Timer? _saveTimer;
  String? _currentNoteId;
  List<Attachment> _attachments = [];
  List<Label> _noteLabels = [];
  AttachmentService? _attachmentService;
  DateTime? _reminderAt;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _quillController = QuillController.basic();
    _titleController = TextEditingController();
    _isNew = widget.noteId == null;

    _quillController.document.changes.listen((_) {
      ref.read(editorStateProvider.notifier).markDirty();
      _debounceSave();
    });

    _titleController.addListener(() {
      ref.read(editorStateProvider.notifier).markDirty();
      _debounceSave();
    });

    if (!_isNew) {
      _loadNote();
    }
    _checkDraft();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _saveTimer?.cancel();
    _quillController.dispose();
    _titleController.dispose();
    ref.read(editorStateProvider.notifier).reset();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (ref.read(editorStateProvider).saveStatus == SaveStatus.unsaved) {
        unawaited(_save());
      }
    }
  }

  void _debounceSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), () => unawaited(_save()));
  }

  Future<void> _loadNote() async {
    final dao = ref.read(noteDaoProvider);
    final note = await dao.getById(widget.noteId!);
    if (note != null && mounted) {
      _titleController.text = note.title;
      final editorState = ref.read(editorStateProvider.notifier);
      if (note.color != null) editorState.setColor(note.color);
      if (note.reminderAt != null) _reminderAt = DateTime.fromMillisecondsSinceEpoch(note.reminderAt!);
      if (note.isLocked) {
        _isLocked = true;
        if (note.content.isNotEmpty) {
          try {
            final pin = await _getPin();
            if (pin != null && pin.isNotEmpty) {
              final decrypted = EncryptionService.decrypt(note.content, pin);
              final delta = jsonDecode(decrypted) as List;
              final doc = Document.fromJson(delta.cast<Map<String, dynamic>>());
              if (mounted) {
                setState(() {
                  _quillController = QuillController(
                    document: doc,
                    selection: const TextSelection.collapsed(offset: 0),
                  );
                });
              }
            }
          } catch (_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppLocalizations.of(context)!.failedToUnlockNote)),
              );
            }
          }
        }
        return;
      }
      if (note.content.isNotEmpty) {
        try {
          final delta = jsonDecode(note.content) as List;
          final doc = Document.fromJson(delta.cast<Map<String, dynamic>>());
          setState(() {
            _quillController = QuillController(
              document: doc,
              selection: const TextSelection.collapsed(offset: 0),
            );
          });
        } catch (_) {}
      }
      await _loadLabels();
      await _checkDraft();
    }
  }

  Future<void> _save() async {
    final editorState = ref.read(editorStateProvider.notifier);
    editorState.markSaving();
    try {
      final dao = ref.read(noteDaoProvider);
      final id = widget.noteId ?? const Uuid().v4();
      final now = DateTime.now().millisecondsSinceEpoch;
      final delta = _quillController.document.toDelta().toJson();
      final rawJson = jsonEncode(delta);
      final selectedColor = ref.read(editorStateProvider).selectedColor;

      final auth = AuthService();
      final isPinSet = await auth.isPinSet();
      String contentJson;
      if (_isLocked && isPinSet) {
        final pin = await _getPin();
        if (pin == null) return;
        contentJson = EncryptionService.encrypt(rawJson, pin);
      } else {
        contentJson = rawJson;
      }

      final reminderMs = _reminderAt?.millisecondsSinceEpoch;

      if (_isNew) {
        final result = await dao.insert(id: id, createdAt: now, updatedAt: now);
        if (result is Ok && mounted) {
          await dao.updateFields(NotesCompanion(
            id: Value(id),
            title: Value(_titleController.text),
            content: Value(contentJson),
            color: Value(selectedColor),
            isLocked: Value(_isLocked),
            reminderAt: Value(reminderMs),
          ));
          _isNew = false;
        }
      } else {
        await dao.updateFields(NotesCompanion(
          id: Value(widget.noteId!),
          title: Value(_titleController.text),
          content: Value(contentJson),
          color: Value(selectedColor),
          isLocked: Value(_isLocked),
          reminderAt: Value(reminderMs),
          updatedAt: Value(now),
        ));
      }

      if (mounted) {
        _currentNoteId = id;
        _attachmentService ??= AttachmentService(ref.read(attachmentDaoProvider));
        _loadAttachments();
        _deleteDraft();

        if (_reminderAt != null) {
          await NotificationService.schedule(dao, id, _titleController.text, _reminderAt!);
        } else {
          await NotificationService.cancel(id);
        }

        editorState.markSaved();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) editorState.markIdle();
        });
      }
    } catch (e) {
      if (mounted) {
        editorState.markDirty();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.failedToSaveNote)),
        );
      }
    }
  }

  Future<void> _loadAttachments() async {
    if (_currentNoteId == null) return;
    final dao = ref.read(attachmentDaoProvider);
    final items = await dao.getByNoteId(_currentNoteId!);
    if (mounted) setState(() => _attachments = items);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    await _attachFile(path, result.files.single.extension != null
        ? 'application/${result.files.single.extension}'
        : null);
  }

  Future<void> _attachFile(String path, String? mimeType) async {
    final id = _currentNoteId;
    if (id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.saveFirst)),
        );
      }
      return;
    }

    final service = AttachmentService(ref.read(attachmentDaoProvider));
    final file = File(path);
    final attachResult = await service.attachFile(
      noteId: id,
      sourceFile: file,
      mimeType: mimeType,
    );

    if (attachResult is Ok && mounted) {
      _loadAttachments();
      _debounceSave();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.failedToAttachFile)),
      );
    }
  }

  Future<void> _deleteAttachment(Attachment attachment) async {
    final service = AttachmentService(ref.read(attachmentDaoProvider));
    await service.deleteAttachment(attachment);
    if (mounted) {
      _loadAttachments();
      _debounceSave();
    }
  }

  Future<bool> _onWillPop() async {
    if (ref.read(editorStateProvider).saveStatus != SaveStatus.unsaved) return true;
    await _saveDraft();
    if (!mounted) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.discardChanges),
        content: Text(AppLocalizations.of(context)!.discardChangesContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          FilledButton(
            onPressed: () {
              _saveTimer?.cancel();
              Navigator.of(ctx).pop(true);
            },
            child: Text(AppLocalizations.of(context)!.discard),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showColorPicker() {
    final currentColor = ref.read(editorStateProvider).selectedColor;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.noteColor, style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _colorCircle(ctx, null, currentColor == null),
                for (final c in AppTheme.noteColors)
                  _colorCircle(ctx, c, currentColor == c),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _colorCircle(BuildContext ctx, int? color, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(editorStateProvider.notifier).setColor(color);
        _debounceSave();
        Navigator.of(ctx).pop();
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color != null ? Color(color) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(ctx).colorScheme.primary
                : Theme.of(ctx).colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 3 : 1,
          ),
        ),
      ),
    );
  }

  void _toggleLock() {
    setState(() => _isLocked = !_isLocked);
    _debounceSave();
  }

  Future<String?> _getPin() async {
    final controller = TextEditingController();
    final pin = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.enterPin),
        content: TextField(
          controller: controller,
          obscureText: true,
          maxLength: 6,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.yourPin,
            counterText: '',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(AppLocalizations.of(context)!.cancel)),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
    controller.dispose();
    return pin;
  }

  Future<void> _loadLabels() async {
    if (widget.noteId == null) return;
    final labels = await ref.read(labelDaoProvider).getLabelsForNote(widget.noteId!);
    if (mounted) setState(() => _noteLabels = labels);
  }

  Future<void> _showLabelPicker() async {
    final result = await showLabelPickerSheet(context, selected: _noteLabels);
    if (result == null || widget.noteId == null) return;
    final dao = ref.read(labelDaoProvider);
    final newIds = result.map((l) => l.id).toSet();
    final oldIds = _noteLabels.map((l) => l.id).toSet();
    final toRemove = oldIds.difference(newIds);
    final toAdd = newIds.difference(oldIds);
    for (final id in toRemove) {
      await dao.removeLabelFromNote(widget.noteId!, id);
    }
    for (final id in toAdd) {
      await dao.assignLabelToNote(widget.noteId!, id);
    }
    await _loadLabels();
    _debounceSave();
  }

  Future<void> _shareNote() async {
    final title = _titleController.text;
    final content = stripQuillDelta(jsonEncode(_quillController.document.toDelta().toJson()));
    await Share.share('$title\n\n$content');
  }

  Future<void> _checkDraft() async {
    if (widget.noteId == null) return;
    final dir = await getTemporaryDirectory();
    final draftFile = File('${dir.path}/draft_${widget.noteId}.json');
    if (!await draftFile.exists()) return;
    if (!mounted) return;
    final restore = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.recoverDraft),
        content: Text(AppLocalizations.of(context)!.recoverDraftContent),
        actions: [
          TextButton(
            onPressed: () async {
              await draftFile.delete();
              if (ctx.mounted) Navigator.pop(ctx, false);
            },
            child: Text(AppLocalizations.of(context)!.discard),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(AppLocalizations.of(context)!.restore),
          ),
        ],
      ),
    );
    if (restore != true || !mounted) return;
    try {
      final data = await draftFile.readAsString();
      final draft = jsonDecode(data) as Map<String, dynamic>;
      _titleController.text = draft['title'] as String? ?? '';
      final delta = draft['content'] as List?;
      if (delta != null) {
        final doc = Document.fromJson(delta.cast<Map<String, dynamic>>());
        setState(() {
          _quillController = QuillController(
            document: doc,
            selection: const TextSelection.collapsed(offset: 0),
          );
        });
        ref.read(editorStateProvider.notifier).markDirty();
      }
      await draftFile.delete();
    } catch (_) {}
  }

  Future<void> _saveDraft() async {
    if (widget.noteId == null) return;
    final dir = await getTemporaryDirectory();
    final draftFile = File('${dir.path}/draft_${widget.noteId}.json');
    final delta = _quillController.document.toDelta().toJson();
    final draft = jsonEncode({'title': _titleController.text, 'content': delta});
    await draftFile.writeAsString(draft);
  }

  Future<void> _deleteDraft() async {
    if (widget.noteId == null) return;
    final dir = await getTemporaryDirectory();
    final draftFile = File('${dir.path}/draft_${widget.noteId}.json');
    if (await draftFile.exists()) await draftFile.delete();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    await _attachFile(path, result.files.single.extension != null ? 'image/${result.files.single.extension}' : 'image/*');
  }

  Future<void> _pickCamera() async {
    final result = await ImagePicker().pickImage(source: ImageSource.camera);
    if (result == null) return;
    await _attachFile(result.path, 'image/jpeg');
  }

  void _showReminderPicker() {
    final colors = Theme.of(context).extension<AppColors>()!;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_reminderAt != null)
              ListTile(
                leading: const Icon(Icons.alarm),
                title: Text(
                  'Reminder set for ${_formatReminder(_reminderAt!)}',
                ),
                subtitle: Text(AppLocalizations.of(context)!.tapToChangeOrRemove),
              ),
            ListTile(
              leading: const Icon(Icons.edit_calendar),
              title: Text(AppLocalizations.of(context)!.setReminder),
              onTap: () async {
                Navigator.of(ctx).pop();
                final date = await showDatePicker(
                  context: context,
                  initialDate: _reminderAt ?? DateTime.now().add(const Duration(hours: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date == null || !mounted) return;
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(_reminderAt ?? DateTime.now()),
                );
                if (time == null || !mounted) return;
                final reminder = DateTime(
                  date.year, date.month, date.day, time.hour, time.minute,
                );
                setState(() => _reminderAt = reminder);
                _debounceSave();
              },
            ),
            if (_reminderAt != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: colors.accentDanger),
                title: Text(AppLocalizations.of(context)!.removeReminder, style: TextStyle(color: colors.accentDanger)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  setState(() => _reminderAt = null);
                  _debounceSave();
                },
              ),
          ],
        ),
      ),
    );
  }

  String _formatReminder(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.inMinutes < 60) return '${diff.inMinutes} min';
    if (diff.inHours < 24) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final saveStatus = ref.watch(editorStateProvider.select((s) => s.saveStatus));
    final selectedColor = ref.watch(editorStateProvider.select((s) => s.selectedColor));
    final color = selectedColor != null ? Color(selectedColor) : null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canPop = await _onWillPop();
        if (canPop && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: color?.withValues(alpha: 0.08),
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final canPop = await _onWillPop();
              if (canPop && context.mounted) context.pop();
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.label_outline),
              onPressed: _showLabelPicker,
              tooltip: AppLocalizations.of(context)!.labels,
            ),
            IconButton(
              icon: const Icon(Icons.palette_outlined),
              onPressed: _showColorPicker,
              tooltip: AppLocalizations.of(context)!.color,
            ),
            IconButton(
              icon: Icon(
                _isLocked ? Icons.lock : Icons.lock_open_outlined,
              ),
              onPressed: _toggleLock,
              tooltip: _isLocked ? AppLocalizations.of(context)!.locked : AppLocalizations.of(context)!.unlock,
            ),
            IconButton(
              icon: Icon(
                _reminderAt != null ? Icons.alarm : Icons.alarm_outlined,
              ),
              onPressed: _showReminderPicker,
              tooltip: AppLocalizations.of(context)!.reminder,
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareNote,
              tooltip: AppLocalizations.of(context)!.share,
            ),
            IconButton(
              icon: const Icon(Icons.mic_outlined),
              onPressed: () {
                final id = _currentNoteId;
                if (id == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context)!.saveFirst)),
                  );
                  return;
                }
                context.push('/audio/record/$id');
              },
              tooltip: AppLocalizations.of(context)!.recordAudio,
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _save,
              tooltip: AppLocalizations.of(context)!.save,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _titleController,
                autofocus: _isNew,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.titleHint,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            QuillSimpleToolbar(
              controller: _quillController,
              config: const QuillSimpleToolbarConfig(
                showFontFamily: false,
                showFontSize: false,
                showSubscript: false,
                showSuperscript: false,
                showDirection: false,
                showBoldButton: true,
                showItalicButton: true,
                showUnderLineButton: true,
                showStrikeThrough: true,
                showInlineCode: true,
                showHeaderStyle: true,
                showListNumbers: true,
                showListBullets: true,
                showListCheck: true,
                showCodeBlock: true,
                showQuote: true,
                showIndent: false,
                showLink: true,
                showUndo: true,
                showRedo: true,
                multiRowsDisplay: false,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: QuillEditor.basic(
                  controller: _quillController,
                  config: QuillEditorConfig(
                    placeholder: AppLocalizations.of(context)!.startWriting,
                    padding: const EdgeInsets.only(top: 8),
                  ),
                ),
              ),
            ),
            if (_currentNoteId != null)
              AttachmentChips(
                attachments: _attachments,
                service: AttachmentService(ref.read(attachmentDaoProvider)),
                onAdd: _pickFile,
                onAddImage: _pickImage,
                onAddCamera: _pickCamera,
                onDelete: _deleteAttachment,
              ),
            _SaveStatusBar(saveStatus: saveStatus),
          ],
        ),
      ),
    );
  }
}

class _SaveStatusBar extends StatelessWidget {
  final SaveStatus saveStatus;
  const _SaveStatusBar({required this.saveStatus});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;
    String text;
    IconData icon;
    Color color;

    switch (saveStatus) {
      case SaveStatus.idle:
      case SaveStatus.saved:
        text = AppLocalizations.of(context)!.saved;
        icon = Icons.check_circle_outline;
        color = colors.accentSuccess;
      case SaveStatus.saving:
        text = AppLocalizations.of(context)!.saving;
        icon = Icons.sync;
        color = theme.colorScheme.primary;
      case SaveStatus.unsaved:
        text = AppLocalizations.of(context)!.unsavedChanges;
        icon = Icons.edit_outlined;
        color = colors.accentWarm;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
