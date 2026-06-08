import 'package:flutter/services.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/database/note_type.dart';
import 'package:purenote/core/providers/database_provider.dart';
import 'package:purenote/core/providers/settings_provider.dart';
import 'package:purenote/core/services/notification_service.dart';
import 'package:purenote/features/notes/providers/notes_provider.dart';
import 'package:purenote/features/notes/widgets/note_card.dart';
import 'package:purenote/features/notes/widgets/note_tile.dart';
import 'package:purenote/features/labels/widgets/label_picker_sheet.dart';
import 'package:purenote/l10n/app_localizations.dart';

final _selectedIdsProvider = StateProvider<Set<String>>((_) => {});

class NotesListScreen extends ConsumerStatefulWidget {
  const NotesListScreen({super.key});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  String? _selectedLabelId;

  List<Note> _sortNotes(List<Note> notes, AppSettings settings) {
    final sorted = List<Note>.from(notes);
    final ascending = settings.sortAscending;
    switch (settings.sortBy) {
      case 'title':
        sorted.sort((a, b) => ascending
            ? a.title.compareTo(b.title)
            : b.title.compareTo(a.title));
        break;
      case 'created':
        sorted.sort((a, b) => ascending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
      default:
        sorted.sort((a, b) => ascending
            ? a.updatedAt.compareTo(b.updatedAt)
            : b.updatedAt.compareTo(a.updatedAt));
    }
    return sorted;
  }

  Future<void> _bulkDelete() async {
    final ids = ref.read(_selectedIdsProvider);
    if (ids.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteNotes),
        content: Text(AppLocalizations.of(context)!.deleteNotesConfirm(ids.length)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(AppLocalizations.of(context)!.cancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(AppLocalizations.of(context)!.delete)),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final dao = ref.read(noteDaoProvider);
      for (final id in ids) {
        await NotificationService.cancel(id);
        await dao.delete(id);
      }
      ref.read(_selectedIdsProvider.notifier).state = {};
    }
  }

  Future<void> _bulkPin(bool pin) async {
    final ids = ref.read(_selectedIdsProvider);
    final dao = ref.read(noteDaoProvider);
    for (final id in ids) {
      await dao.updateFields(NotesCompanion(
        id: Value(id),
        isPinned: Value(pin),
      ));
    }
    ref.read(_selectedIdsProvider.notifier).state = {};
  }

  Future<void> _bulkLabel() async {
    final ids = ref.read(_selectedIdsProvider);
    final labelDao = ref.read(labelDaoProvider);
    if (!mounted) return;
    final result = await showLabelPickerSheet(context, selected: []);
    if (result != null && mounted) {
      for (final id in ids) {
        for (final label in result) {
          await labelDao.assignLabelToNote(id, label.id);
        }
      }
      ref.read(_selectedIdsProvider.notifier).state = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = _selectedLabelId != null
        ? ref.watch(notesByLabelProvider(_selectedLabelId!))
        : ref.watch(notesStreamProvider);
    final settings = ref.watch(settingsNotifierProvider);
    final labelsAsync = ref.watch(allLabelsProvider);
    final selectedIds = ref.watch(_selectedIdsProvider);

    final isSelectionMode = selectedIds.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: isSelectionMode
            ? Text('${selectedIds.length} selected')
            : Text(AppLocalizations.of(context)!.notes),
        leading: isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => ref.read(_selectedIdsProvider.notifier).state = {},
              )
            : null,
        actions: [
          if (isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.push_pin),
              onPressed: () => _bulkPin(true),
              tooltip: AppLocalizations.of(context)!.pinAll,
            ),
            IconButton(
              icon: const Icon(Icons.label_outline),
              onPressed: _bulkLabel,
              tooltip: AppLocalizations.of(context)!.addLabel,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _bulkDelete,
              tooltip: AppLocalizations.of(context)!.deleteAll,
            ),
          ] else ...[
            PopupMenuButton<String>(
              initialValue: settings.sortBy,
              icon: const Icon(Icons.sort),
              tooltip: AppLocalizations.of(context)!.sortBy,
              onSelected: (value) {
                if (value == settings.sortBy) {
                  ref.read(settingsNotifierProvider.notifier).update(
                    settings.copyWith(sortAscending: !settings.sortAscending),
                  );
                } else {
                  ref.read(settingsNotifierProvider.notifier).update(
                    settings.copyWith(sortBy: value, sortAscending: false),
                  );
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'modified',
                  child: Row(
                    children: [
                      if (settings.sortBy == 'modified')
                        Icon(Icons.check, size: 18, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(settings.sortBy == 'modified' && settings.sortAscending ? AppLocalizations.of(context)!.oldest : AppLocalizations.of(context)!.latest),
                    ],
                  ),
                ),
                PopupMenuDivider(),
                PopupMenuItem(value: 'title', child: Text(AppLocalizations.of(context)!.sortTitle)),
                PopupMenuItem(value: 'created', child: Text(AppLocalizations.of(context)!.sortCreated)),
                PopupMenuItem(value: 'modified', child: Text(AppLocalizations.of(context)!.sortModified)),
              ],
            ),
            IconButton(
              icon: Icon(
                settings.viewMode == 0 ? Icons.grid_view : Icons.list,
              ),
              onPressed: () {
                ref.read(settingsNotifierProvider.notifier).update(
                  settings.copyWith(viewMode: settings.viewMode == 0 ? 1 : 0),
                );
              },
              tooltip: settings.viewMode == 0 ? AppLocalizations.of(context)!.gridView : AppLocalizations.of(context)!.listView,
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => context.push('/search'),
              tooltip: AppLocalizations.of(context)!.searchNotes,
            ),
          ],
        ],
      ),
      body: notesAsync.when(
        data: (notes) {
          final sorted = _sortNotes(notes, settings);
          final pinned = sorted.where((n) => n.isPinned).toList();
          final unpinned = sorted.where((n) => !n.isPinned).toList();

          if (notes.isEmpty) {
            return const _EmptyState(hasFilter: false);
          }

          if (sorted.isEmpty) {
            return _EmptyState(hasFilter: true);
          }

          return Column(
            children: [
              labelsAsync.when(
                data: (allLabels) => allLabels.isEmpty
                    ? const SizedBox.shrink()
                    : SizedBox(
                        height: 48,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                label: Text(AppLocalizations.of(context)!.all),
                                selected: _selectedLabelId == null,
                                onSelected: (_) => setState(() => _selectedLabelId = null),
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                            ...allLabels.map((label) => Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                label: Text(label.name),
                                selected: _selectedLabelId == label.id,
                                onSelected: (_) => setState(() => _selectedLabelId = _selectedLabelId == label.id ? null : label.id),
                                visualDensity: VisualDensity.compact,
                                selectedColor: label.color != null
                                    ? Color(label.color!).withValues(alpha: 0.2)
                                    : null,
                                side: label.color != null
                                    ? BorderSide(color: Color(label.color!).withValues(alpha: 0.4))
                                    : null,
                              ),
                            )),
                          ],
                        ),
                      ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: settings.viewMode == 1
                      ? _GridNotesView(
                          key: const ValueKey('grid'),
                          pinned: pinned,
                          unpinned: unpinned,
                          selectedIds: selectedIds,
                          onTap: (note) => _onNoteTap(note),
                          onLongPress: (note) => _onNoteLongPress(note),
                          onPin: (note) => _togglePin(note),
                          onDelete: (note) => _deleteNote(note),
                        )
                      : _ListNotesView(
                          key: const ValueKey('list'),
                          pinned: pinned,
                          unpinned: unpinned,
                          selectedIds: selectedIds,
                          onTap: (note) => _onNoteTap(note),
                          onLongPress: (note) => _onNoteLongPress(note),
                          onPin: (note) => _togglePin(note),
                          onDelete: (note) => _deleteNote(note),
                        ),
                ),
              ),
            ],
          );
        },
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          itemBuilder: (_, _) => const NoteCardSkeleton(),
        ),
        error: (e, _) => _ErrorState(onRetry: () => ref.invalidate(notesStreamProvider)),
      ),
      floatingActionButton: !isSelectionMode
          ? FloatingActionButton(
              onPressed: () => context.push('/note/new'),
              tooltip: AppLocalizations.of(context)!.newNote,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  void _onNoteTap(Note note) {
    final selected = ref.read(_selectedIdsProvider);
    if (selected.isNotEmpty) {
      final notifier = ref.read(_selectedIdsProvider.notifier);
      notifier.update((state) {
        if (state.contains(note.id)) {
          state.remove(note.id);
        } else {
          state.add(note.id);
        }
        return {...state};
      });
      return;
    }
    if (note.isTaskList) {
      context.push('/task-list/${note.id}');
    } else {
      context.push('/note/${note.id}');
    }
  }

  void _onNoteLongPress(Note note) {
    final selected = ref.read(_selectedIdsProvider);
    if (selected.isEmpty) {
      ref.read(_selectedIdsProvider.notifier).state = {note.id};
    }
  }

  Future<void> _togglePin(Note note) async {
    final dao = ref.read(noteDaoProvider);
    await dao.togglePin(note.id);
  }

  Future<void> _deleteNote(Note note) async {
    final dao = ref.read(noteDaoProvider);
    final deletedNote = await dao.getById(note.id);
    await NotificationService.cancel(note.id);
    await dao.delete(note.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.noteDeleted),
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.undo,
          onPressed: () async {
            if (deletedNote != null) {
              final dao = ref.read(noteDaoProvider);
              await dao.insert(
                id: deletedNote.id,
                createdAt: deletedNote.createdAt,
                updatedAt: deletedNote.updatedAt,
              );
            }
          },
        ),
      ),
    );
  }
}

