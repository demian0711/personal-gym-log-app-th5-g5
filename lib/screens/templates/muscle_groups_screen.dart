import 'package:flutter/material.dart';
import '../../models/workout_guide.dart';
import '../../services/workout_guide_service.dart';
import 'muscle_group_exercises_screen.dart';

class MuscleGroupsScreen extends StatefulWidget {
  const MuscleGroupsScreen({super.key});

  @override
  State<MuscleGroupsScreen> createState() => _MuscleGroupsScreenState();
}

class _MuscleGroupsScreenState extends State<MuscleGroupsScreen> {
  @override
  Widget build(BuildContext context) {
    final muscleGroups = WorkoutGuideService.muscleGroups;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeroImage(),
          const SizedBox(height: 16),
          const Text(
            'Chuong trinh tap luyện theo nhóm co',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chon nhom co de xem cac bai tap',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: muscleGroups.length,
            itemBuilder: (context, index) {
              return _buildMuscleGroupCard(context, muscleGroups[index]);
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMuscleGroupCard(BuildContext context, MuscleGroup muscle) {
    final colorIndex = WorkoutGuideService.muscleGroups.indexOf(muscle);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                MuscleGroupExercisesScreen(muscleGroup: muscle),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Color.lerp(
                  Colors.blueAccent,
                  Colors.purpleAccent,
                  colorIndex / 7,
                )!,
                Color.lerp(Colors.lightBlue, Colors.pink, colorIndex / 7)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  _getMuscleGroupIcon(muscle.id),
                  size: 32,
                  color: Color.lerp(
                    Colors.blueAccent,
                    Colors.purpleAccent,
                    colorIndex / 7,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                muscle.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  muscle.description,
                  style: const TextStyle(fontSize: 11, color: Colors.white70),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMuscleGroupIcon(String muscleGroupId) {
    switch (muscleGroupId) {
      case 'chest':
        return Icons.favorite;
      case 'back':
        return Icons.backpack;
      case 'shoulders':
        return Icons.upgrade;
      case 'biceps':
        return Icons.fitness_center;
      case 'legs':
        return Icons.directions_run;
      case 'abs':
        return Icons.emoji_events;
      case 'forearms':
        return Icons.pan_tool;
      default:
        return Icons.fitness_center;
    }
  }

  Widget _buildHeroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: -20,
              bottom: -20,
              child: Icon(
                Icons.fitness_center,
                size: 100,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, size: 40, color: Colors.white),
                const SizedBox(height: 8),
                const Text(
                  'Huong dan tap luyện',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
