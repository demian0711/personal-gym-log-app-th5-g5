import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/progress_photo_repository.dart';
import '../models/progress_photo_model.dart';
import '../services/cloudinary_service.dart';

class ProgressPhotoRepositoryImpl implements ProgressPhotoRepository {
  final FirebaseFirestore _firestore;
  final CloudinaryService _cloudinaryService;

  ProgressPhotoRepositoryImpl({
    FirebaseFirestore? firestore,
    required CloudinaryService cloudinaryService,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _cloudinaryService = cloudinaryService;

  CollectionReference<Map<String, dynamic>> _photosCollection(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('progress_photos');
  }

  @override
  Future<List<ProgressPhotoModel>> fetchProgressPhotos(String userId) async {
    final snapshot = await _photosCollection(
      userId,
    ).orderBy('createdAt', descending: true).get();

    return snapshot.docs.map(ProgressPhotoModel.fromFirestore).toList();
  }

  @override
  Future<ProgressPhotoModel> uploadAndSavePhoto({
    required String userId,
    required File imageFile,
  }) async {
    final imageUrl = await _cloudinaryService.uploadToCloudinary(imageFile);

    final now = Timestamp.now();
    final docRef = await _photosCollection(
      userId,
    ).add({'imageUrl': imageUrl, 'createdAt': FieldValue.serverTimestamp()});

    final savedDoc = await docRef.get();
    final data = savedDoc.data() ?? <String, dynamic>{};
    final createdAt = data['createdAt'] is Timestamp
        ? data['createdAt'] as Timestamp
        : now;

    return ProgressPhotoModel(
      id: docRef.id,
      imageUrl: imageUrl,
      createdAt: createdAt.toDate(),
    );
  }
}
