import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

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

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.createNotificationChannel(_restChannel);
    await androidPlugin?.createNotificationChannel(_reminderChannel);
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

  Future<void> setWorkoutReminderEnabled(bool enabled) async {
    if (!enabled) {
      await _plugin.cancel(id: 5002);
      return;
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _reminderChannel.id,
        _reminderChannel.name,
        channelDescription: _reminderChannel.description,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.periodicallyShow(
      id: 5002,
      title: 'Workout Reminder',
      body: 'Time to train and log your session.',
      repeatInterval: RepeatInterval.hourly,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
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
