import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/workout_model.dart';

enum AnalyticsMetric { volume, oneRm }

class AnalyticsDataPoint {
  final DateTime date;
  final double value;

  const AnalyticsDataPoint({
    required this.date,
    required this.value,
  });
}

/// Service xử lý cả phần đọc dữ liệu Firestore và tính toán analytics.
class AnalyticsService {
  final FirebaseFirestore _firestore;

  AnalyticsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Lấy workouts từ Firestore và sắp xếp thời gian tăng dần (ASC).
  Future<List<WorkoutModel>> fetchWorkouts(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('workouts')
        .get();

    final workouts = snapshot.docs.map(WorkoutModel.fromFirestore).toList();
    workouts.sort((a, b) => a.date.compareTo(b.date));
    return workouts;
  }

  /// Tổng volume của 1 workout.
  ///
  /// Công thức: volume = reps * weight.
  double calculateVolume(WorkoutModel workout) {
    double total = 0;
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        if (set.reps <= 0 || set.weight <= 0) {
          continue;
        }
        total += set.reps * set.weight;
      }
    }
    return total;
  }

  /// Epley formula cho 1 set.
  ///
  /// 1RM = weight * (1 + reps / 30)
  double calculate1RM({required int reps, required double weight}) {
    if (reps <= 0 || weight <= 0) {
      return 0;
    }
    return weight * (1 + (reps / 30));
  }

  /// Tìm 1RM đại diện cho 1 workout (lấy max 1RM của mọi set).
  double calculateWorkout1RM(WorkoutModel workout) {
    double best = 0;
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        final oneRm = calculate1RM(reps: set.reps, weight: set.weight);
        if (oneRm > best) {
          best = oneRm;
        }
      }
    }
    return best;
  }

  /// Map workout list -> điểm dữ liệu chart theo ngày.
  /// - Volume: cộng dồn volume trong cùng ngày.
  /// - 1RM: lấy max 1RM trong cùng ngày.
  List<AnalyticsDataPoint> mapToChartData({
    required List<WorkoutModel> workouts,
    required AnalyticsMetric metric,
  }) {
    final Map<DateTime, double> byDay = {};

    for (final workout in workouts) {
      final day = DateTime(workout.date.year, workout.date.month, workout.date.day);
      final value = metric == AnalyticsMetric.volume
          ? calculateVolume(workout)
          : calculateWorkout1RM(workout);

      if (metric == AnalyticsMetric.volume) {
        byDay[day] = (byDay[day] ?? 0) + value;
      } else {
        final current = byDay[day] ?? 0;
        byDay[day] = value > current ? value : current;
      }
    }

    final entries = byDay.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return entries
        .map((entry) => AnalyticsDataPoint(date: entry.key, value: entry.value))
        .toList();
  }
}
