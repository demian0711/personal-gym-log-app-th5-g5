import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../models/exercise.dart';
import '../../models/exercise_set.dart';
import '../../models/workout.dart';
import '../../models/workout_guide.dart';
import '../../providers/workout_provider.dart';
import '../../services/workout_guide_service.dart';
import '../../services/exercise_api_service.dart';

class QRScannerScreen extends StatefulWidget {
  final Workout? template;

  const QRScannerScreen({super.key, this.template});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _isScanned = false;
  static const Color primaryTeal = Color(0xFF0F6B6E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Exercise QR'), centerTitle: true),
      body: Stack(
        children: [
          MobileScanner(
            controller: MobileScannerController(facing: CameraFacing.front),
            onDetect: (capture) {
              if (_isScanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final String? code = barcode.rawValue;
                if (code != null) {
                  _processQR(code);
                  break;
                }
              }
            },
          ),
          // Scanner Overlay
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: primaryTeal, width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              'Align QR code within the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 10, color: Colors.black)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processQR(String code) async {
    setState(() => _isScanned = true);

    try {
      // 1. First try looking up in Local Guide Service
      try {
        final guideExercise = WorkoutGuideService.exercises.firstWhere(
          (e) => e.id == code || e.name.toLowerCase() == code.toLowerCase(),
        );
        _showExercisePreview(guideExercise);
        return;
      } catch (_) {
        // Not found in local guide, proceed to API
      }

      // 2. Try looking up in ExerciseDB API
      final apiData = await ExerciseApiService.fetchExerciseByName(code);
      if (apiData != null) {
        final guideExercise = GuideExercise(
          id: apiData['id'] ?? 'api_${DateTime.now().millisecondsSinceEpoch}',
          name: (apiData['name'] as String)
              .split(' ')
              .map((s) => s[0].toUpperCase() + s.substring(1))
              .join(' '),
          muscleGroupId: apiData['target'] ?? 'other',
          description:
              'Equipment: ${apiData['equipment']}. Target Muscle: ${apiData['target']}. Secondary: ${(apiData['secondaryMuscles'] as List).join(', ')}.',
          steps: (apiData['instructions'] as List).cast<String>(),
          benefits: [
            'Professional form guidance',
            'Muscle isolation',
            'Increased strength',
          ],
          tips: [
            'Keep core engaged',
            'Control the movement',
            'Breath out on exertion',
          ],
          defaultSets: '3',
          defaultReps: '10-12',
        );

        // Dynamic image path from API (GIF URL)
        final String gifUrl = apiData['gifUrl'] ?? '';

        _showExercisePreview(guideExercise, gifUrl: gifUrl);
        return;
      }

      throw Exception('Exercise not found');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercise not found. Please scan a valid workout QR.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      setState(() => _isScanned = false);
    }
  }

  void _showExercisePreview(GuideExercise exercise, {String? gifUrl}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildPreviewSheet(exercise, gifUrl: gifUrl),
    ).then((_) {
      if (mounted) {
        setState(() => _isScanned = false);
      }
    });
  }

  Widget _buildPreviewSheet(GuideExercise exercise, {String? gifUrl}) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Video/GIF Preview
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (gifUrl != null && gifUrl.isNotEmpty)
                            Image.network(
                              gifUrl,
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: primaryTeal,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, obj, stack) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.white24,
                                    size: 64,
                                  ),
                                );
                              },
                            )
                          else
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.6,
                                child: Icon(
                                  _getCategoryIcon(exercise.muscleGroupId),
                                  size: 100,
                                  color: Colors.white24,
                                ),
                              ),
                            ),
                          if (gifUrl == null)
                            const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_circle_fill,
                                  size: 64,
                                  color: primaryTeal,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Watch Exercise Video',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: primaryTeal,
                    ),
                  ),
                  Text(
                    exercise.muscleGroupId.toUpperCase(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection('Instructions', exercise.steps.join('\n\n')),
                  _buildSection('Benefits', exercise.benefits.join(' • ')),
                  _buildSection('Pro Tips', exercise.tips.join(' • ')),
                  const SizedBox(height: 100), // Space for button
                ],
              ),
            ),
          ),
          // Action Buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Dismiss'),
                  ),
                ),
                if (widget.template != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: primaryTeal,
                      ),
                      onPressed: () {
                        _addExerciseToTemplate(exercise);
                        Navigator.pop(context); // Close sheet
                        Navigator.pop(context); // Close scanner
                      },
                      child: const Text('Add to Template'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  void _addExerciseToTemplate(GuideExercise guideExercise) {
    final now = DateTime.now();
    int setsCount =
        int.tryParse(
          guideExercise.defaultSets.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        3;

    final exercise = Exercise(
      id: 'exercise_${now.millisecondsSinceEpoch}',
      name: guideExercise.name,
      muscleGroup: guideExercise.muscleGroupId,
      sets: List.generate(
        setsCount,
        (index) => ExerciseSet(order: index + 1, weight: 0, reps: 0),
      ),
    );

    final template = widget.template;
    if (template == null) return;

    final updated = template.copyWith(
      exercises: [...template.exercises, exercise],
    );

    context.read<WorkoutProvider>().updateTemplate(updated);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${guideExercise.name}" to template'),
        backgroundColor: primaryTeal,
      ),
    );
  }

  IconData _getCategoryIcon(String muscleGroupId) {
    switch (muscleGroupId.toLowerCase()) {
      case 'chest':
      case 'pectorals':
        return Icons.favorite;
      case 'back':
      case 'lats':
      case 'traps':
      case 'upper back':
        return Icons.layers;
      case 'shoulders':
      case 'delts':
        return Icons.vertical_align_top;
      case 'legs':
      case 'quads':
      case 'hamstrings':
      case 'calves':
      case 'glutes':
        return Icons.directions_run;
      case 'abs':
      case 'core':
      case 'waist':
        return Icons.grid_view_rounded;
      default:
        return Icons.fitness_center;
    }
  }
}
