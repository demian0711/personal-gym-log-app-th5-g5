import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/workout_guide.dart';
import '../../models/exercise.dart';
import '../../models/exercise_set.dart';
import '../../models/workout.dart';
import '../../providers/workout_provider.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final GuideExercise exercise;

  const ExerciseDetailScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  int _currentStepIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.exercise.name), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection('Mo Ta', widget.exercise.description),
                  const SizedBox(height: 24),
                  _buildStepsSection(),
                  const SizedBox(height: 24),
                  _buildBenefitsSection(),
                  const SizedBox(height: 24),
                  _buildTipsSection(),
                  const SizedBox(height: 24),
                  _buildScheduleSection(),
                  const SizedBox(height: 24),
                  _buildDefaultsSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addToTemplate(),
        icon: const Icon(Icons.add),
        label: const Text('Them vao Tap'),
      ),
    );
  }

  void _addToTemplate() {
    final provider = context.read<WorkoutProvider>();
    final now = DateTime.now();

    int setsCount =
        int.tryParse(
          widget.exercise.defaultSets.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        3;

    final exercise = Exercise(
      id: 'exercise_${now.millisecondsSinceEpoch}',
      name: widget.exercise.name,
      muscleGroup: widget.exercise.muscleGroupId,
      sets: List.generate(
        setsCount,
        (index) => ExerciseSet(order: index + 1, weight: 0, reps: 0),
      ),
    );

    final template = Workout(
      id: 'template_${now.millisecondsSinceEpoch}',
      title: widget.exercise.name,
      date: now,
      exercises: [exercise],
    );

    provider.addTemplate(template).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Da them "${widget.exercise.name}" vao My Templates'),
          duration: const Duration(milliseconds: 2000),
          action: SnackBarAction(
            label: 'Go',
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ),
      );
    });
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.fitness_center,
          size: 80,
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cac Buoc Thuc Hien',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Stepper(
          currentStep: _currentStepIndex,
          onStepTapped: (index) {
            setState(() {
              _currentStepIndex = index;
            });
          },
          steps: widget.exercise.steps
              .map(
                (step) => Step(
                  title: Text(
                    'Buoc ${widget.exercise.steps.indexOf(step) + 1}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  content: Text(
                    step,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                  isActive:
                      _currentStepIndex == widget.exercise.steps.indexOf(step),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Loi Ich',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...widget.exercise.benefits.map((benefit) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 12),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Expanded(
                  child: Text(
                    benefit,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Meo Vang',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...widget.exercise.tips.map((tip) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                border: Border(left: BorderSide(color: Colors.amber, width: 4)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb, size: 20, color: Colors.amber),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Lich Tap Goi Y',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Colors.green.shade600,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.exercise.trainingSchedule ??
                      'Khong co lap lich cu the',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultsSection() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Icon(Icons.repeat, size: 32, color: Colors.blue),
                const SizedBox(height: 8),
                const Text(
                  'Sets',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  widget.exercise.defaultSets,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Icon(Icons.trending_up, size: 32, color: Colors.orange),
                const SizedBox(height: 8),
                const Text(
                  'Reps',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  widget.exercise.defaultReps,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
