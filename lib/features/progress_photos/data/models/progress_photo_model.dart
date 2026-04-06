import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressPhotoModel {
  final String id;
  final String imageUrl;
  final DateTime createdAt;

  const ProgressPhotoModel({
    required this.id,
    required this.imageUrl,
    required this.createdAt,
  });

  factory ProgressPhotoModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};
    final timestamp = data['createdAt'];

    return ProgressPhotoModel(
      id: document.id,
      imageUrl: (data['imageUrl'] ?? '') as String,
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {'imageUrl': imageUrl, 'createdAt': Timestamp.fromDate(createdAt)};
  }
}
