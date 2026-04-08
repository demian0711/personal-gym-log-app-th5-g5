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
  // Color palette matching app theme (teal-based)
  static const Color primaryTeal = Color(0xFF0F6B6E);

  final List<Color> muscleGroupColors = [
    const Color(0xFF0F6B6E), // Teal - Chest
    const Color(0xFF2E7D7F), // Dark Teal - Back
    const Color(0xFF4A9498), // Medium Teal - Shoulders
    const Color(0xFF5CA8AB), // Light Teal - Biceps
    const Color(0xFF70B8BB), // Lighter Teal - Legs
    const Color(0xFF1B5C5E), // Deep Teal - Abs
    const Color(0xFF3B8B8E), // Teal-Blue - Forearms
  ];

  @override
  Widget build(BuildContext context) {
    final muscleGroups = WorkoutGuideService.muscleGroups;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeroImage(colorScheme),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Training Guide',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Select a muscle group to view detailed exercises',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: muscleGroups.length,
            itemBuilder: (context, index) {
              return _buildMuscleGroupCard(
                context,
                muscleGroups[index],
                muscleGroupColors[index % muscleGroupColors.length],
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMuscleGroupCard(
    BuildContext context,
    MuscleGroup muscle,
    Color baseColor,
  ) {
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [baseColor, baseColor.withValues(alpha: 0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  _getMuscleGroupIcon(muscle.id),
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: baseColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getMuscleGroupIcon(muscle.id),
                        size: 28,
                        color: baseColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      muscle.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        muscle.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
        return Icons.layers;
      case 'shoulders':
        return Icons.vertical_align_top;
      case 'biceps':
        return Icons.fitness_center;
      case 'legs':
        return Icons.directions_run;
      case 'abs':
        return Icons.grid_view_rounded;
      case 'forearms':
        return Icons.pan_tool_outlined;
      default:
        return Icons.fitness_center;
    }
  }

  Widget _buildHeroImage(ColorScheme colorScheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryTeal, primaryTeal.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryTeal.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.sports_gymnastics,
                size: 120,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              left: -30,
              bottom: -30,
              child: Icon(
                Icons.self_improvement,
                size: 100,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Expert Training Guide',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Perfect your form with clear guides',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.9),
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
