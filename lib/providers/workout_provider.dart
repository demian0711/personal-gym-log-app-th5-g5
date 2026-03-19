import 'package:flutter/foundation.dart';

import '../models/workout.dart';

class WorkoutProvider extends ChangeNotifier {
  final List<Workout> _templates = [];
  final List<Workout> _history = [];

  List<Workout> get templates => List.unmodifiable(_templates);
  List<Workout> get history => List.unmodifiable(_history);

  void addTemplate(Workout template) {
    _templates.add(template);
    notifyListeners();
  }

  void removeTemplate(String id) {
    _templates.removeWhere((template) => template.id == id);
    notifyListeners();
  }

  void addWorkoutLog(Workout workout) {
    _history.insert(0, workout);
    notifyListeners();
  }

  void clearAll() {
    _templates.clear();
    _history.clear();
    notifyListeners();
  }
}
