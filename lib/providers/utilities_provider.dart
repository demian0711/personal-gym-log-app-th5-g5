import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/workout.dart';
import '../services/notification_service.dart';
import '../services/local_storage_service.dart';
import '../services/one_rm_service.dart';

class UtilitiesProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final OneRmService _oneRmService = const OneRmService();

  bool _autoRestTimerEnabled = true;
  int _restDurationSeconds = 90;
  int _remainingRestSeconds = 0;
  bool _workoutReminderEnabled = false;
  TimeOfDay _workoutReminderTime = const TimeOfDay(hour: 19, minute: 0);

  Timer? _restTimer;

  bool get autoRestTimerEnabled => _autoRestTimerEnabled;
  int get restDurationSeconds => _restDurationSeconds;
  int get remainingRestSeconds => _remainingRestSeconds;
  bool get isRestTimerRunning => _remainingRestSeconds > 0;
  bool get workoutReminderEnabled => _workoutReminderEnabled;
  TimeOfDay get workoutReminderTime => _workoutReminderTime;

  UtilitiesProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _autoRestTimerEnabled = await _storage.getAutoRestTimerEnabled();
    _restDurationSeconds = await _storage.getRestDurationSeconds();
    _workoutReminderEnabled = await _storage.getReminderEnabled();
    final hour = await _storage.getReminderHour();
    final minute = await _storage.getReminderMinute();
    _workoutReminderTime = TimeOfDay(hour: hour, minute: minute);
    notifyListeners();

    if (_workoutReminderEnabled) {
      await NotificationService.instance.setWorkoutReminder(
        enabled: true,
        hour: _workoutReminderTime.hour,
        minute: _workoutReminderTime.minute,
      );
    }
  }

  void setAutoRestTimerEnabled(bool value) {
    _autoRestTimerEnabled = value;
    unawaited(_storage.setAutoRestTimerEnabled(value));
    if (!value) {
      stopRestTimer();
      return;
    }
    notifyListeners();
  }

  void setRestDurationSeconds(int value) {
    _restDurationSeconds = value.clamp(15, 300);
    unawaited(_storage.setRestDurationSeconds(_restDurationSeconds));
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
        _restTimer = null;
        _remainingRestSeconds = 0;
        notifyListeners();
        unawaited(NotificationService.instance.showRestTimerCompleted());
        unawaited(_triggerRestCompletedFeedback());
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
    return _oneRmService.calculateOneRm(weight: weight, reps: reps);
  }

  double calculateRecommendedTrainingWeight(double oneRm, int targetReps) {
    final raw = _oneRmService.calculateTrainingWeight(
      oneRm: oneRm,
      targetReps: targetReps,
    );
    return _oneRmService.roundLoad(raw);
  }

  List<SmartOneRmSuggestion> buildSmartOneRmSuggestions(
    List<Workout> history, {
    int targetReps = 8,
    int maxItems = 6,
  }) {
    return _oneRmService.buildSmartSuggestions(
      history,
      targetReps: targetReps,
      maxItems: maxItems,
    );
  }

  SmartOneRmSuggestion? buildExerciseOneRmSuggestion(
    List<Workout> history,
    String exerciseName, {
    int targetReps = 8,
  }) {
    return _oneRmService.buildExerciseSuggestion(
      history,
      exerciseName,
      targetReps: targetReps,
    );
  }

  Future<void> setWorkoutReminderEnabled(bool value) async {
    _workoutReminderEnabled = value;
    notifyListeners();
    await _storage.setReminderEnabled(value);
    await NotificationService.instance.setWorkoutReminder(
      enabled: value,
      hour: _workoutReminderTime.hour,
      minute: _workoutReminderTime.minute,
    );
  }

  Future<void> setWorkoutReminderTime(TimeOfDay time) async {
    _workoutReminderTime = time;
    notifyListeners();

    await _storage.setReminderHour(time.hour);
    await _storage.setReminderMinute(time.minute);

    if (_workoutReminderEnabled) {
      await NotificationService.instance.setWorkoutReminder(
        enabled: true,
        hour: time.hour,
        minute: time.minute,
      );
    }
  }

  Future<void> sendTestNotification() {
    return NotificationService.instance.sendTestNotification();
  }

  Future<void> _triggerRestCompletedFeedback() async {
    if (kIsWeb) {
      return;
    }

    try {
      await HapticFeedback.vibrate();
    } catch (_) {}
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }
}
