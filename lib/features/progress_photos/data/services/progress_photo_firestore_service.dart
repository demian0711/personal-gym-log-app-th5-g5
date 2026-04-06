import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/progress_photo_model.dart';

class ProgressPhotoFirestoreService {
  final FirebaseFirestore _firestore;

  ProgressPhotoFirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('progress_photos');

  Future<void> savePhoto(ProgressPhotoModel photo) {
    return _collection.doc(photo.id).set(photo.toMap());
  }

  Stream<List<ProgressPhotoModel>> streamPhotos(String userId) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ProgressPhotoModel.fromFirestore)
              .where((photo) => photo.imageUrl.isNotEmpty)
              .toList(),
        );
  }

  Future<void> deletePhoto({required String photoId}) {
    return _collection.doc(photoId).delete();
  }
}
