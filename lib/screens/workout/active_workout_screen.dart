import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/exercise.dart';
import '../../models/exercise_set.dart';
import '../../models/workout.dart';
import '../../providers/utilities_provider.dart';
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
        .map((exercise) => exercise.copyWith(sets: _copySets(exercise)))
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

  Future<void> _finishWorkout() async {
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

    context.read<UtilitiesProvider>().stopRestTimer();
    await context.read<WorkoutProvider>().addWorkoutLog(completedWorkout);

    if (!mounted) return;

    _clearControllers();

    setState(() {
      _activeWorkout = null;
      _selectedTemplateId = null;
      _startTime = null;
    });

    _showMessage('Workout saved.');
  }

  void _backToStartWorkout() {
    context.read<UtilitiesProvider>().stopRestTimer();
    _clearControllers();

    setState(() {
      _activeWorkout = null;
      _startTime = null;
    });
  }

  void _initControllers(Workout workout) {
    for (final exercise in workout.exercises) {
      _setControllers[exercise.id] = exercise.sets.map((set) {
        return _SetInputControllers(
          weightController: TextEditingController(
            text: _formatWeight(set.weight),
          ),
          repsController: TextEditingController(
            text: set.reps == 0 ? '' : set.reps.toString(),
          ),
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
        .map((set) => set.copyWith(isCompleted: false))
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

  void _toggleSet(Workout workout, int exerciseIndex, int setIndex) {
    final exercise = workout.exercises[exerciseIndex];
    final set = exercise.sets[setIndex];
    final controllers = _setControllers[exercise.id]?[setIndex];

    if (controllers == null) return;

    if (!set.isCompleted) {
      final weightValid =
          controllers.weightKey.currentState?.validate() ?? false;
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

    if (!set.isCompleted && updatedSet.isCompleted) {
      context.read<UtilitiesProvider>().startRestTimer();
    }
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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

  String _formatShortDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  _PreviousExercisePerformance? _findPreviousPerformance(
    List<Workout> history,
    Exercise exercise,
  ) {
    final targetName = exercise.name.trim().toLowerCase();

    for (final workout in history) {
      for (final previousExercise in workout.exercises) {
        if (previousExercise.name.trim().toLowerCase() != targetName) {
          continue;
        }

        final hasTrackedSet = previousExercise.sets.any(
          (set) => set.isCompleted && (set.weight > 0 || set.reps > 0),
        );
        if (!hasTrackedSet) {
          continue;
        }

        return _PreviousExercisePerformance(
          workoutDate: workout.date,
          exercise: previousExercise,
        );
      }
    }

    return null;
  }

  ExerciseSet? _findSetByOrder(List<ExerciseSet> sets, int order) {
    for (final set in sets) {
      if (set.order == order && (set.weight > 0 || set.reps > 0)) {
        return set;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final workoutProvider = context.watch<WorkoutProvider>();
    final templates = workoutProvider.templates;
    final history = workoutProvider.history;
    final utilities = context.watch<UtilitiesProvider>();
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
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Back to start',
                onPressed: _backToStartWorkout,
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            const SizedBox(height: 8),
            _buildWorkoutHeader(workout),
            const SizedBox(height: 16),
            if (utilities.isRestTimerRunning) ...[
              _buildRestTimerCard(utilities),
              const SizedBox(height: 16),
            ],
            for (var i = 0; i < workout.exercises.length; i++)
              _buildExerciseCard(workout, i, history),
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
            LayoutBuilder(
              builder: (context, constraints) {
                return DropdownMenu<String>(
                  width: constraints.maxWidth,
                  initialSelection: _selectedTemplateId,
                  enableFilter: true,
                  enableSearch: true,
                  requestFocusOnTap: true,
                  label: const Text('Template'),
                  leadingIcon: const Icon(Icons.search),
                  trailingIcon: const Icon(Icons.arrow_drop_down),
                  dropdownMenuEntries: templates
                      .map(
                        (template) => DropdownMenuEntry<String>(
                          value: template.id,
                          label: template.title,
                        ),
                      )
                      .toList(),
                  onSelected: (value) {
                    setState(() {
                      _selectedTemplateId = value;
                    });
                  },
                );
              },
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
                  Colors.black.withValues(alpha: 0.55),
                  Colors.black.withValues(alpha: 0.05),
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

  Widget _buildExerciseCard(
    Workout workout,
    int exerciseIndex,
    List<Workout> history,
  ) {
    final exercise = workout.exercises[exerciseIndex];
    final controllers = _setControllers[exercise.id] ?? [];
    final previousPerformance = _findPreviousPerformance(history, exercise);

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
            if (previousPerformance != null) ...[
              const SizedBox(height: 4),
              Text(
                'Last session: ${_formatShortDate(previousPerformance.workoutDate)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
                  final previousSet = previousPerformance == null
                      ? null
                      : _findSetByOrder(
                          previousPerformance.exercise.sets,
                          set.order,
                        );

                  return DataRow(
                    cells: [
                      DataCell(Text(set.order.toString())),
                      DataCell(
                        SizedBox(
                          width: 108,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
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
                              if (previousSet != null && previousSet.weight > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Last: ${_formatWeight(previousSet.weight)} kg',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 80,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextFormField(
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
                              if (previousSet != null && previousSet.reps > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Last: ${previousSet.reps}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                            ],
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

  Widget _buildRestTimerCard(UtilitiesProvider utilities) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.timer_outlined,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Rest timer: ${utilities.remainingRestSeconds}s remaining',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: utilities.stopRestTimer,
              child: const Text('Stop'),
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

class _PreviousExercisePerformance {
  final DateTime workoutDate;
  final Exercise exercise;

  const _PreviousExercisePerformance({
    required this.workoutDate,
    required this.exercise,
  });
}
