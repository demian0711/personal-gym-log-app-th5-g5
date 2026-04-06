import '../../data/models/progress_photo_model.dart';

abstract class ProgressPhotoRepository {
  Future<void> uploadProgressPhoto({
    required String userId,
    required List<int> imageBytes,
    required String fileName,
    String? note,
  });

  Stream<List<ProgressPhotoModel>> streamUserPhotos(String userId);

  Future<void> deletePhoto({required String photoId});
}
