import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/exercise.dart';
import '../../models/exercise_set.dart';
import '../../models/workout.dart';
import '../../providers/workout_provider.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, List<_SetInputControllers>> _setControllers = {};

  Workout? _activeWorkout;
  String? _selectedTemplateId;
  DateTime? _startTime;

  @override
  void dispose() {
    _clearControllers();
    super.dispose();
  }

  void _clearControllers() {
    for (final list in _setControllers.values) {
      for (final controller in list) {
        controller.dispose();
      }
    }
    _setControllers.clear();
  }

  void _startWorkout(Workout template) {
    final now = DateTime.now();
    final exercises = template.exercises
        .map((exercise) => exercise.copyWith(
              sets: _copySets(exercise),
            ))
        .toList();

    final workout = Workout(
      id: 'workout_${now.millisecondsSinceEpoch}',
      title: template.title,
      date: now,
      exercises: exercises,
    );

    _clearControllers();
    _initControllers(workout);

    setState(() {
      _activeWorkout = workout;
      _startTime = now;
    });
  }

  void _finishWorkout() {
    final workout = _activeWorkout;
    if (workout == null) return;

    if (!_validateCompletedSets(workout)) {
      _showMessage('Please complete weight and reps before checking a set.');
      return;
    }

    final completedWorkout = _applyControllersToWorkout(workout).copyWith(
      durationInMinutes: _startTime == null
          ? 0
          : DateTime.now().difference(_startTime!).inMinutes,
    );

    context.read<WorkoutProvider>().addWorkoutLog(completedWorkout);

    _clearControllers();

    setState(() {
      _activeWorkout = null;
      _selectedTemplateId = null;
      _startTime = null;
    });

    _showMessage('Workout saved.');
  }

  void _initControllers(Workout workout) {
    for (final exercise in workout.exercises) {
      _setControllers[exercise.id] = exercise.sets.map((set) {
        return _SetInputControllers(
          weightController:
              TextEditingController(text: _formatWeight(set.weight)),
          repsController: TextEditingController(
              text: set.reps == 0 ? '' : set.reps.toString()),
        );
      }).toList();
    }
  }

  List<ExerciseSet> _copySets(Exercise exercise) {
    if (exercise.sets.isEmpty) {
      return List.generate(
        3,
        (index) => ExerciseSet(order: index + 1, weight: 0, reps: 0),
      );
    }

    return exercise.sets
        .map(
          (set) => set.copyWith(isCompleted: false),
        )
        .toList();
  }

  String _formatWeight(double weight) {
    if (weight == 0) return '';
    final intWeight = weight.roundToDouble();
    if (intWeight == weight) {
      return weight.toInt().toString();
    }
    return weight.toString();
  }

  void _toggleSet(
    Workout workout,
    int exerciseIndex,
    int setIndex,
  ) {
    final exercise = workout.exercises[exerciseIndex];
    final set = exercise.sets[setIndex];
    final controllers = _setControllers[exercise.id]?[setIndex];

    if (controllers == null) return;

    if (!set.isCompleted) {
      final weightValid = controllers.weightKey.currentState?.validate() ?? false;
      final repsValid = controllers.repsKey.currentState?.validate() ?? false;
      if (!weightValid || !repsValid) {
        return;
      }
    }

    final updatedSet = set.copyWith(
      weight: _parseWeight(controllers.weightController.text),
      reps: _parseReps(controllers.repsController.text),
      isCompleted: !set.isCompleted,
    );

    final updatedExercises = [...workout.exercises];
    final updatedSets = [...exercise.sets];
    updatedSets[setIndex] = updatedSet;
    updatedExercises[exerciseIndex] = exercise.copyWith(sets: updatedSets);

    setState(() {
      _activeWorkout = workout.copyWith(exercises: updatedExercises);
    });
  }

  bool _validateCompletedSets(Workout workout) {
    for (final exercise in workout.exercises) {
      final controllers = _setControllers[exercise.id];
      if (controllers == null) continue;
      for (var i = 0; i < exercise.sets.length; i++) {
        final set = exercise.sets[i];
        if (!set.isCompleted) continue;
        final weightValid =
            controllers[i].weightKey.currentState?.validate() ?? false;
        final repsValid =
            controllers[i].repsKey.currentState?.validate() ?? false;
        if (!weightValid || !repsValid) {
          return false;
        }
      }
    }
    return true;
  }

  Workout _applyControllersToWorkout(Workout workout) {
    final updatedExercises = workout.exercises.map((exercise) {
      final controllers = _setControllers[exercise.id];
      if (controllers == null) return exercise;

      final updatedSets = exercise.sets.asMap().entries.map((entry) {
        final index = entry.key;
        final set = entry.value;
        final input = controllers[index];
        return set.copyWith(
          weight: _parseWeight(input.weightController.text),
          reps: _parseReps(input.repsController.text),
        );
      }).toList();

      return exercise.copyWith(sets: updatedSets);
    }).toList();

    return workout.copyWith(exercises: updatedExercises);
  }

  double _parseWeight(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return double.tryParse(trimmed) ?? 0;
  }

  int _parseReps(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return int.tryParse(trimmed) ?? 0;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  int _totalSets(Workout workout) {
    return workout.exercises.fold<int>(
      0,
      (total, exercise) => total + exercise.sets.length,
    );
  }

  int _completedSets(Workout workout) {
    return workout.exercises.fold<int>(
      0,
      (total, exercise) =>
          total + exercise.sets.where((set) => set.isCompleted).length,
    );
  }

  String _formatStartTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final templates = context.watch<WorkoutProvider>().templates;
    final workout = _activeWorkout;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeroImage(),
          const SizedBox(height: 16),
          if (workout == null) _buildStartCard(templates),
          if (workout != null) ...[
            _buildWorkoutHeader(workout),
            const SizedBox(height: 16),
            for (var i = 0; i < workout.exercises.length; i++)
              _buildExerciseCard(workout, i),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _finishWorkout,
              icon: const Icon(Icons.flag),
              label: const Text('Finish Workout'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStartCard(List<Workout> templates) {
    if (templates.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No templates yet. Create one in Templates to start a workout.',
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Start Workout',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedTemplateId,
              items: templates
                  .map(
                    (template) => DropdownMenuItem<String>(
                      value: template.id,
                      child: Text(template.title),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTemplateId = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Template',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _selectedTemplateId == null
                    ? null
                    : () {
                        final template = templates.firstWhere(
                          (item) => item.id == _selectedTemplateId,
                        );
                        _startWorkout(template);
                      },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        alignment: Alignment.bottomLeft,
        children: [
          Image.asset(
            'assets/images/gym_banner.png',
            height: 170,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            height: 170,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.55),
                  Colors.black.withOpacity(0.05),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Active Workout',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutHeader(Workout workout) {
    final startTime = _startTime;
    final totalSets = _totalSets(workout);
    final completedSets = _completedSets(workout);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workout.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text('Exercises: ${workout.exercises.length}'),
            Text('Sets completed: $completedSets / $totalSets'),
            if (startTime != null)
              Text('Started at: ${_formatStartTime(startTime)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Workout workout, int exerciseIndex) {
    final exercise = workout.exercises[exerciseIndex];
    final controllers = _setControllers[exercise.id] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              exercise.muscleGroup,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 12,
                columns: const [
                  DataColumn(label: Text('Set')),
                  DataColumn(label: Text('Weight (kg)')),
                  DataColumn(label: Text('Reps')),
                  DataColumn(label: Text('Check')),
                ],
                rows: exercise.sets.asMap().entries.map((entry) {
                  final setIndex = entry.key;
                  final set = entry.value;
                  final input = controllers[setIndex];
                  final isCompleted = set.isCompleted;

                  return DataRow(
                    cells: [
                      DataCell(Text(set.order.toString())),
                      DataCell(
                        SizedBox(
                          width: 96,
                          child: TextFormField(
                            key: input.weightKey,
                            controller: input.weightController,
                            enabled: !isCompleted,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                              hintText: 'kg',
                            ),
                            validator: _validateWeight,
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 72,
                          child: TextFormField(
                            key: input.repsKey,
                            controller: input.repsController,
                            enabled: !isCompleted,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              isDense: true,
                              border: OutlineInputBorder(),
                              hintText: 'reps',
                            ),
                            validator: _validateReps,
                          ),
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: Icon(
                            isCompleted
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: isCompleted
                                ? Colors.green
                                : Colors.grey.shade600,
                          ),
                          onPressed: () =>
                              _toggleSet(workout, exerciseIndex, setIndex),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateWeight(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Required';
    }
    final weight = double.tryParse(trimmed);
    if (weight == null || weight <= 0) {
      return 'Invalid';
    }
    return null;
  }

  String? _validateReps(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Required';
    }
    final reps = int.tryParse(trimmed);
    if (reps == null || reps <= 0) {
      return 'Invalid';
    }
    return null;
  }
}

class _SetInputControllers {
  final TextEditingController weightController;
  final TextEditingController repsController;
  final GlobalKey<FormFieldState> weightKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> repsKey = GlobalKey<FormFieldState>();

  _SetInputControllers({
    required this.weightController,
    required this.repsController,
  });

  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }
}
