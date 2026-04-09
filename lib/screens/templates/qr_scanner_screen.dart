import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
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
  static const Color primaryTealColor = Color(0xFF0F6B6E);
  late final MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      facing: CameraFacing.back,
      detectionSpeed: DetectionSpeed.normal,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét QR bài tập'), centerTitle: true),
      body: Stack(
        children: [
          MobileScanner(
            controller: _scannerController,
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
                border: Border.all(color: primaryTealColor, width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Text(
              'Đưa mã QR vào giữa khung để quét',
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
              'Dụng cụ: ${apiData['equipment']}. Nhóm cơ chính: ${apiData['target']}. Nhóm cơ phụ: ${(apiData['secondaryMuscles'] as List).join(', ')}.',
          steps: (apiData['instructions'] as List).cast<String>(),
          benefits: [
            'Chuẩn hoá kỹ thuật tập',
            'Tăng khả năng cô lập nhóm cơ',
            'Tăng sức mạnh tổng thể',
          ],
          tips: [
            'Giữ core siết ổn định',
            'Kiểm soát toàn bộ biên độ',
            'Thở ra khi gắng sức',
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
          content: Text('Không tìm thấy bài tập. Vui lòng quét mã QR hợp lệ.'),
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
    return _ExerciseDetailSheet(exercise: exercise, gifUrl: gifUrl);
  }
}

class _ExerciseDetailSheet extends StatefulWidget {
  final GuideExercise exercise;
  final String? gifUrl;

  const _ExerciseDetailSheet({required this.exercise, this.gifUrl});

  @override
  State<_ExerciseDetailSheet> createState() => _ExerciseDetailSheetState();
}

class _ExerciseDetailSheetState extends State<_ExerciseDetailSheet> {
  YoutubePlayerController? _controller;
  bool _isYoutubeUnavailable = false;

  @override
  void initState() {
    super.initState();
    if (widget.exercise.videoId != null) {
      _controller = YoutubePlayerController(
        initialVideoId: widget.exercise.videoId!,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          loop: true,
          disableDragSeek: true,
          useHybridComposition: true,
        ),
      );
      _controller!.addListener(_onYoutubeStateChanged);
    }
  }

  void _onYoutubeStateChanged() {
    final controller = _controller;
    if (!mounted || controller == null) {
      return;
    }

    if (controller.value.hasError && !_isYoutubeUnavailable) {
      setState(() {
        _isYoutubeUnavailable = true;
      });
    }
  }

  String _buildSearchUrl() {
    final query = Uri.encodeComponent('${widget.exercise.name} exercise tutorial');
    return 'https://www.youtube.com/results?search_query=$query';
  }

  Uri _buildWebVideoUri({String? fallbackVideoId}) {
    final videoId =
        widget.exercise.videoId?.trim().isNotEmpty == true
        ? widget.exercise.videoId!.trim()
        : fallbackVideoId;
    return videoId != null
        ? Uri.parse('https://www.youtube.com/watch?v=$videoId')
        : Uri.parse(_buildSearchUrl());
  }

  Future<void> _openVideoOnWeb({String? fallbackVideoId}) async {
    final webUri = _buildWebVideoUri(fallbackVideoId: fallbackVideoId);
    await launchUrl(
      webUri,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(
        enableJavaScript: true,
        enableDomStorage: true,
      ),
    );
  }

  String? _resolveYoutubeThumbnail() {
    final videoId = widget.exercise.videoId;
    if (videoId == null || videoId.isEmpty) {
      return null;
    }
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }

  String? _suggestVideoIdByExerciseName(String exerciseName) {
    final key = exerciseName.toLowerCase().trim();
    const knownVideoMap = {
      'barbell row': 'vT2GjY_Umpw',
      'đòn tạ kéo thân': 'vT2GjY_Umpw',
      'deadlift': 'op9kVnSso6Q',
      'bench press': 'gRVjAtPip0Y',
      'đẩy ngực phẳng': 'gRVjAtPip0Y',
      'squat': 'ultWZbUMPL8',
      'gánh tạ': 'ultWZbUMPL8',
      'lat pulldown': 'CAwf7n6Luuc',
      'military press': '2yjwXTZQDDI',
      'dumbbell curl': 'ykJmrZ5v0Oo',
      'hammer curl': 'zC3nLlEvin4',
    };

    final directMatch = knownVideoMap[key];
    if (directMatch != null) {
      return directMatch;
    }

    final openBracket = key.indexOf('(');
    final closeBracket = key.indexOf(')');
    if (openBracket >= 0 && closeBracket > openBracket) {
      final inBracket = key.substring(openBracket + 1, closeBracket).trim();
      final bracketMatch = knownVideoMap[inBracket];
      if (bracketMatch != null) {
        return bracketMatch;
      }
    }

    final beforeBracket = openBracket > 0 ? key.substring(0, openBracket).trim() : key;
    return knownVideoMap[beforeBracket];
  }

  @override
  void dispose() {
    _controller?.removeListener(_onYoutubeStateChanged);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fallbackVideoId = _suggestVideoIdByExerciseName(widget.exercise.name);

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
                          if (_controller != null && !_isYoutubeUnavailable)
                            YoutubePlayer(
                              controller: _controller!,
                              showVideoProgressIndicator: true,
                              progressIndicatorColor: Colors.teal,
                            )
                          else if (widget.gifUrl != null &&
                              widget.gifUrl!.isNotEmpty)
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.network(
                                  widget.gifUrl!,
                                  fit: BoxFit.contain,
                                  cacheWidth:
                                      800, // Optimize memory consumption
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.teal,
                                            strokeWidth: 2,
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
                                ),
                                // Play Video Search Overlay (Fallback)
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () => _openVideoOnWeb(
                                      fallbackVideoId: fallbackVideoId,
                                    ),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white70,
                                            width: 1,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (_isYoutubeUnavailable)
                                  Positioned(
                                    top: 10,
                                    left: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Video nhúng bị chặn. Đang dùng GIF minh hoạ.',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          else if (_isYoutubeUnavailable &&
                              _resolveYoutubeThumbnail() != null)
                            Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  _resolveYoutubeThumbnail()!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, _, __) {
                                    return const Center(
                                      child: Icon(
                                        Icons.ondemand_video,
                                        color: Colors.white38,
                                        size: 64,
                                      ),
                                    );
                                  },
                                ),
                                Container(color: Colors.black38),
                                Center(
                                  child: FilledButton.icon(
                                    onPressed: () => _openVideoOnWeb(
                                      fallbackVideoId: fallbackVideoId,
                                    ),
                                    icon: const Icon(Icons.open_in_new),
                                    label: const Text('Xem trên YouTube'),
                                  ),
                                ),
                              ],
                            )
                          else
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.6,
                                child: Icon(
                                  (context
                                          .findAncestorStateOfType<
                                            _QRScannerScreenState
                                          >()
                                          ?._getCategoryIcon(
                                            widget.exercise.muscleGroupId,
                                          )) ??
                                      Icons.fitness_center,
                                  size: 100,
                                  color: Colors.white24,
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: FilledButton.icon(
                              onPressed: () => _openVideoOnWeb(
                                fallbackVideoId: fallbackVideoId,
                              ),
                              icon: const Icon(Icons.play_circle_outline),
                              label: const Text('Xem trên YouTube'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.exercise.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _QRScannerScreenState.primaryTealColor,
                    ),
                  ),
                  Text(
                    widget.exercise.muscleGroupId.toUpperCase(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    'Hướng dẫn',
                    widget.exercise.steps.join('\n\n'),
                  ),
                  _buildSection(
                    'Lợi ích',
                    widget.exercise.benefits.join(' • '),
                  ),
                  _buildSection('Mẹo tập', widget.exercise.tips.join(' • ')),
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
                    child: const Text('Đóng'),
                  ),
                ),
                // We need to resolve the widget original context to call its methods
                Builder(
                  builder: (context) {
                    final parent = context
                        .findAncestorStateOfType<_QRScannerScreenState>();
                    if (parent?.widget.template != null) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  _QRScannerScreenState.primaryTealColor,
                            ),
                            onPressed: () {
                              parent?._addExerciseToTemplate(widget.exercise);
                              Navigator.pop(context); // Close sheet
                              Navigator.pop(parent!.context); // Close scanner
                            },
                            child: const Text('Thêm vào mẫu tập'),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
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
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Keep helper methods below inside _QRScannerScreenState scope if needed
extension _QRScannerHelpers on _QRScannerScreenState {
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
        content: Text('Đã thêm "${guideExercise.name}" vào mẫu tập'),
        backgroundColor: _QRScannerScreenState.primaryTealColor,
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
