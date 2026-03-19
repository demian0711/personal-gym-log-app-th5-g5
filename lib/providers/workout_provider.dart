import 'package:flutter/foundation.dart';

import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../models/workout.dart';

class WorkoutProvider extends ChangeNotifier {
  final List<Workout> _templates = [];
  final List<Workout> _history = [];

  WorkoutProvider() {
    _seedTemplates();
  }

  List<Workout> get templates => List.unmodifiable(_templates);
  List<Workout> get history => List.unmodifiable(_history);

  void addTemplate(Workout template) {
    _templates.add(template);
    notifyListeners();
  }

  void updateTemplate(Workout template) {
    final index = _templates.indexWhere((item) => item.id == template.id);
    if (index == -1) return;
    _templates[index] = template;
    notifyListeners();
  }

  void removeTemplate(String id) {
    _templates.removeWhere((template) => template.id == id);
    notifyListeners();
  }

  void addWorkoutLog(Workout workout) {
    _history.insert(0, workout);
    notifyListeners();
  }

  void clearAll() {
    _templates.clear();
    _history.clear();
    notifyListeners();
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
      (index) => ExerciseSet(
        order: index + 1,
        weight: 0,
        reps: 0,
      ),
    );
  }
}
