import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../models/user_workout_data.dart';
import '../models/workout.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  final FirebaseService _firebase = FirebaseService();

  List<Workout> _templates = [];
  List<Workout> _history = [];
  String? _userId;
  bool _isLoading = false;
  bool _isSyncing = false;

  WorkoutProvider(this._storage);

  List<Workout> get templates => List.unmodifiable(_templates);
  List<Workout> get history => List.unmodifiable(_history);
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;

  void bindUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    if (userId != null) {
      _firebase.setUserId(userId);
    }
    unawaited(_loadForUser(userId));
  }

  Future<void> addTemplate(Workout template) async {
    _templates.add(template);
    await _storage.saveTemplate(template);
    try {
      await _firebase.uploadTemplate(template);
    } catch (_) {}
    notifyListeners();
    unawaited(_persist());
  }

  Future<void> updateTemplate(Workout template) async {
    final index = _templates.indexWhere((item) => item.id == template.id);
    if (index == -1) return;
    _templates[index] = template;
    await _storage.saveTemplate(template);
    try {
      await _firebase.uploadTemplate(template);
    } catch (_) {}
    notifyListeners();
    unawaited(_persist());
  }

  Future<void> removeTemplate(String id) async {
    _templates.removeWhere((template) => template.id == id);
    await _storage.deleteTemplate(id);
    try {
      await _firebase.deleteTemplate(id);
    } catch (_) {}
    notifyListeners();
    unawaited(_persist());
  }

  Future<void> addWorkoutLog(Workout workout) async {
    _history.insert(0, workout);
    await _storage.saveWorkoutLog(workout);
    try {
      await _firebase.uploadWorkoutLog(workout);
    } catch (_) {}
    notifyListeners();
    unawaited(_persist());
  }

  Future<void> clearAll() async {
    for (final template in _templates) {
      await _storage.deleteTemplate(template.id);
    }
    for (final workout in _history) {
      await _storage.deleteWorkoutLog(workout.id);
    }
    _templates.clear();
    _history.clear();
    notifyListeners();

    final userId = _userId;
    if (userId != null) {
      await _storage.clearWorkoutData(userId);
    }
  }

  Future<void> syncFromFirebase() async {
    if (_userId == null) return;
    _isSyncing = true;
    notifyListeners();

    try {
      _templates = await _firebase.downloadTemplates();
      _history = await _firebase.downloadWorkoutLogs();
      await _persist();
    } catch (_) {
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> syncToFirebase() async {
    if (_userId == null) return;
    _isSyncing = true;
    notifyListeners();

    try {
      await _firebase.syncAllToFirebase(_templates, _history);
    } catch (_) {
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<void> _loadForUser(String? userId) async {
    _isLoading = true;
    notifyListeners();

    _templates = [];
    _history = [];

    if (userId != null) {
      final data = await _storage.getWorkoutData(userId);
      if (data != null) {
        _templates = data.templates;
        _history = data.history;
      } else {
        _seedTemplates();
        await _persist();
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    final userId = _userId;
    if (userId == null) return;
    final data = UserWorkoutData(
      templates: _templates,
      history: _history,
    );
    await _storage.saveWorkoutData(userId, data);
  }

  void _seedTemplates() {
    if (_templates.isNotEmpty) return;
    final now = DateTime.now();

    _templates.addAll([
      Workout(
        id: 'seed_push',
        title: 'Push Day',
        date: now,
        exercises: [
          Exercise(
            id: 'seed_push_bench',
            name: 'Bench Press',
            muscleGroup: 'Chest',
            sets: _defaultSets(4),
          ),
          Exercise(
            id: 'seed_push_ohp',
            name: 'Overhead Press',
            muscleGroup: 'Shoulders',
            sets: _defaultSets(3),
          ),
          Exercise(
            id: 'seed_push_tricep',
            name: 'Triceps Pushdown',
            muscleGroup: 'Triceps',
            sets: _defaultSets(3),
          ),
        ],
      ),
      Workout(
        id: 'seed_pull',
        title: 'Pull Day',
        date: now,
        exercises: [
          Exercise(
            id: 'seed_pull_deadlift',
            name: 'Deadlift',
            muscleGroup: 'Back',
            sets: _defaultSets(3),
          ),
          Exercise(
            id: 'seed_pull_row',
            name: 'Bent-over Row',
            muscleGroup: 'Back',
            sets: _defaultSets(3),
          ),
          Exercise(
            id: 'seed_pull_biceps',
            name: 'Biceps Curl',
            muscleGroup: 'Biceps',
            sets: _defaultSets(3),
          ),
        ],
      ),
      Workout(
        id: 'seed_legs',
        title: 'Legs Day',
        date: now,
        exercises: [
          Exercise(
            id: 'seed_legs_squat',
            name: 'Back Squat',
            muscleGroup: 'Legs',
            sets: _defaultSets(4),
          ),
          Exercise(
            id: 'seed_legs_lunge',
            name: 'Walking Lunges',
            muscleGroup: 'Legs',
            sets: _defaultSets(3),
          ),
          Exercise(
            id: 'seed_legs_calf',
            name: 'Calf Raise',
            muscleGroup: 'Calves',
            sets: _defaultSets(3),
          ),
        ],
      ),
      Workout(
        id: 'seed_upper',
        title: 'Upper Body',
        date: now,
        exercises: [
          Exercise(
            id: 'seed_upper_pullup',
            name: 'Pull Up',
            muscleGroup: 'Back',
            sets: _defaultSets(3),
          ),
          Exercise(
            id: 'seed_upper_incline',
            name: 'Incline Dumbbell Press',
            muscleGroup: 'Chest',
            sets: _defaultSets(3),
          ),
          Exercise(
            id: 'seed_upper_lateral',
            name: 'Lateral Raise',
            muscleGroup: 'Shoulders',
            sets: _defaultSets(3),
          ),
        ],
      ),
      Workout(
        id: 'seed_lower',
        title: 'Lower Body',
        date: now,
        exercises: [
          Exercise(
            id: 'seed_lower_rdl',
            name: 'Romanian Deadlift',
            muscleGroup: 'Hamstrings',
            sets: _defaultSets(3),
          ),
          Exercise(
            id: 'seed_lower_legpress',
            name: 'Leg Press',
            muscleGroup: 'Legs',
            sets: _defaultSets(3),
          ),
          Exercise(
            id: 'seed_lower_core',
            name: 'Plank',
            muscleGroup: 'Core',
            sets: _defaultSets(3),
          ),
        ],
      ),
    ]);
  }

  List<ExerciseSet> _defaultSets(int count) {
    return List.generate(
      count,
      (index) => ExerciseSet(order: index + 1, weight: 0, reps: 0),
    );
  }
}
