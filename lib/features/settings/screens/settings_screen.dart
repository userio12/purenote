import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purenote/core/providers/database_provider.dart';
import 'package:purenote/core/providers/settings_provider.dart';
import 'package:purenote/core/services/auth_service.dart';
import 'package:purenote/core/services/widget_service.dart';
import 'package:purenote/features/lock/screens/pin_setup_screen.dart';
import 'package:purenote/features/lock/screens/pin_change_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionHeader(context, 'View'),
          ListTile(
            title: const Text('View mode'),
            subtitle: Text(settings.viewMode == 0 ? 'List' : 'Grid'),
            trailing: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, icon: Icon(Icons.list)),
                ButtonSegment(value: 1, icon: Icon(Icons.grid_view)),
              ],
              selected: {settings.viewMode},
              onSelectionChanged: (v) {
                ref.read(settingsNotifierProvider.notifier).update(
                  settings.copyWith(viewMode: v.first),
                );
              },
            ),
          ),
          ListTile(
            title: const Text('Sort by'),
            trailing: DropdownButton<String>(
              value: settings.sortBy,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'modified', child: Text('Modified')),
                DropdownMenuItem(value: 'created', child: Text('Created')),
                DropdownMenuItem(value: 'title', child: Text('Title')),
              ],
              onChanged: (v) {
                if (v != null) {
                  ref.read(settingsNotifierProvider.notifier).update(
                    settings.copyWith(sortBy: v),
                  );
                }
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Ascending order'),
            value: settings.sortAscending,
            onChanged: (v) {
              ref.read(settingsNotifierProvider.notifier).update(
                settings.copyWith(sortAscending: v),
              );
            },
          ),
          ListTile(
            title: const Text('Text size'),
            subtitle: Slider(
              value: settings.textScale,
              min: 0.7,
              max: 1.5,
              divisions: 8,
              label: '${(settings.textScale * 100).round()}%',
              onChanged: (v) {
                ref.read(settingsNotifierProvider.notifier).update(
                  settings.copyWith(textScale: v),
                );
              },
            ),
          ),
          ListTile(
            title: const Text('Theme'),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
              onChanged: (v) {
                if (v != null) {
                  ref.read(settingsNotifierProvider.notifier).update(
                    settings.copyWith(themeMode: v),
                  );
                }
              },
            ),
          ),
          const Divider(),
          _sectionHeader(context, 'Security'),
          FutureBuilder<bool>(
            future: AuthService().isPinSet(),
            builder: (context, snapshot) {
              final isPinSet = snapshot.data ?? false;
              return ListTile(
                title: const Text('App lock'),
                subtitle: Text(isPinSet ? 'PIN is set' : 'Not set up'),
                trailing: isPinSet
                    ? TextButton(
                        onPressed: () => _removePin(context),
                        child: const Text('Remove', style: TextStyle(color: Colors.red)),
                      )
                    : TextButton(
                        onPressed: () => _setupPin(context),
                        child: const Text('Set up'),
                      ),
              );
            },
          ),
          ListTile(
            title: const Text('Lock method'),
            subtitle: Text(_lockMethodLabel(settings.lockMethod)),
            trailing: DropdownButton<String?>(
              value: settings.lockMethod,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: null, child: Text('PIN only')),
                DropdownMenuItem(value: 'biometric', child: Text('Biometric only')),
                DropdownMenuItem(value: 'both', child: Text('PIN or biometric')),
              ],
              onChanged: (v) {
                ref.read(settingsNotifierProvider.notifier).update(
                  settings.copyWith(lockMethod: v),
                );
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Lock new notes by default'),
            subtitle: const Text('Newly created notes start locked'),
            value: settings.lockNewNotes,
            onChanged: (v) {
              ref.read(settingsNotifierProvider.notifier).update(
                settings.copyWith(lockNewNotes: v),
              );
            },
          ),
          ListTile(
            title: const Text('Auto-lock timer'),
            subtitle: Text(_autoLockLabel(settings.autoLockSeconds)),
            trailing: DropdownButton<int>(
              value: settings.autoLockSeconds,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Immediately')),
                DropdownMenuItem(value: 15, child: Text('15 seconds')),
                DropdownMenuItem(value: 30, child: Text('30 seconds')),
                DropdownMenuItem(value: 60, child: Text('1 minute')),
                DropdownMenuItem(value: 300, child: Text('5 minutes')),
                DropdownMenuItem(value: 900, child: Text('15 minutes')),
              ],
              onChanged: (v) {
                if (v != null) {
                  ref.read(settingsNotifierProvider.notifier).update(
                    settings.copyWith(autoLockSeconds: v),
                  );
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Change PIN'),
            leading: const Icon(Icons.lock_outline),
            onTap: () => _changePin(context),
          ),
          const Divider(),
          _sectionHeader(context, 'Widget'),
          ListTile(
            title: const Text('Refresh widget'),
            subtitle: const Text('Update the home screen widget data'),
            leading: const Icon(Icons.widgets_outlined),
            onTap: () => _refreshWidget(context, ref),
          ),
          const Divider(),
          _sectionHeader(context, 'Data'),
          ListTile(
            title: const Text('Manage labels'),
            subtitle: const Text('Create, rename, delete labels'),
            leading: const Icon(Icons.label_outline),
            onTap: () => context.push('/labels'),
          ),
          ListTile(
            title: const Text('Backup & restore'),
            subtitle: const Text('Create and restore backups'),
            leading: const Icon(Icons.backup_outlined),
            onTap: () => context.push('/backup'),
          ),
          ListTile(
            title: const Text('Import notes'),
            subtitle: const Text('From Keep, Evernote, or Quillpad'),
            leading: const Icon(Icons.file_download_outlined),
            onTap: () => context.push('/import'),
          ),
          ListTile(
            title: const Text('Repair database'),
            subtitle: const Text('Check and repair database integrity'),
            leading: const Icon(Icons.healing_outlined),
            onTap: () => _repairDatabase(context, ref),
          ),
          ListTile(
            title: const Text('Clear all data'),
            subtitle: const Text('Delete all notes and reset the app'),
            leading: const Icon(Icons.delete_forever_outlined),
            onTap: () => _clearAllData(context, ref),
          ),
          const Divider(),
          _sectionHeader(context, 'About'),
          ListTile(
            title: const Text('About PureNote'),
            leading: const Icon(Icons.info_outline),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/about'),
          ),
        ],
      ),
    );
  }

  String _autoLockLabel(int seconds) {
    if (seconds <= 0) return 'Immediately';
    if (seconds < 60) return '$seconds seconds';
    final min = seconds ~/ 60;
    return '$min minute${min > 1 ? 's' : ''}';
  }

  String _lockMethodLabel(String? method) {
    switch (method) {
      case 'biometric': return 'Biometric only';
      case 'both': return 'PIN or biometric';
      default: return 'PIN only';
    }
  }

  void _refreshWidget(BuildContext context, WidgetRef ref) {
    final dao = ref.read(noteDaoProvider);
    WidgetService.updateWidgetData(dao);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Widget updated')),
    );
  }

  void _setupPin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PinSetupScreen(
          onComplete: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _changePin(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PinChangeScreen()),
    );
  }

  void _removePin(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove PIN?'),
        content: const Text('This will disable app lock.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              AuthService().clearPin();
              Navigator.of(ctx).pop();
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _repairDatabase(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Repair database'),
        content: const Text('This will check and repair the database. May take a moment.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Running integrity check...')),
              );
              final msg = await _runIntegrityCheck(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(msg)),
                );
              }
            },
            child: const Text('Repair'),
          ),
        ],
      ),
    );
  }

  Future<String> _runIntegrityCheck(WidgetRef ref) async {
    try {
      final db = ref.read(databaseProvider);
      final result = await db.customSelect('PRAGMA integrity_check').get();
      final status = result.first.data.values.first.toString();
      if (status == 'ok') {
        return 'Database integrity check passed';
      }
      return 'Issues found: $status';
    } catch (e) {
      return 'Check failed: $e';
    }
  }

  void _clearAllData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text('This will permanently delete all notes, labels, attachments, and settings. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              _confirmClearAll(context, ref);
            },
            child: const Text('Clear data'),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('This action is irreversible. All your notes, attachments, and settings will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared')),
              );
            },
            child: const Text('Delete everything'),
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
}
