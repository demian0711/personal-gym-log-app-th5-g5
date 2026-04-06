import '../../../../models/workout.dart';
import '../../domain/repositories/workout_repository.dart';
import '../services/workout_firestore_service.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final WorkoutFirestoreService _service;

  WorkoutRepositoryImpl(this._service);

  @override
  Future<void> saveWorkout({required String userId, required Workout workout}) {
    return _service.saveWorkout(userId: userId, workout: workout);
  }

  @override
  Future<void> deleteWorkout({
    required String userId,
    required String workoutId,
  }) {
    return _service.deleteWorkout(userId: userId, workoutId: workoutId);
  }

  @override
  Future<List<Workout>> fetchAllWorkouts({required String userId}) {
    return _service.fetchAllWorkouts(userId: userId);
  }

  @override
  Stream<List<Workout>> streamWorkouts({required String userId}) {
    return _service.streamWorkouts(userId: userId);
  }
}
