import 'dart:io';

import '../../data/models/progress_photo_model.dart';

abstract class ProgressPhotoRepository {
  Future<List<ProgressPhotoModel>> fetchProgressPhotos(String userId);

  Future<ProgressPhotoModel> uploadAndSavePhoto({
    required String userId,
    required File imageFile,
  });
}
