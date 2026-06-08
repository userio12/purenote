import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:purenote/core/providers/database_provider.dart';
import 'package:purenote/core/providers/settings_provider.dart';
import 'package:purenote/core/services/auth_service.dart';
import 'package:purenote/core/services/backup_service.dart';
import 'package:purenote/core/services/widget_service.dart';
import 'package:purenote/core/theme/app_colors.dart';
import 'package:purenote/core/theme/app_spacing.dart';
import 'package:purenote/core/theme/app_shapes.dart';
import 'package:purenote/features/lock/screens/pin_setup_screen.dart';
import 'package:purenote/features/lock/screens/pin_change_screen.dart';
import 'package:purenote/features/labels/widgets/label_picker_sheet.dart';
import 'package:purenote/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).extension<AppColors>()!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _buildSectionHeader(l10n.sectionView, colors),
          Card(
            color: colors.surfaceElevated,
            shape: RoundedRectangleBorder(borderRadius: AppShapes.md),
            child: Column(
              children: [
                ListTile(
                  title: Text(l10n.viewMode),
                  subtitle: Text(
                    settings.viewMode == 0 ? l10n.list : l10n.grid,
                  ),
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
                const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                ListTile(
                  title: Text(l10n.sortBy),
                  trailing: DropdownButton<String>(
                    value: settings.sortBy,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(value: 'modified', child: Text(l10n.sortModified)),
                      DropdownMenuItem(value: 'created', child: Text(l10n.sortCreated)),
                      DropdownMenuItem(value: 'title', child: Text(l10n.sortTitle)),
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
                const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                SwitchListTile(
                  title: Text(l10n.ascendingOrder),
                  value: settings.sortAscending,
                  onChanged: (v) {
                    ref.read(settingsNotifierProvider.notifier).update(
                      settings.copyWith(sortAscending: v),
                    );
                  },
                ),
                const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                ListTile(
                  title: Text(l10n.textSize),
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
                const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                ListTile(
                  title: Text(l10n.theme),
                  trailing: DropdownButton<ThemeMode>(
                    value: settings.themeMode,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(value: ThemeMode.system, child: Text(l10n.themeSystem)),
                      DropdownMenuItem(value: ThemeMode.light, child: Text(l10n.themeLight)),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n.themeDark)),
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
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader(l10n.sectionSecurity, colors),
          Card(
            color: colors.surfaceElevated,
            shape: RoundedRectangleBorder(borderRadius: AppShapes.md),
            child: Column(
              children: [
                FutureBuilder<bool>(
                  future: AuthService().isPinSet(),
                  builder: (context, snapshot) {
                    final isPinSet = snapshot.data ?? false;
                    return ListTile(
                      title: Text(l10n.appLock),
                      subtitle: Text(isPinSet ? l10n.pinIsSet : l10n.notSetUp),
                      trailing: isPinSet
                          ? TextButton(
                              onPressed: () => _removePin(context),
                              child: Text(l10n.remove, style: TextStyle(color: colors.accentDanger)),
                            )
                          : TextButton(
                              onPressed: () => _setupPin(context),
                              child: Text(l10n.setup),
                            ),
                    );
                  },
                ),
                const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                ListTile(
                  title: Text(l10n.lockMethod),
                  subtitle: Text(_lockMethodLabel(context, settings.lockMethod)),
                  trailing: DropdownButton<String?>(
                    value: settings.lockMethod,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(value: null, child: Text(l10n.lockMethodPinOnly)),
                      DropdownMenuItem(value: 'biometric', child: Text(l10n.lockMethodBiometricOnly)),
                      DropdownMenuItem(value: 'both', child: Text(l10n.lockMethodBoth)),
                    ],
                    onChanged: (v) {
                      ref.read(settingsNotifierProvider.notifier).update(
                        settings.copyWith(lockMethod: v),
                      );
                    },
                  ),
                ),
                const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                SwitchListTile(
                  title: Text(l10n.lockNewNotes),
                  subtitle: Text(l10n.lockNewNotesSubtitle),
                  value: settings.lockNewNotes,
                  onChanged: (v) {
                    ref.read(settingsNotifierProvider.notifier).update(
                      settings.copyWith(lockNewNotes: v),
                    );
                  },
                ),
                const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                ListTile(
                  title: Text(l10n.autoLockTimer),
                  subtitle: Text(_autoLockLabel(context, settings.autoLockSeconds)),
                  trailing: DropdownButton<int>(
                    value: settings.autoLockSeconds,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(value: 0, child: Text(l10n.autoLockImmediately)),
                      DropdownMenuItem(value: 15, child: Text(l10n.autoLock15Seconds)),
                      DropdownMenuItem(value: 30, child: Text(l10n.autoLock30Seconds)),
                      DropdownMenuItem(value: 60, child: Text(l10n.autoLock1Minute)),
                      DropdownMenuItem(value: 300, child: Text(l10n.autoLock5Minutes)),
                      DropdownMenuItem(value: 900, child: Text(l10n.autoLock15Minutes)),
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
                const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                ListTile(
                  title: Text(l10n.changePin),
                  leading: const Icon(Icons.lock_outline),
                  onTap: () => _changePin(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader(l10n.sectionWidget, colors),
          Card(
            color: colors.surfaceElevated,
            shape: RoundedRectangleBorder(borderRadius: AppShapes.md),
            child: Column(
              children: [
                ListTile(
                  title: Text(l10n.widgetSource),
                  subtitle: Text(
                    settings.widgetSource == 'pinned'
                        ? l10n.widgetPinnedNotes
                        : settings.widgetSource == 'label'
                            ? l10n.widgetSpecificLabel
                            : l10n.widgetAllNotes,
                  ),
                  trailing: DropdownButton<String>(
                    value: settings.widgetSource,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(value: 'pinned', child: Text(l10n.widgetPinnedNotes)),
                      DropdownMenuItem(value: 'all', child: Text(l10n.widgetAllNotes)),
                      DropdownMenuItem(value: 'label', child: Text(l10n.widgetSpecificLabel)),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(settingsNotifierProvider.notifier).update(
                          settings.copyWith(
                            widgetSource: v,
                            widgetLabel: v == 'label' ? settings.widgetLabel : null,
                          ),
                        );
                      }
                    },
                  ),
                ),
                if (settings.widgetSource == 'label') ...[
                  const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                  ListTile(
                    title: Text(l10n.widgetLabel),
                    subtitle: Text(settings.widgetLabel ?? 'Select a label'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final dao = ref.read(labelDaoProvider);
                      final allLabels = await dao.watchAll().first;
                      if (!context.mounted) return;
                      final result = await showLabelPickerSheet(
                        context,
                        selected: allLabels.where((l) => l.id == settings.widgetLabel).toList(),
                      );
                      if (result != null && result.isNotEmpty) {
                        ref.read(settingsNotifierProvider.notifier).update(
                          settings.copyWith(widgetLabel: result.first.id),
                        );
                      }
                    },
                  ),
                ],
                const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                ListTile(
                  title: Text(l10n.widgetMaxItems),
                  trailing: DropdownButton<int>(
                    value: settings.widgetMaxItems,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 3, child: Text('3')),
                      DropdownMenuItem(value: 5, child: Text('5')),
                      DropdownMenuItem(value: 10, child: Text('10')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(settingsNotifierProvider.notifier).update(
                          settings.copyWith(widgetMaxItems: v),
                        );
                      }
                    },
                  ),
                ),
                const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                ListTile(
                  title: Text(l10n.widgetTheme),
                  trailing: DropdownButton<String>(
                    value: settings.widgetTheme,
                    underline: const SizedBox(),
                    items: [
                      DropdownMenuItem(value: 'match', child: Text(l10n.matchApp)),
                      DropdownMenuItem(value: 'light', child: Text(l10n.themeLight)),
                      DropdownMenuItem(value: 'dark', child: Text(l10n.themeDark)),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        ref.read(settingsNotifierProvider.notifier).update(
                          settings.copyWith(widgetTheme: v),
                        );
                      }
                    },
                  ),
                ),
                const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                ListTile(
                  title: Text(l10n.refreshWidget),
                  subtitle: Text(l10n.refreshWidgetSubtitle),
                  leading: const Icon(Icons.widgets_outlined),
                  onTap: () => _refreshWidget(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader(l10n.sectionData, colors),
          Card(
            color: colors.surfaceElevated,
            shape: RoundedRectangleBorder(borderRadius: AppShapes.md),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(l10n.autoBackup),
                  subtitle: Text(l10n.autoBackupSubtitle),
                  value: settings.autoBackup,
                  onChanged: (v) async {
                    ref.read(settingsNotifierProvider.notifier).update(
                      settings.copyWith(autoBackup: v),
                    );
                    await BackupService.rescheduleBackup(
                      autoBackup: v,
                      interval: settings.backupInterval,
                    );
                  },
                ),
                if (settings.autoBackup) ...[
                  const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                  ListTile(
                    title: Text(l10n.backupInterval),
                    trailing: DropdownButton<String>(
                      value: settings.backupInterval,
                      underline: const SizedBox(),
                      items: [
                        DropdownMenuItem(value: 'daily', child: Text(l10n.backupDaily)),
                        DropdownMenuItem(value: 'weekly', child: Text(l10n.backupWeekly)),
                        DropdownMenuItem(value: 'monthly', child: Text(l10n.backupMonthly)),
                      ],
                      onChanged: (v) async {
                        if (v != null) {
                          ref.read(settingsNotifierProvider.notifier).update(
                            settings.copyWith(backupInterval: v),
                          );
                          await BackupService.rescheduleBackup(
                            autoBackup: true,
                            interval: v,
                          );
                        }
                      },
                    ),
                  ),
                ],
                const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                ListTile(
                  title: Text(l10n.manageLabels),
                  subtitle: Text(l10n.manageLabelsSubtitle),
                  leading: const Icon(Icons.label_outline),
                  onTap: () => context.push('/labels'),
                ),
                const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                ListTile(
                  title: Text(l10n.backupAndRestore),
                  subtitle: Text(l10n.backupAndRestoreSubtitle),
                  leading: const Icon(Icons.backup_outlined),
                  onTap: () => context.push('/backup'),
                ),
                const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                ListTile(
                  title: Text(l10n.importNotes),
                  subtitle: Text(l10n.importNotesSubtitle),
                  leading: const Icon(Icons.file_download_outlined),
                  onTap: () => context.push('/import'),
                ),
                const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                ListTile(
                  title: Text(l10n.repairDatabase),
                  subtitle: Text(l10n.repairDatabaseSubtitle),
                  leading: const Icon(Icons.healing_outlined),
                  onTap: () => _repairDatabase(context, ref),
                ),
                const Divider(height: 1, indent: AppSpacing.lg, endIndent: AppSpacing.lg),
                ListTile(
                  title: Text(l10n.clearAllData),
                  subtitle: Text(l10n.clearAllDataSubtitle),
                  leading: const Icon(Icons.delete_forever_outlined),
                  onTap: () => _clearAllData(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildSectionHeader(l10n.aboutSection, colors),
          Card(
            color: colors.surfaceElevated,
            shape: RoundedRectangleBorder(borderRadius: AppShapes.md),
            child: ListTile(
              title: Text(l10n.aboutPureNote),
              leading: const Icon(Icons.info_outline),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/about'),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colors.textSecondary,
        ),
      ),
    );
  }

  String _autoLockLabel(BuildContext context, int seconds) {
    final l10n = AppLocalizations.of(context)!;
    switch (seconds) {
      case 0: return l10n.autoLockImmediately;
      case 15: return l10n.autoLock15Seconds;
      case 30: return l10n.autoLock30Seconds;
      case 60: return l10n.autoLock1Minute;
      case 300: return l10n.autoLock5Minutes;
      case 900: return l10n.autoLock15Minutes;
      default: return l10n.autoLockImmediately;
    }
  }

  String _lockMethodLabel(BuildContext context, String? method) {
    final l10n = AppLocalizations.of(context)!;
    switch (method) {
      case 'biometric': return l10n.lockMethodBiometricOnly;
      case 'both': return l10n.lockMethodBoth;
      default: return l10n.lockMethodPinOnly;
    }
  }

  void _refreshWidget(BuildContext context, WidgetRef ref) {
    final noteDao = ref.read(noteDaoProvider);
    final labelDao = ref.read(labelDaoProvider);
    final settings = ref.read(settingsNotifierProvider);
    WidgetService.updateWidgetData(
      noteDao,
      labelDao: labelDao,
      widgetSource: settings.widgetSource,
      widgetMaxItems: settings.widgetMaxItems,
      widgetTheme: settings.widgetTheme,
      widgetLabel: settings.widgetLabel,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.widgetUpdated)),
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.removePin),
        content: Text(l10n.removePinContent),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              AuthService().clearPin();
              Navigator.of(ctx).pop();
            },
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
  }

  void _repairDatabase(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.repairDatabaseTitle),
        content: Text(l10n.repairDatabaseContent),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.runningIntegrityCheck)),
              );
              final msg = await _runIntegrityCheck(context, ref);
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

  Future<String> _runIntegrityCheck(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final db = ref.read(databaseProvider);
      final result = await db.customSelect('PRAGMA integrity_check').get();
      final status = result.first.data.values.first.toString();
      if (status == 'ok') {
        return l10n.integrityCheckPassed;
      }
      return l10n.integrityCheckIssues(status);
    } catch (e) {
      return l10n.integrityCheckFailed(e);
    }
  }

  void _clearAllData(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearAllDataTitle),
        content: Text(l10n.clearAllDataContent),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              _confirmClearAll(context, ref);
            },
            child: Text(l10n.clearDataButton),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.areYouSure),
        content: Text(l10n.areYouSureContent),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(l10n.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final db = ref.read(databaseProvider);
                await db.delete(db.settings).go();
                await db.delete(db.backupLog).go();
                await db.delete(db.noteLabels).go();
                await db.delete(db.attachments).go();
                await db.delete(db.taskItems).go();
                await db.delete(db.notes).go();
                await db.delete(db.labels).go();
                final appDir = await getApplicationDocumentsDirectory();
                for (final dirName in ['attachments', 'temp']) {
                  final dir = Directory(p.join(appDir.path, dirName));
                  if (await dir.exists()) await dir.delete(recursive: true);
                  await dir.create();
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.allDataCleared)));
                  ref.invalidate(databaseProvider);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.failedToClearData(e))));
                }
              }
            },
            child: Text(l10n.deleteEverything),
          ),
        ],
      ),
    );
  }
}
