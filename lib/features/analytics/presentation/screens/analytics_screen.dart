import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/services/analytics_service.dart';
import '../providers/analytics_provider.dart';
import '../widgets/analytics_line_chart.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && !provider.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: provider.loadAnalytics,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!provider.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Chưa có dữ liệu workout để phân tích.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final metric = provider.metric;
          final metricLabel = metric == AnalyticsMetric.volume ? 'Volume' : '1RM';
          final latestDate = provider.latestDate;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MetricToggle(
                metric: metric,
                onChanged: provider.setMetric,
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$metricLabel theo thời gian',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 12),
                      AnalyticsLineChart(
                        data: provider.chartData,
                        metric: metric,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Summary',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Max $metricLabel: ${provider.maxValue.toStringAsFixed(1)}',
                      ),
                      Text(
                        'Latest $metricLabel: ${provider.latestValue.toStringAsFixed(1)}'
                        '${latestDate != null ? ' (${_formatDate(latestDate)})' : ''}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MetricToggle extends StatelessWidget {
  final AnalyticsMetric metric;
  final ValueChanged<AnalyticsMetric> onChanged;

  const _MetricToggle({
    required this.metric,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: [
        metric == AnalyticsMetric.volume,
        metric == AnalyticsMetric.oneRm,
      ],
      onPressed: (index) {
        if (index == 0) {
          onChanged(AnalyticsMetric.volume);
          return;
        }
        onChanged(AnalyticsMetric.oneRm);
      },
      constraints: const BoxConstraints(minHeight: 42, minWidth: 120),
      borderRadius: BorderRadius.circular(10),
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('Volume'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('1RM'),
        ),
      ],
    );
  }
}

String _formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year;
  return '$day/$month/$year';
}
