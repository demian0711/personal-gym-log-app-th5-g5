import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../models/workout.dart';
import '../../providers/workout_provider.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onStartExercisesTap;

  const DashboardScreen({super.key, this.onStartExercisesTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final profileProvider = context.watch<ProfileProvider>();
    final weeklyTarget = profileProvider.profile?.weeklyTarget ?? 3;

    return Consumer<WorkoutProvider>(
      builder: (context, provider, _) {
        final history = provider.history;
        final sortedHistory = [...history]
          ..sort((a, b) => b.date.compareTo(a.date));
        final lastWorkout = sortedHistory.isNotEmpty
            ? sortedHistory.first
            : null;

        final chartData = _buildChartData(sortedHistory);
        final recentCount = sortedHistory.take(7).length;
        final startOfWeek = DateTime.now().subtract(const Duration(days: 7));
        final weeklyCount = sortedHistory
            .where((workout) => workout.date.isAfter(startOfWeek))
            .length;
        final streakDays = _calculateWorkoutStreak(sortedHistory);
        final totalVolume = _sumTotalVolume(sortedHistory);
        final personalRecord = _findPersonalRecord(sortedHistory);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeroImage(),
              const SizedBox(height: 16),
              _buildWelcomeCard(context),
              const SizedBox(height: 16),
              _buildWeeklyProgress(context, weeklyCount, weeklyTarget),
              const SizedBox(height: 16),
              _buildStreakAndQuickAction(context, streakDays, onStartExercisesTap),
              const SizedBox(height: 16),
              Text(
                'Tổng quan nhanh',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _DashboardStatCard(
                      title: 'Buổi tập gần đây',
                      value: '$recentCount',
                      icon: Icons.calendar_month,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DashboardStatCard(
                      title: 'Tổng khối lượng',
                      value: totalVolume.toStringAsFixed(0),
                      icon: Icons.timer,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DashboardStatCard(
                      title: 'Kỷ lục (kg)',
                      value: personalRecord.toStringAsFixed(1),
                      icon: Icons.local_fire_department,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _StrengthChartCard(data: chartData),
              const SizedBox(height: 18),
              _LatestWorkoutCard(workout: lastWorkout),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildHeroImage() {
  return ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: Stack(
      alignment: Alignment.bottomLeft,
      children: [
        Image.asset(
          'assets/images/gym_banner.png',
          height: 160,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Container(
          height: 160,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.55),
                Colors.black.withValues(alpha: 0.08),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Sẵn sàng bứt phá hôm nay',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildStreakAndQuickAction(
  BuildContext context,
  int streakDays,
  VoidCallback? onStartExercisesTap,
) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return Row(
    children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: colorScheme.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chuỗi tập hiện tại',
                      style: textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$streakDays ngày liên tiếp',
                      style: textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(width: 10),
      FilledButton.icon(
        onPressed: onStartExercisesTap,
        icon: const Icon(Icons.play_arrow_rounded),
        label: const Text('Bắt đầu tập nhanh'),
      ),
    ],
  );
}

Widget _buildWeeklyProgress(BuildContext context, int current, int target) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;
  final progress = (current / target).clamp(0.0, 1.0);

  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mục tiêu hàng tuần',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '$current / $target buổi',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progress >= 1.0
                ? 'Đã đạt mục tiêu! Tuần này thật tuyệt vời.'
                : 'Bạn còn thiếu ${target - current} buổi nữa để đạt mục tiêu tuần.',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    ),
  );
}

Widget _buildWelcomeCard(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final textTheme = Theme.of(context).textTheme;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [colorScheme.primary, colorScheme.primaryContainer],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.insights, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Bảng điều khiển',
                style: textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Theo dõi tiến trình sức mạnh và xem tóm tắt buổi tập gần nhất của bạn.',
          style: textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.94),
          ),
        ),
      ],
    ),
  );
}

