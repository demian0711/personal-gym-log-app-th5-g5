import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/progress_photo_model.dart';
import '../../domain/repositories/progress_photo_repository.dart';

class ProgressPhotoProvider extends ChangeNotifier {
  final ProgressPhotoRepository _repository;

  ProgressPhotoProvider(this._repository);

  String? _userId;
  StreamSubscription<List<ProgressPhotoModel>>? _subscription;

  List<ProgressPhotoModel> _photos = [];
  bool _isUploading = false;
  String? _errorMessage;

  List<ProgressPhotoModel> get photos => List.unmodifiable(_photos);
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  void bindUser(String? userId) {
    if (_userId == userId) {
      return;
    }

    _userId = userId;
    _subscription?.cancel();
    _photos = [];
    _errorMessage = null;

    if (userId == null || userId.isEmpty) {
      notifyListeners();
      return;
    }

    _subscription = _repository
        .streamUserPhotos(userId)
        .listen(
          (items) {
            _photos = items;
            notifyListeners();
          },
          onError: (_) {
            _errorMessage = 'Không thể tải ảnh tiến trình.';
            notifyListeners();
          },
        );
  }

  Future<String?> uploadPhoto({
    required List<int> imageBytes,
    required String fileName,
    String? note,
  }) async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      return 'Bạn chưa đăng nhập.';
    }

    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.uploadProgressPhoto(
        userId: userId,
        imageBytes: imageBytes,
        fileName: fileName,
        note: note,
      );
      return null;
    } catch (error) {
      final rawMessage = error.toString();
      _errorMessage = rawMessage;

      final normalized = rawMessage.toLowerCase();
      if (normalized.contains('upload preset not found')) {
        return 'Không tìm thấy upload preset trên Cloudinary. '
            'Hãy mở Cloudinary > Settings > Upload > Upload presets, '
            'tạo preset Unsigned và nhấn Save.';
      }

      if (normalized.contains('must be unsigned')) {
        return 'Upload preset hiện tại chưa phải Unsigned. '
            'Hãy chỉnh Signing mode = Unsigned trong Cloudinary.';
      }

      return 'Upload ảnh thất bại. Kiểm tra lại Cloud name/preset trong màn hình này.';
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> deletePhoto(String photoId) async {
    await _repository.deletePhoto(photoId: photoId);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
