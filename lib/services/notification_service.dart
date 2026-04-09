import 'dart:typed_data';
import 'dart:math';

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
  final Random _random = Random();
  bool _isTimezoneInitialized = false;
  static const int _restNotificationId = 5001;
  static const int _reminderNotificationId = 5002;
  static const int _testNotificationId = 5003;
  static const List<_NotificationCopy> _restCopies = [
    _NotificationCopy(
      title: 'Nghỉ đủ rồi',
      body: 'Vào set tiếp theo thôi, cố hơn buổi trước một chút nhé.',
    ),
    _NotificationCopy(
      title: 'Đã đến lúc quay lại',
      body: 'Nhịp tập đang rất tốt, thêm một set chất lượng nữa nào.',
    ),
    _NotificationCopy(
      title: 'Sẵn sàng cho set mới',
      body: 'Tập trung thêm một chút, bạn đang làm rất ổn.',
    ),
  ];
  static const List<_NotificationCopy> _workoutReminderCopies = [
    _NotificationCopy(
      title: 'Đến giờ tập rồi',
      body: 'Hôm nay cố hơn buổi trước một chút nhé.',
    ),
    _NotificationCopy(
      title: 'Buổi tập đang chờ bạn',
      body: 'Chỉ cần bắt đầu, động lực sẽ theo sau.',
    ),
    _NotificationCopy(
      title: 'Giữ nhịp thói quen nào',
      body: 'Thêm một buổi tập nữa là thêm một bước tiến bộ.',
    ),
    _NotificationCopy(
      title: 'Hôm nay mình tập nhé',
      body: 'Không cần hoàn hảo, chỉ cần đều đặn và cố gắng hơn hôm qua.',
    ),
  ];
  static const List<_NotificationCopy> _testCopies = [
    _NotificationCopy(
      title: 'Sẵn sàng quay lại buổi tập',
      body: 'Thông báo đang hoạt động, giữ nhịp đều mỗi ngày nhé.',
    ),
    _NotificationCopy(
      title: 'Test thông báo thành công',
      body: 'Mọi thứ đã sẵn sàng để nhắc bạn vào giờ tập.',
    ),
  ];

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

    await _initializeTimezone();
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
    final copy = _pickCopy(_restCopies);

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
      title: copy.title,
      body: copy.body,
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
    final copy = _pickCopy(_workoutReminderCopies);

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
      title: copy.title,
      body: copy.body,
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
    final copy = _pickCopy(_testCopies);

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
      title: copy.title,
      body: copy.body,
      notificationDetails: details,
    );
  }

  _NotificationCopy _pickCopy(List<_NotificationCopy> copies) {
    if (copies.isEmpty) {
      return const _NotificationCopy(title: '', body: '');
    }
    return copies[_random.nextInt(copies.length)];
  }
}

class _NotificationCopy {
  final String title;
  final String body;

  const _NotificationCopy({
    required this.title,
    required this.body,
  });
}
