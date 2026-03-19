import 'package:flutter/foundation.dart';
import '../models/workout.dart';
import '../services/local_storage_service.dart';

class WorkoutProvider extends ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  
  List<Workout> _templates = [];
  List<Workout> _history = [];

  List<Workout> get templates => List.unmodifiable(_templates);
  List<Workout> get history => List.unmodifiable(_history);

  // Load data from DB
  Future<void> loadData() async {
    _templates = await _storage.getAllTemplates();
    _history = await _storage.getAllWorkoutLogs();
    notifyListeners();
  }

  Future<void> addTemplate(Workout template) async {
    _templates.add(template);
    await _storage.saveTemplate(template);
    notifyListeners();
  }

  Future<void> removeTemplate(String id) async {
    _templates.removeWhere((template) => template.id == id);
    await _storage.deleteTemplate(id);
    notifyListeners();
  }

  Future<void> addWorkoutLog(Workout workout) async {
    _history.insert(0, workout);
    await _storage.saveWorkoutLog(workout);
    notifyListeners();
  }

  Future<void> clearAll() async {
    for (var t in _templates) {
      await _storage.deleteTemplate(t.id);
    }
    for (var h in _history) {
      await _storage.deleteWorkoutLog(h.id);
    }
    _templates.clear();
    _history.clear();
    notifyListeners();
  }
}
