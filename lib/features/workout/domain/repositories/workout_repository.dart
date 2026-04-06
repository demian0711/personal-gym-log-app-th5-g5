import '../../../../models/workout.dart';

abstract class WorkoutRepository {
  Future<void> saveWorkout({required String userId, required Workout workout});

  Future<void> deleteWorkout({
    required String userId,
    required String workoutId,
  });

  Future<List<Workout>> fetchAllWorkouts({required String userId});

  Stream<List<Workout>> streamWorkouts({required String userId});
}
