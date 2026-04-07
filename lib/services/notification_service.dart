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

  static const AndroidNotificationChannel _restChannel =
      AndroidNotificationChannel(
        'rest_timer_channel',
        'Rest Timer',
        description: 'Rest timer completion alerts',
        importance: Importance.high,
      );

  static const AndroidNotificationChannel _reminderChannel =
      AndroidNotificationChannel(
        'workout_reminder_channel',
        'Workout Reminder',
        description: 'Periodic workout reminders',
        importance: Importance.defaultImportance,
      );

  Future<void> initialize() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _plugin.initialize(settings: initializationSettings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();
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
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _restChannel.id,
        _restChannel.name,
        channelDescription: _restChannel.description,
        priority: Priority.high,
        importance: Importance.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: 5001,
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
    if (!enabled) {
      await _plugin.cancel(id: 5002);
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
      id: 5002,
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
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _reminderChannel.id,
        _reminderChannel.name,
        channelDescription: _reminderChannel.description,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.show(
      id: 5003,
      title: 'Personal Gym Log',
      body: 'Local notification is working.',
      notificationDetails: details,
    );
  }
}
