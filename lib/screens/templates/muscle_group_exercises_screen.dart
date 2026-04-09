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
  @override
  Widget build(BuildContext context) {
    final exercises = WorkoutGuideService.getExercisesByMuscleGroup(
      widget.muscleGroup.id,
    );

    return Scaffold(
      appBar: AppBar(title: Text(widget.muscleGroup.name), elevation: 0),
      body: exercises.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text('Chua co bai tap nao'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                return _buildExerciseCard(context, exercises[index]);
              },
            ),
    );
  }

  Widget _buildExerciseCard(BuildContext context, GuideExercise exercise) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ExerciseDetailScreen(exercise: exercise),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors
                  .primaries[exercise.id.hashCode % Colors.primaries.length]
                  .withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors
                            .primaries[exercise.id.hashCode %
                                Colors.primaries.length]
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color:
                            Colors.primaries[exercise.id.hashCode %
                                Colors.primaries.length],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            exercise.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoTag('Sets', exercise.defaultSets),
                    _buildInfoTag('Reps', exercise.defaultReps),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.arrow_forward,
                          color:
                              Colors.primaries[exercise.id.hashCode %
                                  Colors.primaries.length],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTag(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
