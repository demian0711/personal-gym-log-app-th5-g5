import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/exercise.dart';
import '../../models/exercise_set.dart';
import '../../models/workout.dart';
import '../../providers/workout_provider.dart';

class TemplateScreen extends StatefulWidget {
  const TemplateScreen({super.key});

  @override
  State<TemplateScreen> createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  void _showTemplateDialog({
    Workout? template,
  }) {
    final formKey = GlobalKey<FormState>();
    final titleController =
        TextEditingController(text: template?.title ?? '');

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(template == null ? 'New Template' : 'Edit Template'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Template name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return 'Required';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;

                final provider = context.read<WorkoutProvider>();
                final now = DateTime.now();
                if (template == null) {
                  provider.addTemplate(
                    Workout(
                      id: 'template_${now.millisecondsSinceEpoch}',
                      title: titleController.text.trim(),
                      date: now,
                      exercises: const [],
                    ),
                  );
                } else {
                  provider.updateTemplate(
                    template.copyWith(
                      title: titleController.text.trim(),
                    ),
                  );
                }

                Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showExerciseDialog(Workout template) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final muscleController = TextEditingController();
    final setsController = TextEditingController(text: '3');

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Exercise'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Exercise name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: muscleController,
                  decoration: const InputDecoration(
                    labelText: 'Muscle group',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: setsController,
                  decoration: const InputDecoration(
                    labelText: 'Number of sets',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    final parsed = int.tryParse(trimmed);
                    if (parsed == null || parsed <= 0) return 'Invalid';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final setsCount = int.parse(setsController.text.trim());
                final now = DateTime.now();
                final exercise = Exercise(
                  id: 'exercise_${now.millisecondsSinceEpoch}',
                  name: nameController.text.trim(),
                  muscleGroup: muscleController.text.trim(),
                  sets: List.generate(
                    setsCount,
                    (index) => ExerciseSet(
                      order: index + 1,
                      weight: 0,
                      reps: 0,
                    ),
                  ),
                );

                final updated = template.copyWith(
                  exercises: [...template.exercises, exercise],
                );
                context.read<WorkoutProvider>().updateTemplate(updated);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditExerciseDialog(Workout template, Exercise exercise) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: exercise.name);
    final muscleController = TextEditingController(text: exercise.muscleGroup);
    final setsController =
        TextEditingController(text: exercise.sets.length.toString());

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Exercise'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Exercise name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: muscleController,
                  decoration: const InputDecoration(
                    labelText: 'Muscle group',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: setsController,
                  decoration: const InputDecoration(
                    labelText: 'Number of sets',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    final parsed = int.tryParse(trimmed);
                    if (parsed == null || parsed <= 0) return 'Invalid';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;

                final setsCount = int.parse(setsController.text.trim());
                final updatedExercise = exercise.copyWith(
                  name: nameController.text.trim(),
                  muscleGroup: muscleController.text.trim(),
                  sets: List.generate(
                    setsCount,
                    (index) => ExerciseSet(
                      order: index + 1,
                      weight: 0,
                      reps: 0,
                    ),
                  ),
                );

                final updated = template.copyWith(
                  exercises: template.exercises.map((item) {
                    if (item.id != exercise.id) return item;
                    return updatedExercise;
                  }).toList(),
                );

                context.read<WorkoutProvider>().updateTemplate(updated);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _removeExercise(Workout template, Exercise exercise) {
    final updated = template.copyWith(
      exercises: template.exercises
          .where((item) => item.id != exercise.id)
          .toList(),
    );
    context.read<WorkoutProvider>().updateTemplate(updated);
  }

  @override
  Widget build(BuildContext context) {
    final templates = context.watch<WorkoutProvider>().templates;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTemplateDialog(),
        icon: const Icon(Icons.add),
        label: const Text('New Template'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (templates.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No templates yet. Create one to start workouts.'),
              ),
            ),
          for (final template in templates)
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            template.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () => _showTemplateDialog(
                            template: template,
                          ),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () => context
                              .read<WorkoutProvider>()
                              .removeTemplate(template.id),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Exercises: ${template.exercises.length}'),
                    const SizedBox(height: 12),
                    if (template.exercises.isEmpty)
                      const Text('No exercises yet. Add one below.'),
                    for (final exercise in template.exercises)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(exercise.name),
                        subtitle: Text(
                          '${exercise.muscleGroup} • ${exercise.sets.length} sets',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () => _showEditExerciseDialog(
                                template,
                                exercise,
                              ),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              tooltip: 'Remove',
                              onPressed: () => _removeExercise(template, exercise),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () => _showExerciseDialog(template),
                        icon: const Icon(Icons.fitness_center),
                        label: const Text('Add Exercise'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
