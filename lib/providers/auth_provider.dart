import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  List<AppUser> _users = [];
  AppUser? _currentUser;
  bool _isLoading = true;

  AuthProvider(this._storage) {
    _initialize();
  }

  bool get isLoading => _isLoading;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    _users = await _storage.getUsers();
    final activeUserId = await _storage.getActiveUserId();
    _currentUser = _findUserById(activeUserId);

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final trimmedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    if (trimmedName.isEmpty ||
        normalizedEmail.isEmpty ||
        trimmedPassword.isEmpty) {
      return 'Vui lòng nhập đầy đủ thông tin.';
    }

    final existing = _users.any(
      (user) => user.email.toLowerCase() == normalizedEmail,
    );
    if (existing) {
      return 'Email đã được đăng ký.';
    }

    final now = DateTime.now();
    final user = AppUser(
      id: 'user_${now.millisecondsSinceEpoch}',
      name: trimmedName,
      email: normalizedEmail,
      passwordHash: _hashPassword(trimmedPassword),
      createdAt: now,
    );

    _users = [..._users, user];
    _currentUser = user;

    await _storage.saveUsers(_users);
    await _storage.setActiveUserId(user.id);

    notifyListeners();
    return null;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedPassword = password.trim();

    if (normalizedEmail.isEmpty || trimmedPassword.isEmpty) {
      return 'Vui lòng nhập email và mật khẩu.';
    }

    final user = _findUserByEmail(normalizedEmail);
    if (user == null) {
      return 'Không tìm thấy tài khoản.';
    }

    if (user.passwordHash != _hashPassword(trimmedPassword)) {
      return 'Mật khẩu không đúng.';
    }

    _currentUser = user;
    await _storage.setActiveUserId(user.id);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _currentUser = null;
    await _storage.setActiveUserId(null);
    notifyListeners();
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  AppUser? _findUserByEmail(String normalizedEmail) {
    for (final user in _users) {
      if (user.email.toLowerCase() == normalizedEmail) {
        return user;
      }
    }
    return null;
  }

  AppUser? _findUserById(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final user in _users) {
      if (user.id == id) {
        return user;
      }
    }
    return null;
  }
}
