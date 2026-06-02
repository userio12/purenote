import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:purenote/core/providers/database_provider.dart';

part 'settings_provider.g.dart';

class AppSettings {
  final ThemeMode themeMode;
  final int viewMode; // 0=list, 1=grid
  final String sortBy; // 'title', 'created', 'modified'
  final bool sortAscending;
  final double textScale;
  final String? lockMethod; // null, 'biometric', 'pin'
  final int autoLockSeconds;
  final bool lockNewNotes;
  final bool autoBackup;
  final String backupInterval; // 'daily', 'weekly', 'monthly'
  final bool backupIncludeFiles;
  final bool backupPasswordProtected;
  final String widgetSource; // 'pinned', 'all'
  final int widgetMaxItems; // 3, 5, 10
  final String widgetTheme; // 'match', 'light', 'dark'

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.viewMode = 0,
    this.sortBy = 'modified',
    this.sortAscending = false,
    this.textScale = 1.0,
    this.lockMethod,
    this.autoLockSeconds = 60,
    this.lockNewNotes = false,
    this.autoBackup = false,
    this.backupInterval = 'daily',
    this.backupIncludeFiles = false,
    this.backupPasswordProtected = false,
    this.widgetSource = 'pinned',
    this.widgetMaxItems = 5,
    this.widgetTheme = 'match',
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    int? viewMode,
    String? sortBy,
    bool? sortAscending,
    double? textScale,
    String? lockMethod,
    int? autoLockSeconds,
    bool? lockNewNotes,
    bool? autoBackup,
    String? backupInterval,
    bool? backupIncludeFiles,
    bool? backupPasswordProtected,
    String? widgetSource,
    int? widgetMaxItems,
    String? widgetTheme,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      viewMode: viewMode ?? this.viewMode,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      textScale: textScale ?? this.textScale,
      lockMethod: lockMethod ?? this.lockMethod,
      autoLockSeconds: autoLockSeconds ?? this.autoLockSeconds,
      lockNewNotes: lockNewNotes ?? this.lockNewNotes,
      autoBackup: autoBackup ?? this.autoBackup,
      backupInterval: backupInterval ?? this.backupInterval,
      backupIncludeFiles: backupIncludeFiles ?? this.backupIncludeFiles,
      backupPasswordProtected: backupPasswordProtected ?? this.backupPasswordProtected,
      widgetSource: widgetSource ?? this.widgetSource,
      widgetMaxItems: widgetMaxItems ?? this.widgetMaxItems,
      widgetTheme: widgetTheme ?? this.widgetTheme,
    );
  }

  Map<String, String> toMap() => {
    'themeMode': themeMode.index.toString(),
    'viewMode': viewMode.toString(),
    'sortBy': sortBy,
    'sortAscending': sortAscending.toString(),
    'textScale': textScale.toString(),
    'lockMethod': lockMethod ?? '',
    'autoLockSeconds': autoLockSeconds.toString(),
    'lockNewNotes': lockNewNotes.toString(),
    'autoBackup': autoBackup.toString(),
    'backupInterval': backupInterval,
    'backupIncludeFiles': backupIncludeFiles.toString(),
    'backupPasswordProtected': backupPasswordProtected.toString(),
    'widgetSource': widgetSource,
    'widgetMaxItems': widgetMaxItems.toString(),
    'widgetTheme': widgetTheme,
  };

  factory AppSettings.fromMap(Map<String, String> map) {
    return AppSettings(
      themeMode: ThemeMode.values[int.tryParse(map['themeMode'] ?? '0') ?? 0],
      viewMode: int.tryParse(map['viewMode'] ?? '0') ?? 0,
      sortBy: map['sortBy'] ?? 'modified',
      sortAscending: map['sortAscending'] == 'true',
      textScale: double.tryParse(map['textScale'] ?? '1.0') ?? 1.0,
      lockMethod: map['lockMethod']?.isNotEmpty == true ? map['lockMethod'] : null,
      autoLockSeconds: int.tryParse(map['autoLockSeconds'] ?? '60') ?? 60,
      lockNewNotes: map['lockNewNotes'] == 'true',
      autoBackup: map['autoBackup'] == 'true',
      backupInterval: map['backupInterval'] ?? 'daily',
      backupIncludeFiles: map['backupIncludeFiles'] == 'true',
      backupPasswordProtected: map['backupPasswordProtected'] == 'true',
      widgetSource: map['widgetSource'] ?? 'pinned',
      widgetMaxItems: int.tryParse(map['widgetMaxItems'] ?? '5') ?? 5,
      widgetTheme: map['widgetTheme'] ?? 'match',
    );
  }
}

@Riverpod(keepAlive: true)
class SettingsNotifier extends _$SettingsNotifier {
  @override
  AppSettings build() {
    return const AppSettings();
  }

  Future<void> load() async {
    final dao = ref.read(settingsDaoProvider);
    final map = await dao.getAll();
    state = AppSettings.fromMap(map);
  }

  Future<void> update(AppSettings newSettings) async {
    final dao = ref.read(settingsDaoProvider);
    state = newSettings;
    for (final entry in newSettings.toMap().entries) {
      await dao.set(entry.key, entry.value);
    }
  }
}
