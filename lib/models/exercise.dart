import 'exercise_set.dart';

class Exercise {
  final String id;
  final String name;
  final String muscleGroup;
  final List<ExerciseSet> sets;

  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.sets = const [],
  });

  Exercise copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    List<ExerciseSet>? sets,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      sets: sets ?? this.sets,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'sets': sets.map((set) => set.toMap()).toList(),
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    final rawSets = (map['sets'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();

    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      muscleGroup: map['muscleGroup'] as String,
      sets: rawSets.map(ExerciseSet.fromMap).toList(),
    );
  }
}
