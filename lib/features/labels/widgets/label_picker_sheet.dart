import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/error/result.dart';
import 'package:purenote/core/providers/database_provider.dart';
import 'package:purenote/features/labels/providers/labels_provider.dart';
import 'package:purenote/l10n/app_localizations.dart';

Future<List<Label>?> showLabelPickerSheet(
  BuildContext context, {
  required List<Label> selected,
}) {
  return showModalBottomSheet<List<Label>>(
    context: context,
    builder: (_) => _LabelPickerSheet(selected: selected),
  );
}

class _LabelPickerSheet extends ConsumerStatefulWidget {
  final List<Label> selected;
  const _LabelPickerSheet({required this.selected});

  @override
  ConsumerState<_LabelPickerSheet> createState() => _LabelPickerSheetState();
}

class _LabelPickerSheetState extends ConsumerState<_LabelPickerSheet> {
  final _selectedIds = <String>{};
  final _newLabelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(widget.selected.map((l) => l.id));
  }

  @override
  void dispose() {
    _newLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labelsAsync = ref.watch(labelsProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.labelsTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newLabelController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.newLabelName,
                    isDense: true,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onSubmitted: (v) { _createLabel(v); },
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: () => _createLabel(_newLabelController.text),
                icon: const Icon(Icons.add, size: 18),
                label: Text(AppLocalizations.of(context)!.add),
              ),
            ],
          ),
          const SizedBox(height: 12),
          labelsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, _) => const Text('Failed to load labels'),
            data: (labels) {
              if (labels.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.noLabelsinYet,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                );
              }
              return Wrap(
                spacing: 8,
                runSpacing: 4,
                children: labels.map((label) {
                  final selected = _selectedIds.contains(label.id);
                  return FilterChip(
                    label: Text(label.name),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) { _selectedIds.add(label.id); }
                        else { _selectedIds.remove(label.id); }
                      });
                    },
                    selectedColor: label.color != null
                        ? Color(label.color!).withValues(alpha: 0.2)
                        : null,
                    side: label.color != null
                        ? BorderSide(color: Color(label.color!).withValues(alpha: 0.5))
                        : null,
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final allLabels = (labelsAsync.asData?.value) ?? <Label>[];
                final selectedLabels = allLabels.where((l) => _selectedIds.contains(l.id)).toList();
                Navigator.of(context).pop(selectedLabels);
              },
              child: Text(AppLocalizations.of(context)!.apply),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createLabel(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final dao = ref.read(labelDaoProvider);
    final id = const Uuid().v4();
    final result = await dao.insert(LabelsCompanion.insert(id: id, name: trimmed));
    if (result is Ok) {
      _newLabelController.clear();
      setState(() => _selectedIds.add(id));
      ref.invalidate(labelsProvider);
    }
  }
}
