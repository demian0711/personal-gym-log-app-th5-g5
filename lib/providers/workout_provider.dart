import 'package:flutter/foundation.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../models/workout.dart';
import '../services/local_storage_service.dart';
import '../services/firebase_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final FirebaseService _firebase = FirebaseService();

  List<Workout> _templates = [];
  List<Workout> _history = [];
  bool _isSyncing = false;

  List<Workout> get templates => List.unmodifiable(_templates);
  List<Workout> get history => List.unmodifiable(_history);
  bool get isSyncing => _isSyncing;

  WorkoutProvider();

  Future<void> loadData() async {
    _templates = await _storage.getAllTemplates();
    _history = await _storage.getAllWorkoutLogs();

    if (_templates.isEmpty) {
      _seedTemplates();
      for (final template in _templates) {
        await _storage.saveTemplate(template);
      }
    }

    notifyListeners();
  }

  Future<void> addTemplate(Workout template) async {
    _templates.add(template);
    // Save locally
    await _storage.saveTemplate(template);
    // Try to sync to Firebase
    try {
      await _firebase.uploadTemplate(template);
    } catch (e) {
      print('Error uploading template to Firebase: $e');
    }
    notifyListeners();
  }

  Future<void> updateTemplate(Workout template) async {
    final index = _templates.indexWhere((item) => item.id == template.id);
    if (index == -1) return;
    _templates[index] = template;
    // Save locally
    await _storage.saveTemplate(template);
    // Try to sync to Firebase
    try {
      await _firebase.uploadTemplate(template);
    } catch (e) {
      print('Error updating template in Firebase: $e');
    }
    notifyListeners();
  }

  Future<void> removeTemplate(String id) async {
    _templates.removeWhere((template) => template.id == id);
    // Delete locally
    await _storage.deleteTemplate(id);
    // Try to delete from Firebase
    try {
      await _firebase.deleteTemplate(id);
    } catch (e) {
      print('Error deleting template from Firebase: $e');
    }
    notifyListeners();
  }

  Future<void> addWorkoutLog(Workout workout) async {
    _history.insert(0, workout);
    // Save locally
    await _storage.saveWorkoutLog(workout);
    // Try to sync to Firebase
    try {
      await _firebase.uploadWorkoutLog(workout);
    } catch (e) {
      print('Error uploading workout log to Firebase: $e');
    }
    notifyListeners();
  }

  Future<void> clearAll() async {
    for (var t in _templates) {
      await _storage.deleteTemplate(t.id);
    }
    for (var h in _history) {
      await _storage.deleteWorkoutLog(h.id);
    }
    _templates.clear();
    _history.clear();
    notifyListeners();
  }

  /// Sync all data from Firebase to local storage
  Future<void> syncFromFirebase() async {
    _isSyncing = true;
    notifyListeners();

    try {
      // Download templates from Firebase
      final firebaseTemplates = await _firebase.downloadTemplates();
      _templates = firebaseTemplates;

      // Download workout logs from Firebase
      final firebaseLogs = await _firebase.downloadWorkoutLogs();
      _history = firebaseLogs;

      print('Successfully synced data from Firebase');
    } catch (e) {
      print('Error syncing from Firebase: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Sync all local data to Firebase
  Future<void> syncToFirebase() async {
    _isSyncing = true;
    notifyListeners();

    try {
      await _firebase.syncAllToFirebase(_templates, _history);
      print('Successfully synced data to Firebase');
    } catch (e) {
      print('Error syncing to Firebase: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
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
