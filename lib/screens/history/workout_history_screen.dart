import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/exercise.dart';
import '../../models/exercise_set.dart';
import '../../models/workout.dart';
import '../../providers/workout_provider.dart';
import '../../services/workout_export_service.dart';

class WorkoutHistoryScreen extends StatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  State<WorkoutHistoryScreen> createState() => _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends State<WorkoutHistoryScreen> {
  final WorkoutExportService _exportService = WorkoutExportService();
  bool _isExporting = false;

  Future<void> _exportExcel(List<Workout> history) async {
    if (history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có dữ liệu để xuất file.')),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      await _exportService.exportToExcel(history);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Xuất Excel thất bại.')));
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _exportPdf(List<Workout> history) async {
    if (history.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa có dữ liệu để xuất file.')),
      );
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      await _exportService.exportToPdf(history);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Xuất PDF thất bại.')));
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Consumer<WorkoutProvider>(
      builder: (context, provider, _) {
        final sortedHistory = [...provider.history]
          ..sort((a, b) => b.date.compareTo(a.date));

        if (sortedHistory.isEmpty) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _isExporting
                            ? null
                            : () => _exportExcel(sortedHistory),
                        icon: const Icon(Icons.table_chart_outlined),
                        label: const Text('Export Excel'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isExporting
                            ? null
                            : () => _exportPdf(sortedHistory),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Export PDF'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: sortedHistory.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _isExporting
                            ? null
                            : () => _exportExcel(sortedHistory),
                        icon: const Icon(Icons.table_chart_outlined),
                        label: const Text('Export Excel'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isExporting
                            ? null
                            : () => _exportPdf(sortedHistory),
                        icon: const Icon(Icons.picture_as_pdf_outlined),
                        label: const Text('Export PDF'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final workout = sortedHistory[index - 1];
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
            _buildSetRow(
              exercise.sets[i],
              previousExercise?.sets.elementAtOrNull(i),
            ),
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
      style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
    ),
  );
}

String _formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  final y = date.year;
  return '$d/$m/$y';
}
