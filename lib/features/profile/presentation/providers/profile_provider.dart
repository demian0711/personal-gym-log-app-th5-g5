import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/user_model.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  UserModel? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  String? _boundUserId;
  String _boundEmail = '';
  String _boundFallbackDisplayName = '';
  String? _boundPhotoUrl;

  ProfileProvider(this._repository);

  UserModel? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  /// Bind theo user hiện tại từ AuthProvider.
  ///
  /// Nếu user chưa có document trong Firestore thì tự tạo default document.
  void bindUser({
    required String? userId,
    required String email,
    required String fallbackDisplayName,
    String? photoUrl,
  }) {
    if (userId == null || userId.isEmpty) {
      _boundUserId = null;
      _boundEmail = '';
      _boundFallbackDisplayName = '';
      _boundPhotoUrl = null;
      _profile = null;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    final unchanged =
        _boundUserId == userId &&
        _boundEmail == email &&
        _boundFallbackDisplayName == fallbackDisplayName &&
        _boundPhotoUrl == photoUrl;

    if (unchanged && _profile != null) {
      return;
    }

    _boundUserId = userId;
    _boundEmail = email;
    _boundFallbackDisplayName = fallbackDisplayName;
    _boundPhotoUrl = photoUrl;

    unawaited(_loadProfile());
  }

  Future<void> refresh() => _loadProfile();

  Future<String?> saveProfile({
    required String displayName,
    required String goal,
    required String unit,
    required int weeklyTarget,
    double? targetWeight,
  }) async {
    final userId = _boundUserId;
    if (userId == null) {
      return 'Không tìm thấy người dùng hiện tại.';
    }

    final trimmedName = displayName.trim();
    if (trimmedName.isEmpty) {
      return 'Tên người dùng không được để trống.';
    }

    if (weeklyTarget <= 0) {
      return 'Số buổi tập mỗi tuần phải lớn hơn 0.';
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final current =
          _profile ??
          UserModel(
            userId: userId,
            email: _boundEmail,
            displayName: _boundFallbackDisplayName,
            photoUrl: _boundPhotoUrl,
            goal: 'duy trì',
            unit: 'kg',
            weeklyTarget: 3,
            targetWeight: null,
          );

      final updated = current.copyWith(
        displayName: trimmedName,
        goal: goal,
        unit: unit,
        weeklyTarget: weeklyTarget,
        targetWeight: targetWeight,
        clearTargetWeight: targetWeight == null,
      );

      _profile = await _repository.updateProfile(updated);
      return null;
    } catch (_) {
      _errorMessage = 'Không thể lưu hồ sơ. Vui lòng thử lại.';
      return _errorMessage;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> _loadProfile() async {
    final userId = _boundUserId;
    if (userId == null) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _repository.fetchOrCreateProfile(
        userId: userId,
        email: _boundEmail,
        fallbackDisplayName: _boundFallbackDisplayName,
        photoUrl: _boundPhotoUrl,
      );
    } catch (_) {
      _errorMessage = 'Không thể tải hồ sơ. Vui lòng thử lại.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
