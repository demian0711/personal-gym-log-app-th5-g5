import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../models/workout_guide.dart';
import '../../services/workout_guide_service.dart';
import 'exercise_detail_screen.dart';

class QrExerciseScannerScreen extends StatefulWidget {
  const QrExerciseScannerScreen({super.key});

  @override
  State<QrExerciseScannerScreen> createState() =>
      _QrExerciseScannerScreenState();
}

class _QrExerciseScannerScreenState extends State<QrExerciseScannerScreen> {
  bool _isNavigating = false;
  DateTime? _lastInvalidToastAt;
  String _lastInvalidValue = '';
  late final MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      facing: CameraFacing.front,
      detectionSpeed: DetectionSpeed.normal,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BuildContext context, BarcodeCapture capture) {
    if (_isNavigating) {
      return;
    }

    final rawValue = capture.barcodes
        .map((barcode) => barcode.rawValue?.trim() ?? '')
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');

    if (rawValue.isEmpty) {
      return;
    }

    final GuideExercise? exercise = WorkoutGuideService.findExerciseByQr(
      rawValue,
    );
    if (exercise == null) {
      final now = DateTime.now();
      final shouldShowToast =
          _lastInvalidToastAt == null ||
          now.difference(_lastInvalidToastAt!).inSeconds >= 2 ||
          _lastInvalidValue != rawValue;
      if (shouldShowToast) {
        _lastInvalidToastAt = now;
        _lastInvalidValue = rawValue;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không nhận diện được mã: $rawValue\n'
              'Hãy thử mã như: bench_press, Bench Press, exercise:bench_press',
            ),
          ),
        );
      }
      return;
    }

    _isNavigating = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ExerciseDetailScreen(exercise: exercise),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét QR bài tập')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: (capture) => _onDetect(context, capture),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Đưa QR vào khung camera.\n'
                'Hỗ trợ: bench_press | Bench Press | exercise:bench_press | '
                'https://.../exercise/bench_press',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