class _ListNotesView extends StatelessWidget {
  final List<Note> pinned;
  final List<Note> unpinned;
  final Set<String> selectedIds;
  final void Function(Note) onTap;
  final void Function(Note) onLongPress;
  final void Function(Note) onPin;
  final void Function(Note) onDelete;

  const _ListNotesView({
    super.key,
    required this.pinned,
    required this.unpinned,
    required this.selectedIds,
    required this.onTap,
    required this.onLongPress,
    required this.onPin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: pinned.length + unpinned.length + (pinned.isNotEmpty ? 1 : 0),
      itemBuilder: (context, index) {
        if (pinned.isNotEmpty && index == pinned.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              AppLocalizations.of(context)!.others,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          );
        }

        final note = index < pinned.length
            ? pinned[index]
            : unpinned[index - pinned.length - (pinned.isNotEmpty ? 1 : 0)];

        return Dismissible(
          key: ValueKey('note_${note.id}'),
          direction: DismissDirection.horizontal,
          background: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            color: Theme.of(context).colorScheme.primary,
            child: note.isPinned
                ? Icon(Icons.push_pin, color: Theme.of(context).colorScheme.onPrimary)
                : Icon(Icons.push_pin_outlined, color: Theme.of(context).colorScheme.onPrimary),
          ),
          secondaryBackground: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Theme.of(context).colorScheme.error,
            child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.onError),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              HapticFeedback.mediumImpact();
              onPin(note);
            } else {
              onDelete(note);
            }
            return false;
          },
          child: NoteTile(
            note: note,
            onTap: () => onTap(note),
            onLongPress: () => onLongPress(note),
            onPin: () => onPin(note),
            onDelete: () => onDelete(note),
            isSelected: selectedIds.contains(note.id),
          ),
        );
      },
    );
  }
}

class _GridNotesView extends StatelessWidget {
  final List<Note> pinned;
  final List<Note> unpinned;
  final Set<String> selectedIds;
  final void Function(Note) onTap;
  final void Function(Note) onLongPress;
  final void Function(Note) onPin;
  final void Function(Note) onDelete;

  const _GridNotesView({
    super.key,
    required this.pinned,
    required this.unpinned,
    required this.selectedIds,
    required this.onTap,
    required this.onLongPress,
    required this.onPin,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final all = [...pinned, ...unpinned];
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: all.length,
      itemBuilder: (context, index) {
        final note = all[index];
        return NoteCard(
          note: note,
          onTap: () => onTap(note),
          onPin: () => onPin(note),
          onDelete: () => onDelete(note),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  const _EmptyState({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            hasFilter ? Icons.filter_list_off : Icons.note_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilter ? AppLocalizations.of(context)!.noMatchingNotes : AppLocalizations.of(context)!.noNotesYet,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilter ? AppLocalizations.of(context)!.tryDifferentFilter : AppLocalizations.of(context)!.tapToCreateFirstNote,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey.shade500),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.couldNotLoadNotes,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
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
