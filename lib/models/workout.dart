import 'exercise.dart';

class Workout {
  final String id;
  final String title;
  final DateTime date;
  final int durationInMinutes;
  final List<Exercise> exercises;

  const Workout({
    required this.id,
    required this.title,
    required this.date,
    this.durationInMinutes = 0,
    this.exercises = const [],
  });

  Workout copyWith({
    String? id,
    String? title,
    DateTime? date,
    int? durationInMinutes,
    List<Exercise>? exercises,
  }) {
    return Workout(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
      exercises: exercises ?? this.exercises,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'date': date.toIso8601String(),
      'durationInMinutes': durationInMinutes,
      'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    final rawExercises = (map['exercises'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();

    return Workout(
      id: map['id'] as String,
      title: map['title'] as String,
      date: DateTime.parse(map['date'] as String),
      durationInMinutes: map['durationInMinutes'] as int? ?? 0,
      exercises: rawExercises.map(Exercise.fromMap).toList(),
    );
  }
}
