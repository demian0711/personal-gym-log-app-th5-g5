import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/workout_model.dart';
import '../../domain/services/analytics_service.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsService _service;

  String? _userId;
  bool _isLoading = false;
  String? _errorMessage;
  AnalyticsMetric _metric = AnalyticsMetric.volume;

  List<WorkoutModel> _workouts = [];
  List<AnalyticsDataPoint> _chartData = [];

  AnalyticsProvider(this._service);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AnalyticsMetric get metric => _metric;
  List<AnalyticsDataPoint> get chartData => List.unmodifiable(_chartData);
  bool get hasData => _chartData.isNotEmpty;

  double get maxValue {
    if (_chartData.isEmpty) return 0;
    return _chartData
        .map((point) => point.value)
        .reduce((current, next) => current > next ? current : next);
  }

  double get latestValue {
    if (_chartData.isEmpty) return 0;
    return _chartData.last.value;
  }

  DateTime? get latestDate {
    if (_chartData.isEmpty) return null;
    return _chartData.last.date;
  }

  void bindUser(String? userId) {
    if (_userId == userId && (_workouts.isNotEmpty || _errorMessage == null)) {
      return;
    }

    _userId = userId;
    _workouts = [];
    _chartData = [];
    _errorMessage = null;

    if (userId == null || userId.isEmpty) {
      notifyListeners();
      return;
    }

    unawaited(loadAnalytics());
  }

  Future<void> loadAnalytics() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _workouts = await _service.fetchWorkouts(userId);
      _rebuildChartData();
    } catch (_) {
      _errorMessage = 'Không thể tải dữ liệu phân tích từ Firestore.';
      _chartData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setMetric(AnalyticsMetric value) {
    if (_metric == value) {
      return;
    }
    _metric = value;
    _rebuildChartData();
    notifyListeners();
  }

  void updateFromWorkouts(List<WorkoutModel> workouts) {
    _workouts = workouts;
    _rebuildChartData();
    notifyListeners();
  }

  void _rebuildChartData() {
    _chartData = _service.mapToChartData(workouts: _workouts, metric: _metric);
  }
}
