import 'package:cloud_firestore/cloud_firestore.dart';

/// Workout model dùng cho Analytics module, ánh xạ dữ liệu từ:
/// users/{userId}/workouts/{workoutId}
class WorkoutModel {
  final String id;
  final DateTime date;
  final List<WorkoutExerciseModel> exercises;

  const WorkoutModel({
    required this.id,
    required this.date,
    required this.exercises,
  });

  factory WorkoutModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};
    final rawExercises = (data['exercises'] as List<dynamic>? ?? <dynamic>[]);

    return WorkoutModel(
      id: document.id,
      date: _parseDate(data['date']),
      exercises: rawExercises
          .whereType<Map<String, dynamic>>()
          .map(WorkoutExerciseModel.fromMap)
          .toList(),
    );
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw is Timestamp) {
      return raw.toDate();
    }
    if (raw is DateTime) {
      return raw;
    }
    if (raw is String) {
      return DateTime.tryParse(raw) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }
    if (raw is int) {
      return DateTime.fromMillisecondsSinceEpoch(raw);
    }
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

class WorkoutExerciseModel {
  final String name;
  final List<WorkoutSetModel> sets;

  const WorkoutExerciseModel({
    required this.name,
    required this.sets,
  });

  factory WorkoutExerciseModel.fromMap(Map<String, dynamic> map) {
    final rawSets = (map['sets'] as List<dynamic>? ?? <dynamic>[]);
    return WorkoutExerciseModel(
      name: (map['name'] ?? '') as String,
      sets: rawSets
          .whereType<Map<String, dynamic>>()
          .map(WorkoutSetModel.fromMap)
          .toList(),
    );
  }
}

class WorkoutSetModel {
  final int reps;
  final double weight;

  const WorkoutSetModel({
    required this.reps,
    required this.weight,
  });

  factory WorkoutSetModel.fromMap(Map<String, dynamic> map) {
    return WorkoutSetModel(
      reps: _toInt(map['reps']),
      weight: _toDouble(map['weight']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return 0;
  }
}
