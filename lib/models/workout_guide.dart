class MuscleGroup {
  final String id;
  final String name;
  final String imagePath;
  final String description;

  const MuscleGroup({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.description,
  });
}

class GuideExercise {
  final String id;
  final String name;
  final String muscleGroupId;
  final String description;
  final List<String> steps;
  final String? trainingSchedule;
  final List<String> benefits;
  final List<String> tips;
  final String defaultSets;
  final String defaultReps;

  const GuideExercise({
    required this.id,
    required this.name,
    required this.muscleGroupId,
    required this.description,
    required this.steps,
    this.trainingSchedule,
    required this.benefits,
    required this.tips,
    required this.defaultSets,
    required this.defaultReps,
  });
}
