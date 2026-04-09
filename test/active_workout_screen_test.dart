import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:personal_gym_log_app_th5_g5/models/exercise.dart';
import 'package:personal_gym_log_app_th5_g5/models/exercise_set.dart';
import 'package:personal_gym_log_app_th5_g5/models/workout.dart';
import 'package:personal_gym_log_app_th5_g5/providers/utilities_provider.dart';
import 'package:personal_gym_log_app_th5_g5/providers/workout_provider.dart';
import 'package:personal_gym_log_app_th5_g5/screens/workout/active_workout_screen.dart';

class _FakeWorkoutProvider extends ChangeNotifier implements WorkoutProvider {
  _FakeWorkoutProvider({
    List<Workout> templates = const [],
    List<Workout> history = const [],
  }) : _templates = List<Workout>.from(templates),
       _history = List<Workout>.from(history);

  final List<Workout> _templates;
  final List<Workout> _history;

  @override
  List<Workout> get templates => List<Workout>.unmodifiable(_templates);

  @override
  List<Workout> get history => List<Workout>.unmodifiable(_history);

  @override
  bool get isLoading => false;

  @override
  bool get isSyncing => false;

  @override
  String? get lastError => null;

  @override
  Workout? get activeWorkout => null;

  @override
  bool get hasActiveWorkout => false;

  @override
  Future<void> addWorkoutLog(Workout workout) async {
    _history.insert(0, workout);
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUtilitiesProvider extends ChangeNotifier
    implements UtilitiesProvider {
  _FakeUtilitiesProvider({
    bool autoRestTimerEnabled = true,
    int restDurationSeconds = 90,
  }) : _autoRestTimerEnabled = autoRestTimerEnabled,
       _restDurationSeconds = restDurationSeconds;

  bool _autoRestTimerEnabled;
  int _restDurationSeconds;
  int _remainingRestSeconds = 0;
  bool _workoutReminderEnabled = false;
  TimeOfDay _workoutReminderTime = const TimeOfDay(hour: 19, minute: 0);

  @override
  bool get autoRestTimerEnabled => _autoRestTimerEnabled;

  @override
  int get restDurationSeconds => _restDurationSeconds;

  @override
  int get remainingRestSeconds => _remainingRestSeconds;

  @override
  bool get isRestTimerRunning => _remainingRestSeconds > 0;

  @override
  bool get workoutReminderEnabled => _workoutReminderEnabled;

  @override
  TimeOfDay get workoutReminderTime => _workoutReminderTime;

  @override
  void setAutoRestTimerEnabled(bool value) {
    _autoRestTimerEnabled = value;
    notifyListeners();
  }

  @override
  void setRestDurationSeconds(int value) {
    _restDurationSeconds = value;
    notifyListeners();
  }

  @override
  void startRestTimer() {
    if (!_autoRestTimerEnabled) {
      return;
    }
    _remainingRestSeconds = _restDurationSeconds;
    notifyListeners();
  }

  @override
  void stopRestTimer() {
    _remainingRestSeconds = 0;
    notifyListeners();
  }

  @override
  double calculateOneRepMax(double weight, int reps) {
    if (weight <= 0 || reps <= 0) {
      return 0;
    }
    return weight * (1 + reps / 30);
  }

  @override
  Future<void> setWorkoutReminderEnabled(bool value) async {
    _workoutReminderEnabled = value;
    notifyListeners();
  }

  @override
  Future<void> setWorkoutReminderTime(TimeOfDay time) async {
    _workoutReminderTime = time;
    notifyListeners();
  }

  @override
  Future<void> sendTestNotification() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Workout _buildTemplateWorkout() {
  return Workout(
    id: 'template_push_day',
    title: 'Push Day',
    date: DateTime(2026, 4, 9),
    exercises: const [
      Exercise(
        id: 'bench_press',
        name: 'Bench Press',
        muscleGroup: 'Ngực',
        sets: [
          ExerciseSet(order: 1, weight: 0, reps: 0),
        ],
      ),
    ],
  );
}

Workout _buildHistoryWorkout() {
  return Workout(
    id: 'history_1',
    title: 'Push Day',
    date: DateTime(2026, 4, 8),
    exercises: const [
      Exercise(
        id: 'bench_press_history',
        name: 'Bench Press',
        muscleGroup: 'Ngực',
        sets: [
          ExerciseSet(order: 1, weight: 80, reps: 8, isCompleted: true),
        ],
      ),
    ],
  );
}

Future<void> _pumpWorkoutScreen(
  WidgetTester tester, {
  required _FakeWorkoutProvider workoutProvider,
  required _FakeUtilitiesProvider utilitiesProvider,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<WorkoutProvider>.value(value: workoutProvider),
        ChangeNotifierProvider<UtilitiesProvider>.value(value: utilitiesProvider),
      ],
      child: const MaterialApp(
        home: Scaffold(body: ActiveWorkoutScreen()),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

Future<void> _startWorkout(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.arrow_drop_down));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Push Day').last);
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('start_workout_button')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tick Done thì rest timer chạy', (tester) async {
    final workoutProvider = _FakeWorkoutProvider(
      templates: [_buildTemplateWorkout()],
    );
    final utilitiesProvider = _FakeUtilitiesProvider(restDurationSeconds: 90);

    await _pumpWorkoutScreen(
      tester,
      workoutProvider: workoutProvider,
      utilitiesProvider: utilitiesProvider,
    );
    await _startWorkout(tester);

    final formFields = find.byType(TextFormField);
    await tester.enterText(formFields.at(0), '100');
    await tester.enterText(formFields.at(1), '8');
    await tester.pump();

    await tester.tap(find.byKey(const Key('toggle_set_bench_press_1')));
    await tester.pumpAndSettle();

    expect(utilitiesProvider.isRestTimerRunning, isTrue);
    expect(find.text('Đang nghỉ giữa hiệp'), findsOneWidget);
    expect(find.text('Còn 90 / 90 giây'), findsOneWidget);
  });

  testWidgets('có history thì hiện Lần trước đúng set', (tester) async {
    final workoutProvider = _FakeWorkoutProvider(
      templates: [_buildTemplateWorkout()],
      history: [_buildHistoryWorkout()],
    );
    final utilitiesProvider = _FakeUtilitiesProvider();

    await _pumpWorkoutScreen(
      tester,
      workoutProvider: workoutProvider,
      utilitiesProvider: utilitiesProvider,
    );
    await _startWorkout(tester);

    expect(find.text('Buổi gần nhất: 08/04'), findsOneWidget);
    expect(find.text('Lần trước: 80 kg'), findsOneWidget);
    expect(find.text('Lần trước: 8'), findsOneWidget);
  });
}
