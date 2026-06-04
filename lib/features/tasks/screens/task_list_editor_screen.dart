import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/error/result.dart';
import 'package:purenote/core/providers/database_provider.dart';
import 'package:purenote/core/theme/app_theme.dart';
import 'package:purenote/features/labels/widgets/label_picker_sheet.dart';

class TaskListEditorScreen extends ConsumerStatefulWidget {
  final String? noteId;
  const TaskListEditorScreen({super.key, this.noteId});

  @override
  ConsumerState<TaskListEditorScreen> createState() => _TaskListEditorScreenState();
}

class _TaskListEditorScreenState extends ConsumerState<TaskListEditorScreen> {
  late TextEditingController _titleController;
  final _itemControllers = <String, TextEditingController>{};
  final _itemFocusNodes = <String, FocusNode>{};
  final _itemChecked = <String, bool>{};
  final _itemParentId = <String, String?>{};
  final _expandedItems = <String>{};
  bool _isNew = true;
  Timer? _saveTimer;
  int? _selectedColor;
  List<Label> _noteLabels = [];
  bool _isPinned = false;
  bool _autoSort = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _isNew = widget.noteId == null;
    if (!_isNew) _loadTaskList();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _titleController.dispose();
    for (final c in _itemControllers.values) {
      c.dispose();
    }
    for (final f in _itemFocusNodes.values) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _loadTaskList() async {
    final dao = ref.read(noteDaoProvider);
    final note = await dao.getById(widget.noteId!);
    if (note != null && mounted) {
      _titleController.text = note.title;
      _selectedColor = note.color;
      _isPinned = note.isPinned;
      final labelDao = ref.read(labelDaoProvider);
      _noteLabels = await labelDao.getLabelsForNote(note.id);
      final taskDao = ref.read(taskDaoProvider);
      final items = await taskDao.watchByNoteId(widget.noteId!).first;
      if (mounted) {
        setState(() {
          for (final item in items) {
            _itemControllers[item.id] = TextEditingController(text: item.content);
            _itemFocusNodes[item.id] = FocusNode();
            _itemChecked[item.id] = item.isChecked;
            _itemParentId[item.id] = item.parentId;
          }
        });
      }
    }
  }

  void _addItem({String? parentId}) {
    final id = const Uuid().v4();
    setState(() {
      _itemControllers[id] = TextEditingController();
      _itemFocusNodes[id] = FocusNode();
      _itemChecked[id] = false;
      _itemParentId[id] = parentId;
    });
    _debounceSave();
    Future.microtask(() => _itemFocusNodes[id]?.requestFocus());
  }

  void _removeItem(String id) {
    _itemControllers[id]?.dispose();
    _itemFocusNodes[id]?.dispose();
    final childIds = _itemParentId.entries
        .where((e) => e.value == id)
        .map((e) => e.key)
        .toList();
    setState(() {
      _itemControllers.remove(id);
      _itemFocusNodes.remove(id);
      _itemChecked.remove(id);
      _itemParentId.remove(id);
      for (final cid in childIds) {
        _itemParentId[cid] = null;
      }
    });
    _debounceSave();
  }

  void _toggleChecked(String id) {
    setState(() {
      _itemChecked[id] = !(_itemChecked[id] ?? false);
    });
    _debounceSave();
  }

  void _toggleSubtask(String id) {
    setState(() {
      _itemParentId[id] = _itemParentId[id] == null ? _firstUncheckedId(id) : null;
    });
    _debounceSave();
  }

  String? _firstUncheckedId(String excludeId) {
    final sorted = _sortedItems();
    for (final item in sorted) {
      if (item.key != excludeId && !(_itemChecked[item.key] ?? false)) return item.key;
    }
    return null;
  }

  void _removeAllChecked() {
    setState(() {
      final checked = _itemChecked.entries.where((e) => e.value).map((e) => e.key).toSet();
      for (final id in checked) {
        _itemControllers[id]?.dispose();
        _itemFocusNodes[id]?.dispose();
        final childIds = _itemParentId.entries
            .where((e) => e.value == id)
            .map((e) => e.key)
            .toList();
        _itemControllers.remove(id);
        _itemFocusNodes.remove(id);
        _itemChecked.remove(id);
        _itemParentId.remove(id);
        for (final cid in childIds) {
        _itemParentId[cid] = null;
      }
      }
    });
    _debounceSave();
  }

  List<MapEntry<String, int>> _sortedItems() {
    final entries = _itemControllers.entries.toList();
    if (!_autoSort) {
      return entries.asMap().entries.map((e) => MapEntry(e.value.key, e.key)).toList();
    }
    final unchecked = <MapEntry<String, int>>[];
    final checked = <MapEntry<String, int>>[];
    for (var i = 0; i < entries.length; i++) {
      final id = entries[i].key;
      if (_itemChecked[id] == true) {
        checked.add(MapEntry(id, i));
      } else {
        unchecked.add(MapEntry(id, i));
      }
    }
    return [...unchecked, ...checked];
  }

