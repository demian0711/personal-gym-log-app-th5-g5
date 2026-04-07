import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/auth/data/repositories/firebase_auth_repository.dart';
import '../features/auth/data/services/firebase_auth_service.dart';
import '../features/auth/data/services/user_firestore_service.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  AppUser? _currentUser;
  bool _isLoading = true;
  String? _lastError;

  AuthProvider({AuthRepository? authRepository})
    : _authRepository =
          authRepository ??
          FirebaseAuthRepository(
            authService: FirebaseAuthService(),
            userFirestoreService: UserFirestoreService(),
          ) {
    // Load auth state asynchronously
    Future.delayed(const Duration(milliseconds: 300)).then((_) {
      _initialize();
    });
  }

  bool get isLoading => _isLoading;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  String? get lastError => _lastError;

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = _authRepository.currentUser;
    _authRepository.authStateChanges().listen((user) {
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    });

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

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.registerWithEmail(
        name: trimmedName,
        email: normalizedEmail,
        password: trimmedPassword,
      );
      return null;
    } on FirebaseAuthException catch (error) {
      final message = _mapFirebaseAuthError(error);
      _lastError = message;
      return message;
    } catch (_) {
      const message = 'Không thể tạo tài khoản. Vui lòng thử lại.';
      _lastError = message;
      return message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.loginWithEmail(
        email: normalizedEmail,
        password: trimmedPassword,
      );
      return null;
    } on FirebaseAuthException catch (error) {
      final message = _mapFirebaseAuthError(error);
      _lastError = message;
      return message;
    } catch (_) {
      const message = 'Không thể đăng nhập. Vui lòng thử lại.';
      _lastError = message;
      return message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> loginWithGoogle() async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final user = await _authRepository.loginWithGoogle();
      if (user == null) {
        _isLoading = false;
        notifyListeners();
        return 'Bạn đã hủy đăng nhập Google.';
      }
      _currentUser = user;
      return null;
    } on FirebaseAuthException catch (error) {
      final message = _mapFirebaseAuthError(error);
      _lastError = message;
      return message;
    } catch (_) {
      const message = 'Đăng nhập Google thất bại. Vui lòng thử lại.';
      _lastError = message;
      return message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.logout();
      _currentUser = null;
      _lastError = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa.';
      case 'user-not-found':
        return 'Không tìm thấy tài khoản.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Email đã được đăng ký.';
      case 'weak-password':
        return 'Mật khẩu quá yếu (ít nhất 6 ký tự).';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập chưa được bật trên Firebase.';
      case 'network-request-failed':
        return 'Lỗi mạng. Vui lòng kiểm tra kết nối internet.';
      default:
        return error.message ?? 'Có lỗi xác thực xảy ra.';
    }
  }
}
