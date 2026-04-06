import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/workout.dart';

class WorkoutFirestoreService {
  final FirebaseFirestore _firestore;

  WorkoutFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _workoutsCollection =>
      _firestore.collection('workouts');

  Future<void> saveWorkout({
    required String userId,
    required Workout workout,
  }) async {
    final payload = workout.toMap()
      ..['userId'] = userId
      ..['updatedAt'] = FieldValue.serverTimestamp()
      ..putIfAbsent('createdAt', () => FieldValue.serverTimestamp());

    await _workoutsCollection
        .doc(workout.id)
        .set(payload, SetOptions(merge: true));
  }

  Future<void> deleteWorkout({
    required String userId,
    required String workoutId,
  }) async {
    final ref = _workoutsCollection.doc(workoutId);
    final doc = await ref.get();
    final data = doc.data();
    if (data == null) {
      return;
    }

    if (data['userId'] != userId) {
      return;
    }

    await ref.delete();
  }

  Future<List<Workout>> fetchAllWorkouts({required String userId}) async {
    final snapshot = await _workoutsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map(_toWorkout).toList();
  }

  Stream<List<Workout>> streamWorkouts({required String userId}) {
    return _workoutsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_toWorkout).toList());
  }

  Workout _toWorkout(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data();
    if ((map['id'] as String?)?.isEmpty ?? true) {
      map['id'] = doc.id;
    }
    return Workout.fromMap(map);
  }
}
