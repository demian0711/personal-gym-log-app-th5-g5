import 'package:cloud_firestore/cloud_firestore.dart';

/// User model dùng cho module Profile & Goals.
///
/// Lưu ý: `targetWeight` là optional theo yêu cầu.
class UserModel {
  final String userId;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String goal;
  final String unit;
  final int weeklyTarget;
  final double? targetWeight;
  final double? height;
  final double? currentWeight;
  final double? chest;
  final double? waist;
  final double? hips;
  final Map<int, String> weeklyPlan; // Map<Ngày trong tuần (1-7), Tên bài tập/Mục tiêu>

  const UserModel({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.goal,
    required this.unit,
    required this.weeklyTarget,
    required this.targetWeight,
    this.height,
    this.currentWeight,
    this.chest,
    this.waist,
    this.hips,
    this.weeklyPlan = const {},
  });

  UserModel copyWith({
    String? userId,
    String? email,
    String? displayName,
    String? photoUrl,
    String? goal,
    String? unit,
    int? weeklyTarget,
    double? targetWeight,
    double? height,
    double? currentWeight,
    double? chest,
    double? waist,
    double? hips,
    Map<int, String>? weeklyPlan,
    bool clearPhotoUrl = false,
    bool clearTargetWeight = false,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      goal: goal ?? this.goal,
      unit: unit ?? this.unit,
      weeklyTarget: weeklyTarget ?? this.weeklyTarget,
      targetWeight: clearTargetWeight ? null : (targetWeight ?? this.targetWeight),
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      chest: chest ?? this.chest,
      waist: waist ?? this.waist,
      hips: hips ?? this.hips,
      weeklyPlan: weeklyPlan ?? this.weeklyPlan,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'goal': goal,
      'unit': unit,
      'weeklyTarget': weeklyTarget,
      'targetWeight': targetWeight,
      'height': height,
      'currentWeight': currentWeight,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'weeklyPlan': weeklyPlan.map((key, value) => MapEntry(key.toString(), value)),
    };
  }

  static UserModel fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};
    return UserModel(
      userId: document.id,
      email: (data['email'] ?? '') as String,
      displayName: (data['displayName'] ?? '') as String,
      photoUrl: data['photoUrl'] as String?,
      goal: (data['goal'] ?? 'duy trì') as String,
      unit: (data['unit'] ?? 'kg') as String,
      weeklyTarget: _toInt(data['weeklyTarget'], defaultValue: 3),
      targetWeight: _toDoubleOrNull(data['targetWeight']),
      height: _toDoubleOrNull(data['height']),
      currentWeight: _toDoubleOrNull(data['currentWeight']),
      chest: _toDoubleOrNull(data['chest']),
      waist: _toDoubleOrNull(data['waist']),
      hips: _toDoubleOrNull(data['hips']),
      weeklyPlan: _toWeeklyPlan(data['weeklyPlan']),
    );
  }

  static Map<int, String> _toWeeklyPlan(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value.map((key, val) => MapEntry(int.tryParse(key) ?? 0, val.toString()));
    }
    return {};
  }

  static int _toInt(dynamic value, {required int defaultValue}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return defaultValue;
  }

  static double? _toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return null;
  }
}
