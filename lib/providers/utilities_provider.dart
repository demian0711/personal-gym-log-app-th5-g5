import 'dart:async';

import 'package:flutter/foundation.dart';

import '../services/notification_service.dart';

class UtilitiesProvider extends ChangeNotifier {
  bool _autoRestTimerEnabled = true;
  int _restDurationSeconds = 90;
  int _remainingRestSeconds = 0;
  bool _workoutReminderEnabled = false;

  Timer? _restTimer;

  bool get autoRestTimerEnabled => _autoRestTimerEnabled;
  int get restDurationSeconds => _restDurationSeconds;
  int get remainingRestSeconds => _remainingRestSeconds;
  bool get isRestTimerRunning => _remainingRestSeconds > 0;
  bool get workoutReminderEnabled => _workoutReminderEnabled;

  void setAutoRestTimerEnabled(bool value) {
    _autoRestTimerEnabled = value;
    if (!value) {
      stopRestTimer();
      return;
    }
    notifyListeners();
  }

  void setRestDurationSeconds(int value) {
    _restDurationSeconds = value.clamp(15, 300);
    notifyListeners();
  }

  void startRestTimer() {
    if (!_autoRestTimerEnabled) return;

    _restTimer?.cancel();
    _remainingRestSeconds = _restDurationSeconds;
    notifyListeners();

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingRestSeconds <= 1) {
        timer.cancel();
        _remainingRestSeconds = 0;
        notifyListeners();
        NotificationService.instance.showRestTimerCompleted();
        return;
      }
      _remainingRestSeconds -= 1;
      notifyListeners();
    });
  }

  void stopRestTimer() {
    _restTimer?.cancel();
    _restTimer = null;
    _remainingRestSeconds = 0;
    notifyListeners();
  }

  double calculateOneRepMax(double weight, int reps) {
    if (weight <= 0 || reps <= 0) return 0;
    return weight * (1 + reps / 30);
  }

  Future<void> setWorkoutReminderEnabled(bool value) async {
    _workoutReminderEnabled = value;
    notifyListeners();
    await NotificationService.instance.setWorkoutReminderEnabled(value);
  }

  Future<void> sendTestNotification() {
    return NotificationService.instance.sendTestNotification();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }
}
