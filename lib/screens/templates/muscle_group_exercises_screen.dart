import 'package:flutter/material.dart';
import '../../models/workout_guide.dart';
import '../../services/workout_guide_service.dart';
import 'exercise_detail_screen.dart';

class MuscleGroupExercisesScreen extends StatefulWidget {
  final MuscleGroup muscleGroup;

  const MuscleGroupExercisesScreen({super.key, required this.muscleGroup});

  @override
  State<MuscleGroupExercisesScreen> createState() =>
      _MuscleGroupExercisesScreenState();
}

class _MuscleGroupExercisesScreenState
    extends State<MuscleGroupExercisesScreen> {
  static const Color primaryTeal = Color(0xFF0F6B6E);

  @override
  Widget build(BuildContext context) {
    final exercises = WorkoutGuideService.getExercisesByMuscleGroup(
      widget.muscleGroup.id,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.muscleGroup.name),
        elevation: 0,
        centerTitle: true,
      ),
      body: exercises.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: colorScheme.outlineVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No exercises available',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                return _buildExerciseCard(
                  context,
                  exercises[index],
                  colorScheme,
                );
              },
            ),
    );
  }

  Widget _buildExerciseCard(
    BuildContext context,
    GuideExercise exercise,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ExerciseDetailScreen(exercise: exercise),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryTeal.withValues(alpha: 0.2),
            width: 1,
          ),
          color: colorScheme.surface,
        ),
        child: Stack(
          children: [
            // Gradient accent bar on left
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  gradient: LinearGradient(
                    colors: [primaryTeal, primaryTeal.withValues(alpha: 0.5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primaryTeal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: primaryTeal,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              exercise.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exercise.description,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: primaryTeal.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoTag('Sets', exercise.defaultSets, colorScheme),
                      const SizedBox(width: 8),
                      _buildInfoTag('Reps', exercise.defaultReps, colorScheme),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(String label, String value, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: primaryTeal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: primaryTeal.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: primaryTeal.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Text(': ', style: TextStyle(color: primaryTeal, fontSize: 12)),
          Text(
            value,
            style: const TextStyle(
              color: primaryTeal,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
