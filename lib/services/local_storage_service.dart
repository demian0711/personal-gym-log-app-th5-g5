import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../models/user_workout_data.dart';
import '../models/workout.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _workoutsBoxName = 'workouts';
  static const String _templatesBoxName = 'templates';
  static const String _settingsBoxName = 'settings';

  static const String _usersKey = 'auth_users';
  static const String _activeUserKey = 'auth_active_user_id';
  static const String _unitKey = 'unit_preference';
  static const String _cloudinaryCloudNameKey = 'cloudinary_cloud_name';
  static const String _cloudinaryUploadPresetKey = 'cloudinary_upload_preset';
  static const String _reminderEnabledKey = 'workout_reminder_enabled';
  static const String _reminderHourKey = 'workout_reminder_hour';
  static const String _reminderMinuteKey = 'workout_reminder_minute';
  static const String _isDarkModeKey = 'theme_is_dark_mode';
  static const String _workoutPrefix = 'workout_data_';

  SharedPreferences? _prefs;
  Box? _workoutsBoxCached;
  Box? _templatesBoxCached;
  Box? _settingsBoxCached;

  Future<void> init() async {
    // Only initialize Hive and SharedPreferences - defer box opening until needed
    await Hive.initFlutter();
    _prefs = await SharedPreferences.getInstance();
  }

  // Lazy-load boxes on first access to reduce initialization time
  Future<Box> get _workoutsBox async {
    if (_workoutsBoxCached != null) return _workoutsBoxCached!;
    _workoutsBoxCached = await Hive.openBox(_workoutsBoxName);
    return _workoutsBoxCached!;
  }

  Future<Box> get _templatesBox async {
    if (_templatesBoxCached != null) return _templatesBoxCached!;
    _templatesBoxCached = await Hive.openBox(_templatesBoxName);
    return _templatesBoxCached!;
  }

  Future<Box> get _settingsBox async {
    if (_settingsBoxCached != null) return _settingsBoxCached!;
    _settingsBoxCached = await Hive.openBox(_settingsBoxName);
    return _settingsBoxCached!;
  }

  SharedPreferences get _prefsInstance {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('LocalStorageService has not been initialized.');
    }
    return prefs;
  }

  Future<void> saveWorkoutLog(Workout workout) async {
    final box = await _workoutsBox;
    await box.put(workout.id, workout.toMap());
  }

  Future<List<Workout>> getAllWorkoutLogs() async {
    final box = await _workoutsBox;
    final logs = box.values
        .map((map) => Workout.fromMap(Map<String, dynamic>.from(map)))
        .toList();
    logs.sort((a, b) => b.date.compareTo(a.date));
    return logs;
  }

  Future<void> deleteWorkoutLog(String id) async {
    final box = await _workoutsBox;
    await box.delete(id);
  }

  Future<void> saveTemplate(Workout template) async {
    final box = await _templatesBox;
    await box.put(template.id, template.toMap());
  }

  Future<List<Workout>> getAllTemplates() async {
    final box = await _templatesBox;
    return box.values
        .map((map) => Workout.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<void> deleteTemplate(String id) async {
    final box = await _templatesBox;
    await box.delete(id);
  }

  Future<void> saveUnit(String unit) async {
    final settingsBox = await _settingsBox;
    await settingsBox.put('unit', unit);
    await _prefsInstance.setString(_unitKey, unit);
  }

  Future<String> getUnit() async {
    final settingsBox = await _settingsBox;
    final fromHive = settingsBox.get('unit');
    if (fromHive is String && fromHive.isNotEmpty) {
      return fromHive;
    }
    return _prefsInstance.getString(_unitKey) ?? 'kg';
  }

  Future<List<AppUser>> getUsers() async {
    final raw = _prefsInstance.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>().map(AppUser.fromMap).toList();
  }

  Future<void> saveUsers(List<AppUser> users) async {
    final payload = jsonEncode(users.map((user) => user.toMap()).toList());
    await _prefsInstance.setString(_usersKey, payload);
  }

  Future<String?> getActiveUserId() async {
    return _prefsInstance.getString(_activeUserKey);
  }

  Future<void> setActiveUserId(String? userId) async {
    if (userId == null) {
      await _prefsInstance.remove(_activeUserKey);
      return;
    }
    await _prefsInstance.setString(_activeUserKey, userId);
  }

  Future<String?> getCloudinaryCloudName() async {
    return _prefsInstance.getString(_cloudinaryCloudNameKey);
  }

  Future<void> setCloudinaryCloudName(String value) async {
    await _prefsInstance.setString(_cloudinaryCloudNameKey, value.trim());
  }

  Future<String?> getCloudinaryUploadPreset() async {
    return _prefsInstance.getString(_cloudinaryUploadPresetKey);
  }

  Future<void> setCloudinaryUploadPreset(String value) async {
    await _prefsInstance.setString(_cloudinaryUploadPresetKey, value.trim());
  }

  Future<bool> getReminderEnabled() async {
    return _prefsInstance.getBool(_reminderEnabledKey) ?? false;
  }

  Future<void> setReminderEnabled(bool value) async {
    await _prefsInstance.setBool(_reminderEnabledKey, value);
  }

  Future<int> getReminderHour() async {
    return _prefsInstance.getInt(_reminderHourKey) ?? 19;
  }

  Future<void> setReminderHour(int value) async {
    await _prefsInstance.setInt(_reminderHourKey, value.clamp(0, 23));
  }

  Future<int> getReminderMinute() async {
    return _prefsInstance.getInt(_reminderMinuteKey) ?? 0;
  }

  Future<void> setReminderMinute(int value) async {
    await _prefsInstance.setInt(_reminderMinuteKey, value.clamp(0, 59));
  }

  Future<bool> getDarkModeEnabled() async {
    return _prefsInstance.getBool(_isDarkModeKey) ?? false;
  }

  Future<void> setDarkModeEnabled(bool value) async {
    await _prefsInstance.setBool(_isDarkModeKey, value);
  }

  Future<UserWorkoutData?> getWorkoutData(String userId) async {
    final raw = _prefsInstance.getString('$_workoutPrefix$userId');
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return UserWorkoutData.fromMap(decoded);
  }

  Future<void> saveWorkoutData(String userId, UserWorkoutData data) async {
    final payload = jsonEncode(data.toMap());
    await _prefsInstance.setString('$_workoutPrefix$userId', payload);
  }

  Future<void> clearWorkoutData(String userId) async {
    await _prefsInstance.remove('$_workoutPrefix$userId');
  }
}
