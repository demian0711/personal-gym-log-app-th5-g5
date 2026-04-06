import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/progress_photo_model.dart';
import '../../domain/repositories/progress_photo_repository.dart';

class ProgressPhotosProvider extends ChangeNotifier {
  final ProgressPhotoRepository _repository;
  final ImagePicker _imagePicker;

  String? _userId;
  List<ProgressPhotoModel> _photos = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _errorMessage;

  ProgressPhotosProvider(this._repository, {ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  List<ProgressPhotoModel> get photos => List.unmodifiable(_photos);
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _photos.isNotEmpty;

  void bindUser(String? userId) {
    if (_userId == userId && (_photos.isNotEmpty || _errorMessage == null)) {
      return;
    }

    _userId = userId;
    _photos = [];
    _errorMessage = null;

    if (userId == null || userId.isEmpty) {
      notifyListeners();
      return;
    }

    unawaited(loadPhotos());
  }

  Future<void> loadPhotos() async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _photos = await _repository.fetchProgressPhotos(userId);
    } catch (_) {
      _errorMessage = 'Không thể tải Progress Photos.';
      _photos = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPhoto(ImageSource source) async {
    final userId = _userId;
    if (userId == null || userId.isEmpty) {
      _errorMessage = 'Không tìm thấy người dùng hiện tại.';
      notifyListeners();
      return;
    }

    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 82,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (picked == null) {
        return;
      }

      _isUploading = true;
      _errorMessage = null;
      notifyListeners();

      final photo = await _repository.uploadAndSavePhoto(
        userId: userId,
        imageFile: File(picked.path),
      );

      _photos = [photo, ..._photos];
    } catch (_) {
      _errorMessage = 'Upload ảnh thất bại. Vui lòng thử lại.';
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
