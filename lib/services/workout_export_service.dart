import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/workout.dart';

class WorkoutExportService {
  Future<void> exportToExcel(List<Workout> history) async {
    final excel = Excel.createExcel();
    final sheet = excel['Workout History'];

    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Title'),
      TextCellValue('Duration (min)'),
      TextCellValue('Exercises'),
      TextCellValue('Sets'),
      TextCellValue('Total Volume'),
    ]);

    for (final workout in history) {
      final totalSets = workout.exercises.fold<int>(
        0,
        (sum, exercise) => sum + exercise.sets.length,
      );
      final totalVolume = _calculateVolume(workout);

      sheet.appendRow([
        TextCellValue(_formatDate(workout.date)),
        TextCellValue(workout.title),
        IntCellValue(workout.durationInMinutes),
        IntCellValue(workout.exercises.length),
        IntCellValue(totalSets),
        DoubleCellValue(totalVolume),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Không thể tạo file Excel.');
    }

    final file = await _createFile(
      'workout_history_${DateTime.now().millisecondsSinceEpoch}.xlsx',
    );
    await file.writeAsBytes(bytes, flush: true);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Workout History (Excel)');
  }

  Future<void> exportToPdf(List<Workout> history) async {
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(20),
        ),
        build: (context) {
          final widgets = <pw.Widget>[
            pw.Text(
              'Workout History Report',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Generated: ${DateTime.now()}'),
            pw.SizedBox(height: 16),
          ];

          for (final workout in history) {
            final totalSets = workout.exercises.fold<int>(
              0,
              (sum, exercise) => sum + exercise.sets.length,
            );

            widgets.add(
              pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 10),
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      workout.title,
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text('Date: ${_formatDate(workout.date)}'),
                    pw.Text('Duration: ${workout.durationInMinutes} min'),
                    pw.Text('Exercises: ${workout.exercises.length}'),
                    pw.Text('Sets: $totalSets'),
                    pw.Text(
                      'Total Volume: ${_calculateVolume(workout).toStringAsFixed(1)}',
                    ),
                  ],
                ),
              ),
            );
          }

          if (history.isEmpty) {
            widgets.add(pw.Text('No workout history available.'));
          }

          return widgets;
        },
      ),
    );

    final file = await _createFile(
      'workout_history_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await document.save(), flush: true);

    await Share.shareXFiles([XFile(file.path)], text: 'Workout History (PDF)');
  }

  Future<File> _createFile(String fileName) async {
    final directory = await getTemporaryDirectory();
    return File('${directory.path}/$fileName');
  }

  double _calculateVolume(Workout workout) {
    double total = 0;
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        if (!set.isCompleted) {
          continue;
        }
        total += set.weight * set.reps;
      }
    }
    return total;
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year;
    return '$d/$m/$y';
  }
}
