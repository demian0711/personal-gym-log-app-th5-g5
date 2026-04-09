import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../models/user_workout_data.dart';
import '../models/workout.dart';
import '../features/workout/data/repositories/workout_repository_impl.dart';
import '../features/workout/data/services/workout_firestore_service.dart';
import '../features/workout/domain/repositories/workout_repository.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';
import '../services/one_rm_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  final FirebaseService _firebase = FirebaseService();
  final WorkoutRepository _workoutRepository;
  final OneRmService _oneRmService = const OneRmService();

  List<Workout> _templates = [];
  List<Workout> _history = [];
  String? _userId;
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _lastError;
  Workout? _activeWorkout;
  DateTime? _activeStartedAt;

  WorkoutProvider(this._storage, {WorkoutRepository? workoutRepository})
    : _workoutRepository =
          workoutRepository ?? WorkoutRepositoryImpl(WorkoutFirestoreService());

  List<Workout> get templates => List.unmodifiable(_templates);
  List<Workout> get history => List.unmodifiable(_history);
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get lastError => _lastError;
  Workout? get activeWorkout => _activeWorkout;
  bool get hasActiveWorkout => _activeWorkout != null;

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
    _lastError = null;
    try {
      final userId = _userId;
      if (userId != null) {
        await _workoutRepository.saveWorkout(userId: userId, workout: workout);
        await _firebase.uploadWorkoutLog(workout);
      }
    } catch (_) {
      _lastError = 'Không thể đồng bộ buổi tập lên Firestore.';
    }
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
    _lastError = null;
    notifyListeners();

    try {
      _templates = await _firebase.downloadTemplates();
      _history = await _workoutRepository.fetchAllWorkouts(userId: _userId!);
      await _persist();
    } catch (_) {
      _lastError = 'Không thể tải dữ liệu workout từ Firestore.';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

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
      await _firebase.syncAllToFirebase(_templates, _history);
      for (final workout in _history) {
        await _workoutRepository.saveWorkout(
          userId: _userId!,
          workout: workout,
        );
      }
    } catch (_) {
      _lastError = 'Không thể đồng bộ workout lên Firestore.';
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

  Exercise _cloneExerciseWithSuggestion(Exercise exercise) {
    return exercise.copyWith(
      sets: exercise.sets.map((set) {
        final targetReps = set.reps > 0 ? set.reps : 8;
        final suggestedWeight = _suggestWeight(
          exercise.name,
          targetReps: targetReps,
          fallbackSetOrder: set.order,
        );
        return set.copyWith(
          weight: suggestedWeight,
          reps: targetReps,
          isCompleted: false,
        );
      }).toList(),
    );
  }

  double _suggestWeight(
    String exerciseName, {
    required int targetReps,
    required int fallbackSetOrder,
  }) {
    final smartSuggestion = _oneRmService.buildExerciseSuggestion(
      _history,
      exerciseName,
      targetReps: targetReps,
    );
    if (smartSuggestion != null && smartSuggestion.suggestedWeight > 0) {
      return smartSuggestion.suggestedWeight;
    }

    for (final workout in _history) {
      for (final exercise in workout.exercises) {
        if (exercise.name.toLowerCase() != exerciseName.toLowerCase()) {
          continue;
        }

        for (final set in exercise.sets) {
          if (!set.isCompleted ||
              set.order != fallbackSetOrder ||
              set.weight <= 0) {
            continue;
          }
          return set.weight + 2.5;
        }
      }
    }
    return 0;
  }
}
