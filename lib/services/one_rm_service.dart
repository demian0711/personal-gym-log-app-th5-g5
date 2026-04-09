import '../models/workout.dart';

class OneRmSetSample {
  final String exerciseName;
  final DateTime workoutDate;
  final double weight;
  final int reps;
  final double oneRm;

  const OneRmSetSample({
    required this.exerciseName,
    required this.workoutDate,
    required this.weight,
    required this.reps,
    required this.oneRm,
  });
}

class SmartOneRmSuggestion {
  final String exerciseName;
  final double estimatedOneRm;
  final double suggestedWeight;
  final int targetReps;
  final int sampleCount;
  final int confidenceScore;
  final DateTime? lastWorkoutDate;
  final OneRmSetSample bestSample;
  final Map<int, double> recommendationByReps;

  const SmartOneRmSuggestion({
    required this.exerciseName,
    required this.estimatedOneRm,
    required this.suggestedWeight,
    required this.targetReps,
    required this.sampleCount,
    required this.confidenceScore,
    required this.lastWorkoutDate,
    required this.bestSample,
    required this.recommendationByReps,
  });
}

class OneRmService {
  const OneRmService();

  double calculateOneRm({required double weight, required int reps}) {
    if (weight <= 0 || reps <= 0) {
      return 0;
    }
    return weight * (1 + reps / 30);
  }

  double calculateTrainingWeight({
    required double oneRm,
    required int targetReps,
  }) {
    if (oneRm <= 0 || targetReps <= 0) {
      return 0;
    }
    return oneRm / (1 + targetReps / 30);
  }

  double roundLoad(double value, {double increment = 2.5}) {
    if (value <= 0) {
      return 0;
    }
    final rounded = (value / increment).round() * increment;
    return rounded < increment ? increment : rounded;
  }

  SmartOneRmSuggestion? buildExerciseSuggestion(
    List<Workout> history,
    String exerciseName, {
    int targetReps = 8,
  }) {
    final normalized = _normalizeExerciseName(exerciseName);
    if (normalized.isEmpty) {
      return null;
    }

    final samples = _collectExerciseSamples(history, normalized);
    if (samples.isEmpty) {
      return null;
    }

    final bestSample = samples.reduce((a, b) => a.oneRm >= b.oneRm ? a : b);
    final estimatedOneRm = bestSample.oneRm;
    final rawSuggested = calculateTrainingWeight(
      oneRm: estimatedOneRm,
      targetReps: targetReps,
    );
    final confidenceScore = _calculateConfidenceScore(samples);
    final lastWorkoutDate = samples
        .map((s) => s.workoutDate)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    return SmartOneRmSuggestion(
      exerciseName: bestSample.exerciseName,
      estimatedOneRm: estimatedOneRm,
      suggestedWeight: roundLoad(rawSuggested),
      targetReps: targetReps,
      sampleCount: samples.length,
      confidenceScore: confidenceScore,
      lastWorkoutDate: lastWorkoutDate,
      bestSample: bestSample,
      recommendationByReps: _buildRepRecommendation(estimatedOneRm),
    );
  }

  List<SmartOneRmSuggestion> buildSmartSuggestions(
    List<Workout> history, {
    int targetReps = 8,
    int maxItems = 6,
  }) {
    final grouped = <String, List<OneRmSetSample>>{};

    for (final workout in history) {
      for (final exercise in workout.exercises) {
        final normalized = _normalizeExerciseName(exercise.name);
        if (normalized.isEmpty) {
          continue;
        }
        for (final set in exercise.sets) {
          if (!set.isCompleted || set.weight <= 0 || set.reps <= 0) {
            continue;
          }
          final sample = OneRmSetSample(
            exerciseName: exercise.name,
            workoutDate: workout.date,
            weight: set.weight,
            reps: set.reps,
            oneRm: calculateOneRm(weight: set.weight, reps: set.reps),
          );
          grouped.putIfAbsent(normalized, () => <OneRmSetSample>[]).add(sample);
        }
      }
    }

    final suggestions = grouped.entries.map((entry) {
      final samples = entry.value;
      final bestSample = samples.reduce((a, b) => a.oneRm >= b.oneRm ? a : b);
      final estimatedOneRm = bestSample.oneRm;
      final confidenceScore = _calculateConfidenceScore(samples);
      final lastWorkoutDate = samples
          .map((s) => s.workoutDate)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      final rawSuggested = calculateTrainingWeight(
        oneRm: estimatedOneRm,
        targetReps: targetReps,
      );

      return SmartOneRmSuggestion(
        exerciseName: bestSample.exerciseName,
        estimatedOneRm: estimatedOneRm,
        suggestedWeight: roundLoad(rawSuggested),
        targetReps: targetReps,
        sampleCount: samples.length,
        confidenceScore: confidenceScore,
        lastWorkoutDate: lastWorkoutDate,
        bestSample: bestSample,
        recommendationByReps: _buildRepRecommendation(estimatedOneRm),
      );
    }).toList();

    suggestions.sort((a, b) {
      final confidenceDiff = b.confidenceScore.compareTo(a.confidenceScore);
      if (confidenceDiff != 0) {
        return confidenceDiff;
      }
      return b.estimatedOneRm.compareTo(a.estimatedOneRm);
    });

    return suggestions.take(maxItems).toList();
  }

  List<OneRmSetSample> _collectExerciseSamples(
    List<Workout> history,
    String normalizedExerciseName,
  ) {
    final samples = <OneRmSetSample>[];
    for (final workout in history) {
      for (final exercise in workout.exercises) {
        if (_normalizeExerciseName(exercise.name) != normalizedExerciseName) {
          continue;
        }
        for (final set in exercise.sets) {
          if (!set.isCompleted || set.weight <= 0 || set.reps <= 0) {
            continue;
          }
          samples.add(
            OneRmSetSample(
              exerciseName: exercise.name,
              workoutDate: workout.date,
              weight: set.weight,
              reps: set.reps,
              oneRm: calculateOneRm(weight: set.weight, reps: set.reps),
            ),
          );
        }
      }
    }
    return samples;
  }

  Map<int, double> _buildRepRecommendation(double oneRm) {
    final reps = <int>[3, 5, 8, 10, 12];
    final data = <int, double>{};
    for (final rep in reps) {
      data[rep] = roundLoad(
        calculateTrainingWeight(oneRm: oneRm, targetReps: rep),
      );
    }
    return data;
  }

  int _calculateConfidenceScore(List<OneRmSetSample> samples) {
    if (samples.isEmpty) {
      return 0;
    }

    final now = DateTime.now();
    final sampleScore = ((samples.length / 12) * 45).clamp(0, 45).toDouble();

    final lastWorkoutDate = samples
        .map((s) => s.workoutDate)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final daysSinceLast = now.difference(lastWorkoutDate).inDays;
    final recencyScore = daysSinceLast <= 14
        ? 35
        : daysSinceLast <= 30
        ? 26
        : daysSinceLast <= 60
        ? 16
        : 8;

    final qualitySets = samples.where((s) => s.reps <= 12).length;
    final qualityScore = ((qualitySets / samples.length) * 20)
        .clamp(0, 20)
        .toDouble();

    final total = sampleScore + recencyScore + qualityScore;
    return total.round().clamp(1, 100).toInt();
  }

  String _normalizeExerciseName(String name) {
    return name.trim().toLowerCase();
  }
}
