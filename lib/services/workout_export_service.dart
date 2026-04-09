import 'dart:io' show File;
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/workout.dart';
import 'web_file_downloader_stub.dart'
    if (dart.library.html) 'web_file_downloader_web.dart'
    as web_downloader;

class WorkoutExportService {
  Future<void> exportToExcel(List<Workout> history) async {
    final fileName =
        'workout_history_${DateTime.now().millisecondsSinceEpoch}.csv';

    final rows = <List<String>>[
      ['Date', 'Workout Title', 'Duration (min)', 'Exercises', 'Sets', 'Volume (kg)'],
      ...history.map((workout) {
        final totalSets = workout.exercises.fold<int>(
          0,
          (sum, exercise) => sum + exercise.sets.length,
        );

        return [
          _formatDate(workout.date),
          workout.title,
          workout.durationInMinutes.toString(),
          workout.exercises.length.toString(),
          totalSets.toString(),
          _calculateVolume(workout).toStringAsFixed(1),
        ];
      }),
    ];

    final buffer = StringBuffer();
    for (final row in rows) {
      final escaped = row
          .map((cell) => '"${cell.replaceAll('"', '""')}"')
          .join(',');
      buffer.writeln(escaped);
    }

    final bytes = utf8.encode(buffer.toString());

    if (kIsWeb) {
      await web_downloader.downloadBytes(
        Uint8List.fromList(bytes),
        fileName,
        'text/csv',
      );
    } else {
      final file = await _createFile(fileName);
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Workout History (CSV)');
    }
  }

  Future<void> exportToPdf(List<Workout> history) async {
    final document = pw.Document();

    // Tải font hỗ trợ tiếng Việt nếu cần, nhưng tạm thời dùng font mặc định của pdf package
    // Lưu ý: Pdf package mặc định không hỗ trợ tiếng Việt tốt nếu không có font.
    // Tôi sẽ sử dụng các ký tự không dấu hoặc cố gắng dùng font mặc định an toàn.

    document.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(32),
        ),
        header: (context) => pw.Column(
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'WORKOUT HISTORY REPORT',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.Text(
                  'Personal Gym Log',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 2, color: PdfColors.blue900),
            pw.SizedBox(height: 20),
          ],
        ),
        footer: (context) => pw.Column(
          children: [
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Generated on: ${_formatDateTime(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ],
        ),
        build: (context) => [
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            headerStyle: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blue800),
            cellStyle: const pw.TextStyle(fontSize: 10),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1.2),
              4: const pw.FlexColumnWidth(1.2),
              5: const pw.FlexColumnWidth(2),
            },
            headers: [
              'Date',
              'Workout Title',
              'Duration',
              'Exercises',
              'Sets',
              'Volume (kg)',
            ],
            data: history.map((workout) {
              final totalSets = workout.exercises.fold<int>(
                0,
                (sum, exercise) => sum + exercise.sets.length,
              );
              return [
                _formatDate(workout.date),
                workout.title,
                '${workout.durationInMinutes}m',
                '${workout.exercises.length}',
                '$totalSets',
                _calculateVolume(workout).toStringAsFixed(1),
              ];
            }).toList(),
          ),
          if (history.isEmpty)
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 20),
              child: pw.Center(
                child: pw.Text(
                  'No workout history recorded.',
                  style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic,
                    color: PdfColors.grey600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final fileName =
        'workout_history_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final bytes = await document.save();

    if (kIsWeb) {
      await web_downloader.downloadBytes(
        Uint8List.fromList(bytes),
        fileName,
        'application/pdf',
      );
    } else {
      final file = await _createFile(fileName);
      await file.writeAsBytes(bytes, flush: true);
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Workout History (PDF)');
    }
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
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime dt) {
    return '${_formatDate(dt)} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