  List<MapEntry<String, int>> _visibleItems() {
    final sorted = _sortedItems();
    final hiddenParents = <String>{};
    for (final entry in sorted) {
      final parentId = _itemParentId[entry.key];
      if (parentId != null && !_expandedItems.contains(parentId)) {
        hiddenParents.add(entry.key);
      }
    }
    return sorted.where((e) => !hiddenParents.contains(e.key)).toList();
  }

  List<String> _childIds(String parentId) {
    return _itemParentId.entries
        .where((e) => e.value == parentId)
        .map((e) => e.key)
        .toList();
  }

  void _debounceSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 600), _save);
  }

  Future<void> _save() async {
    try {
      final noteDao = ref.read(noteDaoProvider);
      final taskDao = ref.read(taskDaoProvider);
      final id = widget.noteId ?? const Uuid().v4();
      final now = DateTime.now().millisecondsSinceEpoch;

      if (_isNew) {
        final result = await noteDao.insert(id: id, createdAt: now, updatedAt: now);
        if (result is Ok && mounted) {
          await noteDao.updateFields(NotesCompanion(
            id: Value(id),
            title: Value(_titleController.text),
            type: const Value(1),
            color: Value(_selectedColor),
            isPinned: Value(_isPinned),
          ));
          _isNew = false;
        }
      } else {
        await noteDao.updateFields(NotesCompanion(
          id: Value(widget.noteId!),
          title: Value(_titleController.text),
          color: Value(_selectedColor),
          isPinned: Value(_isPinned),
          updatedAt: Value(now),
        ));
        await taskDao.deleteByNoteId(id);
      }

      double orderIndex = 0;
      for (final entry in _itemControllers.entries) {
        if (entry.value.text.isNotEmpty) {
          await taskDao.insert(TaskItemsCompanion(
            id: Value(entry.key),
            noteId: Value(id),
            content: Value(entry.value.text),
            isChecked: Value(_itemChecked[entry.key] ?? false),
            parentId: Value(_itemParentId[entry.key]),
            orderIndex: Value(orderIndex),
          ));
          orderIndex += 1.0;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save task list')),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    final hasContent = _titleController.text.isNotEmpty ||
        _itemControllers.values.any((c) => c.text.isNotEmpty);
    if (!hasContent && _isNew) return true;
    await _save();
    return true;
  }

  void _showColorPicker() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Color', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() => _selectedColor = null);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade400),
                        color: _selectedColor == null
                            ? Theme.of(ctx).colorScheme.primaryContainer
                            : null,
                      ),
                      child: _selectedColor == null
                          ? Icon(Icons.check, size: 18, color: Theme.of(ctx).colorScheme.onPrimaryContainer)
                          : Icon(Icons.close, size: 18, color: Colors.grey.shade500),
                    ),
                  ),
                  for (final c in AppTheme.noteColors)
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        setState(() => _selectedColor = c);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(c),
                          border: _selectedColor == c
                              ? Border.all(color: Theme.of(ctx).colorScheme.primary, width: 3)
                              : null,
                        ),
                        child: _selectedColor == c
                            ? Icon(Icons.check, size: 18, color: Colors.white)
                            : null,
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

  Future<void> _showLabelPicker() async {
    if (widget.noteId == null && _isNew) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Save the task list first to add labels')),
      );
      return;
    }
    final noteId = widget.noteId;
    if (noteId == null) return;
    final result = await showLabelPickerSheet(context, selected: _noteLabels);
    if (result == null) return;
    final dao = ref.read(labelDaoProvider);
    final newIds = result.map((l) => l.id).toSet();
    final oldIds = _noteLabels.map((l) => l.id).toSet();
    for (final id in oldIds.difference(newIds)) {
      await dao.removeLabelFromNote(noteId, id);
    }
    for (final id in newIds.difference(oldIds)) {
      await dao.assignLabelToNote(noteId, id);
    }
    final labels = await dao.getLabelsForNote(noteId);
    if (mounted) setState(() => _noteLabels = labels);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = _selectedColor != null ? Color(_selectedColor!).withValues(alpha: 0.08) : null;
    final checkedCount = _itemChecked.values.where((v) => v).length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canPop = await _onWillPop();
        if (canPop && context.mounted) context.pop();
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text(_isNew ? 'New Task List' : 'Edit Task List'),
          actions: [
            IconButton(
              icon: Icon(_isPinned ? Icons.push_pin : Icons.push_pin_outlined),
              onPressed: () => setState(() => _isPinned = !_isPinned),
              tooltip: _isPinned ? 'Unpin' : 'Pin',
            ),
            IconButton(
              icon: const Icon(Icons.label_outline),
              onPressed: _showLabelPicker,
              tooltip: 'Labels',
            ),
            IconButton(
              icon: const Icon(Icons.palette_outlined),
              onPressed: _showColorPicker,
              tooltip: 'Color',
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                await _save();
                if (context.mounted) context.pop();
              },
              tooltip: 'Save',
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: TextField(
                controller: _titleController,
                onChanged: (_) => _debounceSave(),
                decoration: const InputDecoration(
                  hintText: 'Task list title',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _itemControllers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.playlist_add, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'No items yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          FilledButton.tonalIcon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add),
                            label: const Text('Add item'),
                          ),
                        ],
                      ),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: _visibleItems().length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          final visible = _visibleItems();
                          if (oldIndex >= visible.length || newIndex >= visible.length) return;
                          final entries = _itemControllers.entries.toList();
                          final keys = visible.map((e) => e.key).toList();
                          final item = keys.removeAt(oldIndex);
                          keys.insert(newIndex, item);
                          _itemControllers
                            ..clear()
                            ..addEntries(entries.where((e) => keys.contains(e.key)));
                        });
                        _debounceSave();
                      },
                      itemBuilder: (context, index) {
                        final sorted = _visibleItems();
                        if (index >= sorted.length) return const SizedBox.shrink();
                        final entry = sorted[index];
                        final id = entry.key;
                        final isChild = _itemParentId[id] != null;
                        final children = _childIds(id);
                        final isExpanded = _expandedItems.contains(id);

                        return _TaskItemTile(
                          key: ValueKey(id),
                          index: index,
                          controller: _itemControllers[id]!,
                          focusNode: _itemFocusNodes[id]!,
                          isChecked: _itemChecked[id] ?? false,
                          isChild: isChild,
                          hasChildren: children.isNotEmpty,
                          isExpanded: isExpanded,
                          onToggleChecked: () => _toggleChecked(id),
                          onDelete: () => _removeItem(id),
                          onChanged: () => _debounceSave(),
                          onToggleSubtask: () => _toggleSubtask(id),
                          onAddSubtask: () => _addItem(parentId: id),
                          onToggleExpand: () {
                            setState(() {
                              if (isExpanded) {
                                _expandedItems.remove(id);
                              } else {
                                _expandedItems.add(id);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
            if (_itemControllers.isNotEmpty)
              _TaskListFooter(
                autoSort: _autoSort,
                checkedCount: checkedCount,
                totalCount: _itemControllers.length,
                onToggleAutoSort: () => setState(() => _autoSort = !_autoSort),
                onRemoveChecked: checkedCount > 0 ? _removeAllChecked : null,
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addItem,
          tooltip: 'Add item',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _TaskItemTile extends StatelessWidget {
  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isChecked;
  final bool isChild;
  final bool hasChildren;
  final bool isExpanded;
  final VoidCallback onToggleChecked;
  final VoidCallback onDelete;
  final VoidCallback onChanged;
  final VoidCallback onToggleSubtask;
  final VoidCallback onAddSubtask;
  final VoidCallback onToggleExpand;

  const _TaskItemTile({
    super.key,
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.isChecked,
    required this.isChild,
    required this.hasChildren,
    required this.isExpanded,
    required this.onToggleChecked,
    required this.onDelete,
    required this.onChanged,
    required this.onToggleSubtask,
    required this.onAddSubtask,
    required this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(left: isChild ? 40 : 8),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.drag_handle, color: Colors.grey),
            ),
          ),
          Checkbox(
            value: isChecked,
            onChanged: (_) => onToggleChecked(),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: (_) => onChanged(),
              decoration: InputDecoration(
                hintText: 'Task item',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              style: isChecked
                  ? theme.textTheme.bodyMedium?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    )
                  : null,
            ),
          ),
          if (hasChildren)
            IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 18),
              onPressed: onToggleExpand,
              tooltip: isExpanded ? 'Collapse subtasks' : 'Expand subtasks',
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
          IconButton(
            icon: const Icon(Icons.subdirectory_arrow_left, size: 18),
            onPressed: onToggleSubtask,
            tooltip: isChild ? 'Unindent' : 'Indent',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            icon: const Icon(Icons.add, size: 18),
            onPressed: onAddSubtask,
            tooltip: 'Add subtask',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onDelete,
            tooltip: 'Remove',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _TaskListFooter extends StatelessWidget {
  final bool autoSort;
  final int checkedCount;
  final int totalCount;
  final VoidCallback onToggleAutoSort;
  final VoidCallback? onRemoveChecked;

  const _TaskListFooter({
    required this.autoSort,
    required this.checkedCount,
    required this.totalCount,
    required this.onToggleAutoSort,
    this.onRemoveChecked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          Text(
            '$checkedCount / $totalCount done',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const Spacer(),
          if (onRemoveChecked != null)
            TextButton.icon(
              onPressed: onRemoveChecked,
              icon: const Icon(Icons.cleaning_services_outlined, size: 16),
              label: const Text('Remove checked'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                foregroundColor: theme.colorScheme.error,
              ),
            ),
          const SizedBox(width: 8),
          Text(
            'Auto-sort',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Switch(
            value: autoSort,
            onChanged: (_) => onToggleAutoSort(),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
