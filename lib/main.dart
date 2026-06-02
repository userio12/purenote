import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:purenote/core/error/global_error_handler.dart';
import 'package:purenote/core/routing/app_router.dart';
import 'package:purenote/core/services/attachment_service.dart';
import 'package:purenote/core/services/backup_service.dart';
import 'package:purenote/core/services/notification_service.dart';
import 'package:purenote/core/services/widget_service.dart';
import 'package:purenote/core/theme/app_theme.dart';
import 'package:purenote/core/database/database.dart';
import 'package:purenote/core/database/daos/note_dao.dart';
import 'package:purenote/core/providers/database_provider.dart';
import 'package:purenote/core/providers/settings_provider.dart';
import 'package:purenote/features/lock/providers/lock_state_provider.dart';
import 'package:purenote/features/lock/screens/pin_entry_screen.dart';

const _backupTaskName = 'purenote-backup';

@pragma('vm:entry-point')
void backupCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == _backupTaskName) {
      try {
        final db = AppDatabase.noDb();
        final service = BackupService(db);
        await service.createBackup(includeFiles: false);
        await db.close();
        return true;
      } catch (_) {
        return false;
      }
    }
    return true;
  });
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GlobalErrorHandler.init();

  await SentryFlutter.init(
    (options) {
      options.dsn = const String.fromEnvironment('SENTRY_DSN', defaultValue: '');
      options.tracesSampleRate = 0.0;
      options.enableNdkScopeSync = true;
    },
    appRunner: () async {
      final db = AppDatabase.noDb();
      final noteDao = NoteDao(db);
      await NotificationService.init(dao: noteDao);
      HomeWidget.registerInteractivityCallback(widgetBackgroundCallback);
      await Workmanager().initialize(backupCallbackDispatcher);
      await Workmanager().registerPeriodicTask(
        _backupTaskName,
        _backupTaskName,
        frequency: const Duration(hours: 24),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
      runApp(
        const ProviderScope(
          child: PurenoteApp(),
        ),
      );
    },
  );
}

class PurenoteApp extends ConsumerStatefulWidget {
  const PurenoteApp({super.key});

  @override
  ConsumerState<PurenoteApp> createState() => _PurenoteAppState();
}

class _PurenoteAppState extends ConsumerState<PurenoteApp> with WidgetsBindingObserver {
  StreamSubscription? _noteSubscription;
  Timer? _widgetDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() async {
      ref.read(settingsNotifierProvider.notifier).load();
      final dao = ref.read(noteDaoProvider);
      WidgetService.updateWidgetData(dao);

      _noteSubscription = dao.watchAll().listen((_) {
        _widgetDebounce?.cancel();
        _widgetDebounce = Timer(const Duration(seconds: 2), () {
          WidgetService.updateWidgetData(dao);
        });
      });

      final attachmentDao = ref.read(attachmentDaoProvider);
      final attachmentService = AttachmentService(attachmentDao);
      await attachmentService.cleanOrphans();
      await _clearTempDir();
    });
  }

  @override
  void dispose() {
    _noteSubscription?.cancel();
    _widgetDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(lockStateProvider.notifier).checkAndLock();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsNotifierProvider);
    final isLocked = ref.watch(lockStateProvider);

    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        MaterialApp.router(
          title: 'purenote',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          routerConfig: appRouter,
        ),
        if (isLocked)
          PinEntryScreen(
            onUnlock: () {
              ref.read(lockStateProvider.notifier).unlock();
            },
          ),
      ],
    );
  }

  Future<void> _clearTempDir() async {
    try {
      final tempDir = Directory.systemTemp;
      if (await tempDir.exists()) {
        final contents = await tempDir.list().toList();
        for (final entity in contents) {
          if (entity is File) {
            try { await entity.delete(); } catch (_) {}
          } else if (entity is Directory) {
            try { await entity.delete(recursive: true); } catch (_) {}
          }
        }
      }
    } catch (_) {}
  }
}
