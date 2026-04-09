import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _isTimezoneInitialized = false;
  static const int _restNotificationId = 5001;
  static const int _reminderNotificationId = 5002;
  static const int _testNotificationId = 5003;

  static final AndroidNotificationChannel _restChannel =
      AndroidNotificationChannel(
        'rest_timer_channel_v2',
        'Rest Timer',
        description: 'Rest timer completion alerts',
        importance: Importance.high,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 350, 200, 350]),
      );

  static const AndroidNotificationChannel _reminderChannel =
      AndroidNotificationChannel(
        'workout_reminder_channel',
        'Workout Reminder',
        description: 'Periodic workout reminders',
        importance: Importance.defaultImportance,
      );

  Future<void> initialize() async {
    if (kIsWeb) {
      return;
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(settings: initializationSettings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
    await androidPlugin?.createNotificationChannel(_restChannel);
    await androidPlugin?.createNotificationChannel(_reminderChannel);

    // Defer timezone initialization to prevent blocking main thread
    _initializeTimezone().ignore();
  }

  Future<void> _initializeTimezone() async {
    if (_isTimezoneInitialized) {
      return;
    }

    timezone_data.initializeTimeZones();
    try {
      final localTimezone = await FlutterTimezone.getLocalTimezone();
      timezone.setLocalLocation(timezone.getLocation(localTimezone));
    } catch (_) {
      timezone.setLocalLocation(timezone.UTC);
    }
    _isTimezoneInitialized = true;
  }

  Future<void> showRestTimerCompleted() async {
    if (kIsWeb) {
      return;
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _restChannel.id,
        _restChannel.name,
        channelDescription: _restChannel.description,
        priority: Priority.high,
        importance: Importance.high,
        category: AndroidNotificationCategory.alarm,
        enableVibration: true,
        playSound: true,
        vibrationPattern: Int64List.fromList([0, 350, 200, 350]),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      id: _restNotificationId,
      title: 'Rest completed',
      body: 'Start your next set now.',
      notificationDetails: details,
    );
  }

  Future<void> setWorkoutReminder({
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) {
      return;
    }

    if (!enabled) {
      await _plugin.cancel(id: _reminderNotificationId);
      return;
    }

    await _initializeTimezone();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _reminderChannel.id,
        _reminderChannel.name,
        channelDescription: _reminderChannel.description,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: _reminderNotificationId,
      title: 'Workout Reminder',
      body: 'Time to train and log your session.',
      scheduledDate: _nextDailyDate(hour: hour, minute: minute),
      notificationDetails: details,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  timezone.TZDateTime _nextDailyDate({required int hour, required int minute}) {
    final now = timezone.TZDateTime.now(timezone.local);
    var scheduled = timezone.TZDateTime(
      timezone.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }

  Future<void> sendTestNotification() async {
    if (kIsWeb) {
      return;
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _reminderChannel.id,
        _reminderChannel.name,
        channelDescription: _reminderChannel.description,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      id: _testNotificationId,
      title: 'Personal Gym Log',
      body: 'Local notification is working.',
      notificationDetails: details,
    );
  }
}
