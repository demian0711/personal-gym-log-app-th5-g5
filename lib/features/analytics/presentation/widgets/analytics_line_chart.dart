import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/services/analytics_service.dart';

class AnalyticsLineChart extends StatelessWidget {
  final List<AnalyticsDataPoint> data;
  final AnalyticsMetric metric;

  const AnalyticsLineChart({
    super.key,
    required this.data,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final spots = data
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
        .toList();

    final maxY = _resolveMaxY(data);
    final interval = _resolveHorizontalInterval(maxY);

    return SizedBox(
      height: 230,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (spots.length - 1).toDouble(),
          minY: 0,
          maxY: maxY,
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant),
              left: BorderSide(color: colorScheme.outlineVariant),
              right: BorderSide.none,
              top: BorderSide.none,
            ),
          ),
          gridData: FlGridData(
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: colorScheme.outlineVariant.withValues(alpha: 0.28),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(0),
                    style: textTheme.labelSmall,
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: _resolveBottomInterval(data.length),
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      _formatDate(data[index].date),
                      style: textTheme.labelSmall,
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => colorScheme.inverseSurface,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final index = spot.x.toInt();
                  if (index < 0 || index >= data.length) {
                    return null;
                  }
                  final point = data[index];
                  final unit = metric == AnalyticsMetric.volume ? 'kg' : 'kg';

                  return LineTooltipItem(
                    '${_formatDate(point.date)}\n${point.value.toStringAsFixed(1)} $unit',
                    TextStyle(
                      color: colorScheme.onInverseSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: colorScheme.primary,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3.2,
                    color: colorScheme.primary,
                    strokeColor: colorScheme.surface,
                    strokeWidth: 1.8,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colorScheme.primary.withValues(alpha: 0.28),
                    colorScheme.primary.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

double _resolveMaxY(List<AnalyticsDataPoint> data) {
  if (data.isEmpty) {
    return 10;
  }
  final maxValue = data
      .map((point) => point.value)
      .reduce((current, next) => current > next ? current : next);
  if (maxValue <= 0) {
    return 10;
  }
  return maxValue * 1.2;
}

double _resolveHorizontalInterval(double maxY) {
  if (maxY <= 50) return 10;
  if (maxY <= 200) return 25;
  if (maxY <= 500) return 50;
  if (maxY <= 2000) return 200;
  return maxY / 5;
}

double _resolveBottomInterval(int length) {
  if (length <= 6) return 1;
  if (length <= 12) return 2;
  if (length <= 24) return 4;
  return 6;
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day/$month';
}
