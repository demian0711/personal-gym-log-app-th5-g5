import 'workout.dart';

class UserWorkoutData {
  final List<Workout> templates;
  final List<Workout> history;

  const UserWorkoutData({
    required this.templates,
    required this.history,
  });

  Map<String, dynamic> toMap() {
    return {
      'templates': templates.map((item) => item.toMap()).toList(),
      'history': history.map((item) => item.toMap()).toList(),
    };
  }

  factory UserWorkoutData.fromMap(Map<String, dynamic> map) {
    final rawTemplates = (map['templates'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();
    final rawHistory = (map['history'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();

    return UserWorkoutData(
      templates: rawTemplates.map(Workout.fromMap).toList(),
      history: rawHistory.map(Workout.fromMap).toList(),
    );
  }
}
