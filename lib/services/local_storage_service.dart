import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _workoutsBoxName = 'workouts';
  static const String _templatesBoxName = 'templates';
  static const String _settingsBoxName = 'settings';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_workoutsBoxName);
    await Hive.openBox(_templatesBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  // ==========================================
  // --- WORKOUT LOGS ---
  // ==========================================

  /// Add or update a workout log (CREATE / UPDATE)
  Future<void> saveWorkoutLog(Workout workout) async {
    final box = Hive.box(_workoutsBoxName);
    await box.put(workout.id, workout.toMap());
  }

  /// Read all workout logs (READ)
  Future<List<Workout>> getAllWorkoutLogs() async {
    final box = Hive.box(_workoutsBoxName);
    final List<Workout> logs = box.values
        .map((map) => Workout.fromMap(Map<String, dynamic>.from(map)))
        .toList();

    // Sort: newest workouts first
    logs.sort((a, b) => b.date.compareTo(a.date));
    return logs;
  }

  /// Delete a workout log (DELETE)
  Future<void> deleteWorkoutLog(String id) async {
    final box = Hive.box(_workoutsBoxName);
    await box.delete(id);
  }

  // ==========================================
  // --- WORKOUT TEMPLATES ---
  // ==========================================

  /// Add or update a workout template (CREATE / UPDATE)
  Future<void> saveTemplate(Workout template) async {
    final box = Hive.box(_templatesBoxName);
    await box.put(template.id, template.toMap());
  }

  /// Read all workout templates (READ)
  Future<List<Workout>> getAllTemplates() async {
    final box = Hive.box(_templatesBoxName);
    return box.values
        .map((map) => Workout.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  /// Delete a workout template (DELETE)
  Future<void> deleteTemplate(String id) async {
    final box = Hive.box(_templatesBoxName);
    await box.delete(id);
  }

  // ==========================================
  // --- SYSTEM SETTINGS ---
  // ==========================================

  /// Save weight unit (kg/lbs)
  Future<void> saveUnit(String unit) async {
    final box = Hive.box(_settingsBoxName);
    await box.put('unit', unit);
  }

  /// Read weight unit
  Future<String> getUnit() async {
    final box = Hive.box(_settingsBoxName);
    return box.get('unit', defaultValue: 'kg') as String;
  }
}
