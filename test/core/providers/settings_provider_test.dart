import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:purenote/core/providers/settings_provider.dart';

void main() {
  group('AppSettings', () {
    test('default values', () {
      const settings = AppSettings();
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.viewMode, 0);
      expect(settings.sortBy, 'modified');
      expect(settings.sortAscending, false);
      expect(settings.textScale, 1.0);
      expect(settings.lockMethod, isNull);
      expect(settings.autoLockSeconds, 60);
      expect(settings.lockNewNotes, false);
      expect(settings.autoBackup, false);
      expect(settings.backupInterval, 'daily');
      expect(settings.backupIncludeFiles, false);
      expect(settings.backupPasswordProtected, false);
      expect(settings.widgetSource, 'pinned');
      expect(settings.widgetMaxItems, 5);
      expect(settings.widgetTheme, 'match');
    });

    test('copyWith preserves unspecified fields', () {
      const settings = AppSettings(viewMode: 1, sortBy: 'title');
      final copy = settings.copyWith(themeMode: ThemeMode.dark);
      expect(copy.themeMode, ThemeMode.dark);
      expect(copy.viewMode, 1);
      expect(copy.sortBy, 'title');
    });

    test('toMap and fromMap roundtrip', () {
      const settings = AppSettings(
        themeMode: ThemeMode.dark,
        viewMode: 1,
        sortBy: 'created',
        sortAscending: true,
        textScale: 1.25,
        lockNewNotes: true,
        autoBackup: true,
        backupInterval: 'weekly',
      );

      final map = settings.toMap();
      final restored = AppSettings.fromMap(map);

      expect(restored.themeMode, settings.themeMode);
      expect(restored.viewMode, settings.viewMode);
      expect(restored.sortBy, settings.sortBy);
      expect(restored.sortAscending, settings.sortAscending);
      expect(restored.textScale, settings.textScale);
      expect(restored.lockNewNotes, settings.lockNewNotes);
      expect(restored.autoBackup, settings.autoBackup);
      expect(restored.backupInterval, settings.backupInterval);
      expect(restored.widgetSource, settings.widgetSource);
      expect(restored.widgetMaxItems, settings.widgetMaxItems);
      expect(restored.widgetTheme, settings.widgetTheme);
    });

    test('toMap handles null lockMethod', () {
      const settings = AppSettings();
      final map = settings.toMap();
      expect(map['lockMethod'], '');
    });

    test('fromMap handles empty string lockMethod', () {
      final map = <String, String>{'lockMethod': ''};
      final settings = AppSettings.fromMap(map);
      expect(settings.lockMethod, isNull);
    });

    test('SettingsNotifier default state', () {
      final notifier = _TestSettingsNotifier();
      final state = notifier.build();
      expect(state.viewMode, 0);
    });
  });
}

class _TestSettingsNotifier extends SettingsNotifier {
  @override
  AppSettings build() => const AppSettings();
}
