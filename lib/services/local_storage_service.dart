import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../models/user_workout_data.dart';

class LocalStorageService {
  static const String _usersKey = 'auth_users';
  static const String _activeUserKey = 'auth_active_user_id';
  static const String _unitKey = 'unit_preference';
  static const String _workoutPrefix = 'workout_data_';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _instance {
    final prefs = _prefs;
    if (prefs == null) {
      throw StateError('LocalStorageService has not been initialized.');
    }
    return prefs;
  }

  Future<void> saveUnit(String unit) async {
    await _instance.setString(_unitKey, unit);
  }

  Future<String> getUnit() async {
    return _instance.getString(_unitKey) ?? 'kg';
  }

  Future<List<AppUser>> getUsers() async {
    final raw = _instance.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(AppUser.fromMap)
        .toList();
  }

  Future<void> saveUsers(List<AppUser> users) async {
    final payload = jsonEncode(users.map((user) => user.toMap()).toList());
    await _instance.setString(_usersKey, payload);
  }

  Future<String?> getActiveUserId() async {
    return _instance.getString(_activeUserKey);
  }

  Future<void> setActiveUserId(String? userId) async {
    if (userId == null) {
      await _instance.remove(_activeUserKey);
      return;
    }
    await _instance.setString(_activeUserKey, userId);
  }

  Future<UserWorkoutData?> getWorkoutData(String userId) async {
    final raw = _instance.getString('$_workoutPrefix$userId');
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return UserWorkoutData.fromMap(decoded);
  }

  Future<void> saveWorkoutData(String userId, UserWorkoutData data) async {
    final payload = jsonEncode(data.toMap());
    await _instance.setString('$_workoutPrefix$userId', payload);
  }

  Future<void> clearWorkoutData(String userId) async {
    await _instance.remove('$_workoutPrefix$userId');
  }
}
