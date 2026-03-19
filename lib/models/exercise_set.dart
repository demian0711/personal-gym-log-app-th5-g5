class ExerciseSet {
  final int order;
  final double weight;
  final int reps;
  final bool isCompleted;

  const ExerciseSet({
    required this.order,
    required this.weight,
    required this.reps,
    this.isCompleted = false,
  });

  ExerciseSet copyWith({
    int? order,
    double? weight,
    int? reps,
    bool? isCompleted,
  }) {
    return ExerciseSet(
      order: order ?? this.order,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'order': order,
      'weight': weight,
      'reps': reps,
      'isCompleted': isCompleted,
    };
  }

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      order: map['order'] as int,
      weight: (map['weight'] as num).toDouble(),
      reps: map['reps'] as int,
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}
