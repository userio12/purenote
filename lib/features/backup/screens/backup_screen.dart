import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:purenote/core/services/backup_service.dart';
import 'package:purenote/core/providers/database_provider.dart';
import 'package:purenote/core/providers/settings_provider.dart';
import 'package:purenote/features/backup/providers/backup_provider.dart';
import 'package:purenote/core/theme/app_colors.dart';
import 'package:purenote/l10n/app_localizations.dart';

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
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.backupAndRestoreTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader(context, AppLocalizations.of(context)!.autoBackupSection),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.autoBackup),
            subtitle: Text(settings.autoBackup ? AppLocalizations.of(context)!.autoBackupEnabled(settings.backupInterval) : AppLocalizations.of(context)!.autoBackupDisabled),
            value: settings.autoBackup,
            onChanged: (v) {
              ref.read(settingsNotifierProvider.notifier).update(
                settings.copyWith(autoBackup: v),
              );
            },
          ),
          if (settings.autoBackup) ...[
            ListTile(
              title: Text(AppLocalizations.of(context)!.backupInterval),
              trailing: DropdownButton<String>(
                value: settings.backupInterval,
                items: [
                  DropdownMenuItem(value: 'daily', child: Text(AppLocalizations.of(context)!.backupDaily)),
                  DropdownMenuItem(value: 'weekly', child: Text(AppLocalizations.of(context)!.backupWeekly)),
                  DropdownMenuItem(value: 'monthly', child: Text(AppLocalizations.of(context)!.backupMonthly)),
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
              title: Text(AppLocalizations.of(context)!.includeAttachmentFiles),
              subtitle: Text(AppLocalizations.of(context)!.includeAttachmentFilesSubtitle),
              value: settings.backupIncludeFiles,
              onChanged: (v) {
                ref.read(settingsNotifierProvider.notifier).update(
                  settings.copyWith(backupIncludeFiles: v),
                );
              },
            ),
          ],
          const Divider(),
          _sectionHeader(context, AppLocalizations.of(context)!.manualBackupSection),
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.passwordProtectBackup),
            subtitle: Text(AppLocalizations.of(context)!.passwordProtectBackupSubtitle),
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
            label: Text(_creating ? AppLocalizations.of(context)!.creating : AppLocalizations.of(context)!.backUpNow),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: _restoring ? null : _restoreBackup,
            icon: _restoring
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.restore),
            label: Text(_restoring ? AppLocalizations.of(context)!.restoring : AppLocalizations.of(context)!.restoreFromBackup),
          ),
          const Divider(),
          _sectionHeader(context, AppLocalizations.of(context)!.backupHistory),
          _BackupHistory(),
        ],
      ),
    );
  }

  Future<void> _createBackup() async {
    final settings = ref.read(settingsNotifierProvider);
    String? password;
    if (settings.backupPasswordProtected) {
      password = await _promptPassword(context, AppLocalizations.of(context)!.backupPassword);
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
          SnackBar(content: Text(AppLocalizations.of(context)!.backupSaved)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.backupFailed(e.toString()))),
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
        password = await _promptPassword(context, AppLocalizations.of(context)!.backupPassword);
        if (password == null) return;
      }

      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(AppLocalizations.of(context)!.restoreBackupConfirm),
          content: Text(
            'This will replace all current data.\n\n'
            '${data.noteCount} notes\n'
            '${data.attachmentCount} attachments\n'
            'Created: ${_formatDate(data.timestamp)}\n\n'
            'A pre-restore backup will be created first.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(AppLocalizations.of(context)!.cancel)),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(AppLocalizations.of(context)!.restore),
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
          SnackBar(content: Text(AppLocalizations.of(context)!.restoreCompleted)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.restoreFailed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  Future<String?> _promptPassword(BuildContext context, String title) {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.enterBackupPassword,
            border: const OutlineInputBorder(),
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
    final colors = Theme.of(context).extension<AppColors>()!;

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      error: (e, _) => Text(AppLocalizations.of(context)!.failedToLoadHistory(e.toString())),
      data: (logs) {
        if (logs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.noBackupsYet,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        }
        return Column(
          children: logs.asMap().entries.map((entry) {
            final index = entry.key;
            final log = entry.value;
            return ListTile(
              dense: true,
              leading: Icon(
                log.status == 0 ? Icons.check_circle_outline : Icons.error_outline,
                color: log.status == 0 ? colors.accentSuccess : colors.accentDanger,
              ),
              title: Text('Backup ${_formatEpoch(log.timestamp)}'),
              subtitle: log.fileSize != null
                  ? Text('${(log.fileSize! / 1024).toStringAsFixed(1)} KB')
                  : null,
            ).animate(delay: (index * 50).ms).fadeIn(duration: 300.ms).slideY(begin: 0.05, duration: 300.ms);
          }).toList(),
        );
      },
    );
  }

  String _formatEpoch(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.month}/${dt.day}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