class _DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _DashboardStatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(title, style: textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _StrengthChartCard extends StatelessWidget {
  final List<double> data;

  const _StrengthChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final yInterval = _resolveGridInterval(data);
    final maxY = _resolveMaxY(data);

    final spots = data
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biểu đồ tăng trưởng sức mạnh',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '7 buổi gần nhất (tổng khối lượng)',
              style: textTheme.bodySmall,
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 210,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (data.length - 1).toDouble(),
                  minY: 0,
                  maxY: maxY,
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      bottom: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: 1,
                      ),
                      left: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: 1,
                      ),
                      right: BorderSide.none,
                      top: BorderSide.none,
                    ),
                  ),
                  gridData: FlGridData(
                    horizontalInterval: yInterval,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.3,
                        ),
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
                        interval: yInterval,
                        reservedSize: 44,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _formatChartAxisLabel(value),
                            style: textTheme.labelSmall,
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= data.length) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'B${idx + 1}',
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
                      getTooltipItems: (spots) {
                        return spots
                            .map(
                              (spot) => LineTooltipItem(
                                spot.y.toStringAsFixed(0),
                                TextStyle(
                                  color: colorScheme.onInverseSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                            .toList();
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
                            radius: 3.5,
                            color: colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: colorScheme.surface,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.35),
                            colorScheme.primary.withValues(alpha: 0.02),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
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

class _LatestWorkoutCard extends StatelessWidget {
  final Workout? workout;

  const _LatestWorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: workout == null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buổi tập gần nhất',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Chưa có dữ liệu buổi tập. Hoàn thành một buổi để xem tóm tắt tại đây.',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buổi tập gần nhất',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout!.title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Ngày: ${_formatDate(workout!.date)}',
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Thời lượng: ${workout!.durationInMinutes} phút • ${workout!.exercises.length} bài tập',
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

List<double> _buildChartData(List<Workout> history) {
  if (history.isEmpty) {
    return [0];
  }

  final recent = history.take(7).toList().reversed.toList();
  return recent.map((workout) => _calculateWorkoutVolume(workout)).toList();
}

double _sumTotalVolume(List<Workout> history) {
  if (history.isEmpty) {
    return 0;
  }

  return history.fold<double>(
    0,
    (total, workout) => total + _calculateWorkoutVolume(workout),
  );
}

double _findPersonalRecord(List<Workout> history) {
  if (history.isEmpty) {
    return 0;
  }

  double best = 0;
  for (final workout in history) {
    for (final exercise in workout.exercises) {
      for (final set in exercise.sets) {
        if (set.weight > best) {
          best = set.weight;
        }
      }
    }
  }
  return best;
}

double _calculateWorkoutVolume(Workout workout) {
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

double _resolveMaxY(List<double> data) {
  final maxValue = data.reduce((a, b) => a > b ? a : b);
  if (maxValue <= 0) {
    return 100;
  }
  final interval = _resolveGridInterval(data);
  final roundedTop = (maxValue / interval).ceil() * interval;
  return roundedTop + interval;
}

double _resolveGridInterval(List<double> data) {
  final maxValue = data.reduce((a, b) => a > b ? a : b);
  if (maxValue <= 0) {
    return 20;
  }

  final roughInterval = maxValue / 4;
  return _roundToNiceInterval(roughInterval);
}

double _roundToNiceInterval(double value) {
  if (value <= 1) {
    return 1;
  }

  final exponent = value.toStringAsExponential(0).split('e');
  final base = double.parse(exponent[0]);
  final power = int.parse(exponent[1]);
  final factor = base <= 2
      ? 2
      : base <= 5
      ? 5
      : 10;

  return factor * (power >= 0 ? _pow10(power) : 1 / _pow10(-power));
}

double _pow10(int power) {
  double result = 1;
  for (var index = 0; index < power; index++) {
    result *= 10;
  }
  return result;
}

String _formatChartAxisLabel(double value) {
  if (value >= 1000) {
    final compact = value / 1000;
    return compact == compact.roundToDouble()
        ? '${compact.toInt()}k'
        : '${compact.toStringAsFixed(1)}k';
  }
  return value.toInt().toString();
}

int _calculateWorkoutStreak(List<Workout> history) {
  if (history.isEmpty) {
    return 0;
  }

  final workoutDays = history
      .map((workout) => DateTime(workout.date.year, workout.date.month, workout.date.day))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));

  final today = DateTime.now();
  DateTime pointer = DateTime(today.year, today.month, today.day);

  if (!workoutDays.contains(pointer)) {
    pointer = pointer.subtract(const Duration(days: 1));
    if (!workoutDays.contains(pointer)) {
      return 0;
    }
  }

  var streak = 0;
  while (workoutDays.contains(pointer)) {
    streak++;
    pointer = pointer.subtract(const Duration(days: 1));
  }

  return streak;
}

String _formatDate(DateTime date) {
  final d = date.day.toString().padLeft(2, '0');
  final m = date.month.toString().padLeft(2, '0');
  final y = date.year;
  return '$d/$m/$y';
}
