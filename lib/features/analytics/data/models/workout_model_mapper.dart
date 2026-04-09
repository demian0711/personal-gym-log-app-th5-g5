import '../../../../models/exercise.dart';
import '../../../../models/exercise_set.dart';
import '../../../../models/workout.dart';
import 'workout_model.dart';

extension WorkoutModelMapping on Workout {
  WorkoutModel toAnalyticsModel() {
    return WorkoutModel(
      id: id,
      date: date,
      exercises: exercises.map((e) => e.toAnalyticsModel()).toList(),
    );
  }
}

extension on Exercise {
  WorkoutExerciseModel toAnalyticsModel() {
    return WorkoutExerciseModel(
      name: name,
      sets: sets.map((s) => s.toAnalyticsModel()).toList(),
    );
  }
}

extension on ExerciseSet {
  WorkoutSetModel toAnalyticsModel() {
    return WorkoutSetModel(reps: reps, weight: weight);
  }
}
