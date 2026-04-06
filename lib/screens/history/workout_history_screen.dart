import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/exercise.dart';
import '../../models/exercise_set.dart';
import '../../models/workout.dart';
import '../../providers/workout_provider.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<WorkoutProvider>(
      builder: (context, provider, _) {
        final history = provider.history;

        if (history.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workout History',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'No workouts have been saved yet. Go to the Workout tab and tap Finish Workout to create history.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final workout = history[index];
            final totalSets = workout.exercises.fold<int>(
              0,
              (total, item) => total + item.sets.length,
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                title: Text(
                  workout.title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${_formatDate(workout.date)} • ${workout.durationInMinutes} min • ${workout.exercises.length} exercises • $totalSets sets',
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showWorkoutDetail(context, workout),
              ),
            );
          },
        );
      },
    );
  }
}

void _showWorkoutDetail(BuildContext context, Workout workout) {
  final history = context.read<WorkoutProvider>().history;
  
  // Find the previous workout of the same type (same title)
  final workoutIndex = history.indexWhere((w) => w.id == workout.id);
  Workout? previousWorkout;
  if (workoutIndex != -1) {
    for (int i = workoutIndex + 1; i < history.length; i++) {
      if (history[i].title == workout.title) {
        previousWorkout = history[i];
        break;
      }
    }
  }

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                workout.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                '${_formatDate(workout.date)} • ${workout.durationInMinutes} min',
              ),
              if (previousWorkout != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Compared to previous session on ${_formatDate(previousWorkout.date)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              for (final exercise in workout.exercises) ...[
                _buildExerciseDetailCard(context, exercise, previousWorkout),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      );
    },
  );
}

Widget _buildExerciseDetailCard(
  BuildContext context,
  Exercise exercise,
  Workout? previousWorkout,
) {
  final previousExercise = previousWorkout?.exercises.firstWhere(
    (e) => e.name == exercise.name,
    orElse: () => exercise.copyWith(sets: []),
  );

  return Card(
    margin: EdgeInsets.zero,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.name,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          Text(exercise.muscleGroup),
          const SizedBox(height: 8),
          for (var i = 0; i < exercise.sets.length; i++) ...[
            _buildSetRow(exercise.sets[i], previousExercise?.sets.elementAtOrNull(i)),
            if (i < exercise.sets.length - 1) const SizedBox(height: 4),
          ],
        ],
      ),
    ),
  );
}

Widget _buildSetRow(ExerciseSet set, ExerciseSet? prevSet) {
  return Row(
    children: [
      Text(
        'Set ${set.order}: ${set.weight} kg × ${set.reps} reps',
        style: const TextStyle(fontSize: 14),
      ),
      if (prevSet != null) ...[
        const Spacer(),
        _buildComparisonTag(set, prevSet),
      ],
    ],
  );
}

Widget _buildComparisonTag(ExerciseSet current, ExerciseSet previous) {
  final weightDiff = current.weight - previous.weight;
  final repsDiff = current.reps - previous.reps;

  String text = '';
  Color color = Colors.grey;

  if (weightDiff > 0) {
    text = '+${weightDiff.toStringAsFixed(1)} kg';
    color = Colors.green;
  } else if (weightDiff < 0) {
    text = '${weightDiff.toStringAsFixed(1)} kg';
    color = Colors.red;
  } else if (repsDiff > 0) {
    text = '+$repsDiff reps';
    color = Colors.green;
  } else if (repsDiff < 0) {
    text = '$repsDiff reps';
    color = Colors.red;
  } else {
    text = 'Same';
    color = Colors.grey;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        color: color,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

String _formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  final y = date.year;
  return '$d/$m/$y';
}
