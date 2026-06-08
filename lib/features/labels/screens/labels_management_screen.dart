import 'dart:async';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/error/result.dart';
import 'package:purenote/core/providers/database_provider.dart';
import 'package:purenote/features/labels/providers/labels_provider.dart';
import 'package:purenote/core/theme/app_colors.dart';
import 'package:purenote/l10n/app_localizations.dart';

class LabelsManagementScreen extends ConsumerWidget {
  const LabelsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelsAsync = ref.watch(labelsProvider);
    final theme = Theme.of(context);
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.labelsTitle)),
      body: labelsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (e, _) => Center(child: Text('Failed to load labels: $e')),
        data: (labels) {
          if (labels.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.label_outline, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.noLabelsYet, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => _createLabel(context, ref),
                    icon: const Icon(Icons.add),
                    label: Text(AppLocalizations.of(context)!.createLabel),
                  ),
                ],
              ),
            );
          }
          return ReorderableListView.builder(
            itemCount: labels.length,
            onReorder: (oldIndex, newIndex) {
              final ids = labels.map((l) => l.id).toList();
              final item = ids.removeAt(oldIndex);
              ids.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, item);
              unawaited(ref.read(labelDaoProvider).reorderLabels(ids));
            },
            buildDefaultDragHandles: false,
            itemBuilder: (context, index) {
              final label = labels[index];
              return ListTile(
                key: ValueKey(label.id),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ReorderableDragStartListener(
                      index: index,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(Icons.drag_handle, color: colors.textTertiary),
                      ),
                    ),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: label.color != null ? Color(label.color!) : theme.colorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.label, size: 16, color: Colors.white),
                    ),
                  ],
                ),
                title: Text(label.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: () => _deleteLabel(context, ref, label),
                  tooltip: AppLocalizations.of(context)!.delete,
                ),
                onTap: () => _renameLabel(context, ref, label),
              ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, duration: 300.ms);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          _createLabel(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _createLabel(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.newLabel),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.labelName,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(AppLocalizations.of(context)!.cancel)),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(AppLocalizations.of(context)!.create),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty) return;

    final dao = ref.read(labelDaoProvider);
    final id = const Uuid().v4();
    final result = await dao.insert(LabelsCompanion.insert(id: id, name: name.trim()));
    if (result case Err(:final error) when context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.userMessage)),
      );
    }
  }

  Future<void> _renameLabel(BuildContext context, WidgetRef ref, Label label) async {
    final controller = TextEditingController(text: label.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.renameLabel),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.labelName,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.of(ctx).pop(v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(AppLocalizations.of(context)!.cancel)),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: Text(AppLocalizations.of(context)!.rename),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty || name.trim() == label.name) return;

    final dao = ref.read(labelDaoProvider);
    final result = await dao.update(LabelsCompanion(id: Value(label.id), name: Value(name.trim())));
    if (result case Err(:final error) when context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.userMessage)),
      );
    }
  }

  Future<void> _deleteLabel(BuildContext context, WidgetRef ref, Label label) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteLabelTitle),
        content: Text(AppLocalizations.of(context)!.deleteLabelConfirm(label.name)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(AppLocalizations.of(context)!.cancel)),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final dao = ref.read(labelDaoProvider);
    final result = await dao.delete(label.id);
    if (result case Err(:final error) when context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.userMessage)),
      );
    }
  }
}
