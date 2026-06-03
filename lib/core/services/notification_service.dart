import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:purenote/core/database/daos/note_dao.dart';
import 'package:purenote/core/routing/app_router.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _channelId = 'purenote_reminders';
  static const _channelName = 'Reminders';
  static const _channelDesc = 'Note reminder notifications';
  static bool _tzInitialized = false;
  static NoteDao? _dao;

  static Future<void> init({NoteDao? dao}) async {
    _dao = dao;
    if (!_tzInitialized) {
      tz_data.initializeTimeZones();
      _tzInitialized = true;
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDesc,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
    }
  }

  static Future<void> _onNotificationTap(NotificationResponse response) async {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;

    if (_dao != null) {
      final note = await _dao!.getById(payload);
      if (note == null) {
        final navCtx = rootNavigatorKey.currentContext;
        if (navCtx != null && navCtx.mounted) {
          ScaffoldMessenger.of(navCtx).showSnackBar(
            const SnackBar(content: Text('This note has been deleted')),
          );
        }
        return;
      }
    }

    rootNavigatorKey.currentState?.pushReplacementNamed('/note/$payload/view');
  }

  static Future<void> schedule(
    NoteDao dao,
    String noteId,
    String title,
    DateTime reminderAt,
  ) async {
    final now = DateTime.now();
    final delay = reminderAt.difference(now);
    if (delay.isNegative) return;

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      fullScreenIntent: true,
    );

    final tzScheduledDate = tz.TZDateTime.from(reminderAt, tz.local);
    await _plugin.zonedSchedule(
      noteId.hashCode,
      title.isNotEmpty ? title : 'Note reminder',
      'Tap to open your note',
      tzScheduledDate,
      NotificationDetails(android: androidDetails),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: noteId,
    );
  }

  static Future<void> cancel(String noteId) async {
    await _plugin.cancel(noteId.hashCode);
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> rescheduleAll(NoteDao dao) async {
    try {
      final notes = await dao.getAll();
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final note in notes) {
        if (note.reminderAt != null && note.reminderAt! > now) {
          await schedule(
            dao,
            note.id,
            note.title,
            DateTime.fromMillisecondsSinceEpoch(note.reminderAt!),
          );
        }
      }
    } catch (_) {}
  }
}
