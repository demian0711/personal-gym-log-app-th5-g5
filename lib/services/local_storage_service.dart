import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _workoutsBoxName = 'workouts';
  static const String _templatesBoxName = 'templates';
  static const String _settingsBoxName = 'settings';

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_workoutsBoxName);
    await Hive.openBox(_templatesBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  // ==========================================
  // --- NHẬT KÝ TẬP LUYỆN (WORKOUT LOGS) ---
  // ==========================================

  /// Thêm hoặc cập nhật nhật ký tập luyện (CREATE / UPDATE)
  Future<void> saveWorkoutLog(Workout workout) async {
    final box = Hive.box(_workoutsBoxName);
    await box.put(workout.id, workout.toMap());
  }

  /// Đọc toàn bộ nhật ký tập luyện (READ)
  Future<List<Workout>> getAllWorkoutLogs() async {
    final box = Hive.box(_workoutsBoxName);
    final List<Workout> logs = box.values
        .map((map) => Workout.fromMap(Map<String, dynamic>.from(map)))
        .toList();
    
    // Sắp xếp: Buổi tập mới nhất lên đầu
    logs.sort((a, b) => b.date.compareTo(a.date));
    return logs;
  }

  /// Xóa nhật ký tập luyện (DELETE)
  Future<void> deleteWorkoutLog(String id) async {
    final box = Hive.box(_workoutsBoxName);
    await box.delete(id);
  }

  // ==========================================
  // --- LỊCH TẬP MẪU (TEMPLATES) ---
  // ==========================================

  /// Thêm hoặc cập nhật lịch tập mẫu (CREATE / UPDATE)
  Future<void> saveTemplate(Workout template) async {
    final box = Hive.box(_templatesBoxName);
    await box.put(template.id, template.toMap());
  }

  /// Đọc toàn bộ danh sách lịch tập mẫu (READ)
  Future<List<Workout>> getAllTemplates() async {
    final box = Hive.box(_templatesBoxName);
    return box.values
        .map((map) => Workout.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  /// Xóa lịch tập mẫu (DELETE)
  Future<void> deleteTemplate(String id) async {
    final box = Hive.box(_templatesBoxName);
    await box.delete(id);
  }

  // ==========================================
  // --- CÀI ĐẶT HỆ THỐNG (SETTINGS) ---
  // ==========================================

  /// Lưu đơn vị cân nặng (kg/lbs)
  Future<void> saveUnit(String unit) async {
    final box = Hive.box(_settingsBoxName);
    await box.put('unit', unit);
  }

  /// Đọc đơn vị cân nặng
  Future<String> getUnit() async {
    final box = Hive.box(_settingsBoxName);
    return box.get('unit', defaultValue: 'kg') as String;
  }
}
