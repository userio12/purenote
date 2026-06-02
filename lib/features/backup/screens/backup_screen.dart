import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:purenote/core/services/backup_service.dart';
import 'package:purenote/core/providers/database_provider.dart';
import 'package:purenote/core/providers/settings_provider.dart';
import 'package:purenote/features/backup/providers/backup_provider.dart';

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _creating = false;
  bool _restoring = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader(context, 'Auto-backup'),
          SwitchListTile(
            title: const Text('Auto backup'),
            subtitle: Text(settings.autoBackup ? 'Enabled (${settings.backupInterval})' : 'Disabled'),
            value: settings.autoBackup,
            onChanged: (v) {
              ref.read(settingsNotifierProvider.notifier).update(
                settings.copyWith(autoBackup: v),
              );
            },
          ),
          if (settings.autoBackup) ...[
            ListTile(
              title: const Text('Interval'),
              trailing: DropdownButton<String>(
                value: settings.backupInterval,
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                ],
                onChanged: (v) {
                  if (v != null) {
                    ref.read(settingsNotifierProvider.notifier).update(
                      settings.copyWith(backupInterval: v),
                    );
                  }
                },
              ),
            ),
            SwitchListTile(
              title: const Text('Include attachment files'),
              subtitle: const Text('Increases backup size'),
              value: settings.backupIncludeFiles,
              onChanged: (v) {
                ref.read(settingsNotifierProvider.notifier).update(
                  settings.copyWith(backupIncludeFiles: v),
                );
              },
            ),
          ],
          const Divider(),
          _sectionHeader(context, 'Manual backup'),
          SwitchListTile(
            title: const Text('Password protect backup'),
            subtitle: const Text('Enter a password when creating or restoring'),
            value: settings.backupPasswordProtected,
            onChanged: (v) {
              ref.read(settingsNotifierProvider.notifier).update(
                settings.copyWith(backupPasswordProtected: v),
              );
            },
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _creating ? null : _createBackup,
            icon: _creating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.backup),
            label: Text(_creating ? 'Creating...' : 'Back up now'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: _restoring ? null : _restoreBackup,
            icon: _restoring
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.restore),
            label: Text(_restoring ? 'Restoring...' : 'Restore from backup'),
          ),
          const Divider(),
          _sectionHeader(context, 'Backup history'),
          _BackupHistory(),
        ],
      ),
    );
  }

  Future<void> _createBackup() async {
    final settings = ref.read(settingsNotifierProvider);
    String? password;
    if (settings.backupPasswordProtected) {
      password = await _promptPassword(context, 'Set backup password');
      if (password == null) return;
    }

    setState(() => _creating = true);
    try {
      final db = ref.read(databaseProvider);
      final service = BackupService(db);
      await service.createBackup(
        includeFiles: settings.backupIncludeFiles,
        password: password?.isNotEmpty == true ? password : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _restoreBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['zip'],
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;

    setState(() => _restoring = true);
    try {
      final db = ref.read(databaseProvider);
      final settings = ref.read(settingsNotifierProvider);
      final service = BackupService(db);
      final data = await service.loadBackup(path);

      if (!mounted) return;

      String? password;
      if (data.passwordProtected) {
        password = await _promptPassword(context, 'Backup password');
        if (password == null) return;
      }

      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Restore backup?'),
          content: Text(
            'This will replace all current data.\n\n'
            '${data.noteCount} notes\n'
            '${data.attachmentCount} attachments\n'
            'Created: ${_formatDate(data.timestamp)}\n\n'
            'A pre-restore backup will be created first.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Restore'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      await service.createBackup(
        includeFiles: settings.backupIncludeFiles,
        password: password,
      );
      await service.restoreBackup(path, password: password);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restore completed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Future<String?> _promptPassword(BuildContext context, [String title = 'Backup password']) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Backup password'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Enter backup password',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _BackupHistory extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(backupHistoryProvider);
    final theme = Theme.of(context);

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Text('Failed to load history: $e'),
      data: (logs) {
        if (logs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No backups yet',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        }
        return Column(
          children: logs.map((log) => ListTile(
            dense: true,
            leading: Icon(
              log.status == 0 ? Icons.check_circle_outline : Icons.error_outline,
              color: log.status == 0 ? Colors.green : Colors.red,
            ),
            title: Text('Backup ${_formatEpoch(log.timestamp)}'),
            subtitle: log.fileSize != null
                ? Text('${(log.fileSize! / 1024).toStringAsFixed(1)} KB')
                : null,
          )).toList(),
        );
      },
    );
  }

  String _formatEpoch(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.month}/${dt.day}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
