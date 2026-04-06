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

  const UserModel({
    required this.userId,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.goal,
    required this.unit,
    required this.weeklyTarget,
    required this.targetWeight,
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
      targetWeight: clearTargetWeight
          ? null
          : (targetWeight ?? this.targetWeight),
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
    );
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
