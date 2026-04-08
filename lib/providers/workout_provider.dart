import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../models/user_workout_data.dart';
import '../models/workout.dart';
 HEAD
import '../features/workout/data/repositories/workout_repository_impl.dart';
import '../features/workout/data/services/workout_firestore_service.dart';
import '../features/workout/domain/repositories/workout_repository.dart';
  
  HPT
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  final FirebaseService _firebase = FirebaseService();
 HEAD
  final WorkoutRepository _workoutRepository;
  
  HPT

  List<Workout> _templates = [];
  List<Workout> _history = [];
  String? _userId;
  bool _isLoading = false;
  bool _isSyncing = false;
 HEAD
  String? _lastError;
  Workout? _activeWorkout;
  DateTime? _activeStartedAt;
  
  HPT

  WorkoutProvider(this._storage, {WorkoutRepository? workoutRepository})
    : _workoutRepository =
          workoutRepository ?? WorkoutRepositoryImpl(WorkoutFirestoreService());

  List<Workout> get templates => List.unmodifiable(_templates);
  List<Workout> get history => List.unmodifiable(_history);
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
 HEAD
  String? get lastError => _lastError;
  Workout? get activeWorkout => _activeWorkout;
  bool get hasActiveWorkout => _activeWorkout != null;
  
  HPT

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
 HEAD
    _lastError = null;
    try {
      final userId = _userId;
      if (userId != null) {
        await _workoutRepository.saveWorkout(userId: userId, workout: workout);
      }
    } catch (_) {
      _lastError = 'Không thể đồng bộ buổi tập lên Firestore.';
    }
  
    try {
      await _firebase.uploadWorkoutLog(workout);
    } catch (_) {}
  HPT
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
 HEAD
    _lastError = null;
  
  HPT
    notifyListeners();

    try {
      _templates = await _firebase.downloadTemplates();
 HEAD
      _history = await _workoutRepository.fetchAllWorkouts(userId: _userId!);
      await _persist();
    } catch (_) {
      _lastError = 'Không thể tải dữ liệu workout từ Firestore.';
  
      _history = await _firebase.downloadWorkoutLogs();
      await _persist();
    } catch (_) {
  HPT
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

 HEAD
  void startWorkoutFromTemplate(Workout template) {
    final now = DateTime.now();
    _activeStartedAt = now;
    _activeWorkout = Workout(
      id: 'workout_${now.millisecondsSinceEpoch}',
      title: template.title,
      date: now,
      exercises: template.exercises.map(_cloneExerciseWithSuggestion).toList(),
    );
    notifyListeners();
  }

  void cancelActiveWorkout() {
    _activeWorkout = null;
    _activeStartedAt = null;
    notifyListeners();
  }

  void updateActiveSet({
    required String exerciseId,
    required int setOrder,
    double? weight,
    int? reps,
    bool? isCompleted,
  }) {
    final workout = _activeWorkout;
    if (workout == null) {
      return;
    }

    final updatedExercises = workout.exercises.map((exercise) {
      if (exercise.id != exerciseId) {
        return exercise;
      }

      final updatedSets = exercise.sets.map((set) {
        if (set.order != setOrder) {
          return set;
        }
        return set.copyWith(
          weight: weight ?? set.weight,
          reps: reps ?? set.reps,
          isCompleted: isCompleted ?? set.isCompleted,
        );
      }).toList();

      return exercise.copyWith(sets: updatedSets);
    }).toList();

    _activeWorkout = workout.copyWith(exercises: updatedExercises);
    notifyListeners();
  }

  Future<String?> finishActiveWorkout() async {
    final workout = _activeWorkout;
    final startedAt = _activeStartedAt;
    if (workout == null || startedAt == null) {
      return 'Không có buổi tập đang hoạt động.';
    }

    final hasCompletedSet = workout.exercises.any(
      (exercise) => exercise.sets.any((set) => set.isCompleted),
    );

    if (!hasCompletedSet) {
      return 'Hãy hoàn thành ít nhất 1 set trước khi lưu.';
    }

    final durationInMinutes = DateTime.now().difference(startedAt).inMinutes;
    final completedWorkout = workout.copyWith(
      durationInMinutes: durationInMinutes > 0 ? durationInMinutes : 1,
    );

    await addWorkoutLog(completedWorkout);
    _activeWorkout = null;
    _activeStartedAt = null;
    notifyListeners();
    return null;
  }

  Future<void> syncToFirebase() async {
    if (_userId == null) return;
    _isSyncing = true;
    _lastError = null;
    notifyListeners();

    try {
      await _firebase.syncAllToFirebase(_templates, <Workout>[]);
      for (final workout in _history) {
        await _workoutRepository.saveWorkout(
          userId: _userId!,
          workout: workout,
        );
      }
    } catch (_) {
      _lastError = 'Không thể đồng bộ workout lên Firestore.';
  
  Future<void> syncToFirebase() async {
    if (_userId == null) return;
    _isSyncing = true;
    notifyListeners();

    try {
      await _firebase.syncAllToFirebase(_templates, _history);
    } catch (_) {
  HPT
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
      }

      try {
        _templates = await _firebase.downloadTemplates();
        _history = await _workoutRepository.fetchAllWorkouts(userId: userId);
        await _persist();
      } catch (_) {
        _lastError = 'Không thể đồng bộ dữ liệu từ Firestore.';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    final userId = _userId;
    if (userId == null) return;
    final data = UserWorkoutData(templates: _templates, history: _history);
    await _storage.saveWorkoutData(userId, data);
  }

 HEAD
  Exercise _cloneExerciseWithSuggestion(Exercise exercise) {
    return exercise.copyWith(
      sets: exercise.sets.map((set) {
        final suggestedWeight = _suggestWeight(exercise.name, set.order);
        return set.copyWith(
          weight: suggestedWeight,
          reps: 8,
          isCompleted: false,
        );
      }).toList(),
  
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
  HPT
    );
  }

  double _suggestWeight(String exerciseName, int setOrder) {
    for (final workout in _history) {
      for (final exercise in workout.exercises) {
        if (exercise.name.toLowerCase() != exerciseName.toLowerCase()) {
          continue;
        }

        for (final set in exercise.sets) {
          if (!set.isCompleted || set.order != setOrder || set.weight <= 0) {
            continue;
          }
          return set.weight + 2.5;
        }
      }
    }
    return 0;
  }
}
