import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressPhotoModel {
  final String id;
  final String userId;
  final String imageUrl;
  final DateTime createdAt;
  final String? goal;
  final String? standard;
  final double? weight;
  final String? note;

  const ProgressPhotoModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.createdAt,
    this.goal,
    this.standard,
    this.weight,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'goal': goal,
      'standard': standard,
      'weight': weight,
      'note': note,
    };
  }

  factory ProgressPhotoModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawCreatedAt = data['createdAt'];

    DateTime createdAt;
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }

    return ProgressPhotoModel(
      id: doc.id,
      userId: (data['userId'] ?? '') as String,
      imageUrl: (data['imageUrl'] ?? '') as String,
      createdAt: createdAt,
      goal: data['goal'] as String?,
      standard: data['standard'] as String?,
      weight: (data['weight'] as num?)?.toDouble(),
      note: data['note'] as String?,
    );
  }
}
