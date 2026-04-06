import '../../domain/repositories/progress_photo_repository.dart';
import '../models/progress_photo_model.dart';
import '../services/cloudinary_service.dart';
import '../services/progress_photo_firestore_service.dart';

class ProgressPhotoRepositoryImpl implements ProgressPhotoRepository {
  final CloudinaryService _cloudinaryService;
  final ProgressPhotoFirestoreService _firestoreService;

  ProgressPhotoRepositoryImpl({
    required CloudinaryService cloudinaryService,
    required ProgressPhotoFirestoreService firestoreService,
  }) : _cloudinaryService = cloudinaryService,
       _firestoreService = firestoreService;

  @override
  Future<void> uploadProgressPhoto({
    required String userId,
    required List<int> imageBytes,
    required String fileName,
    String? note,
  }) async {
    final imageUrl = await _cloudinaryService.uploadImageBytes(
      bytes: imageBytes,
      fileName: fileName,
    );

    final now = DateTime.now();
    final photo = ProgressPhotoModel(
      id: 'photo_${now.microsecondsSinceEpoch}',
      userId: userId,
      imageUrl: imageUrl,
      createdAt: now,
      note: note?.trim().isEmpty == true ? null : note?.trim(),
    );

    await _firestoreService.savePhoto(photo);
  }

  @override
  Stream<List<ProgressPhotoModel>> streamUserPhotos(String userId) {
    return _firestoreService.streamPhotos(userId);
  }

  @override
  Future<void> deletePhoto({required String photoId}) {
    return _firestoreService.deletePhoto(photoId: photoId);
  }
}
