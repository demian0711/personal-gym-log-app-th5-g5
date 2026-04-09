import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../features/auth/data/repositories/firebase_auth_repository.dart';
import '../features/auth/data/services/firebase_auth_service.dart';
import '../features/auth/data/services/user_firestore_service.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../models/app_user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  AppUser? _currentUser;
  bool _isLoading = false;
  bool _isInitialLoading = true;
  String? _lastError;

  AuthProvider({AuthRepository? authRepository})
    : _authRepository =
          authRepository ??
          FirebaseAuthRepository(
            authService: FirebaseAuthService(),
            userFirestoreService: UserFirestoreService(),
          ) {
    _initialize();
  }

  bool get isLoading => _isLoading;
  bool get isInitialLoading => _isInitialLoading;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  String? get lastError => _lastError;

  Future<void> _initialize() async {
    _isInitialLoading = true;
    notifyListeners();

    _currentUser = _authRepository.currentUser;
    _authRepository.authStateChanges().listen((user) {
      _currentUser = user;
      _isInitialLoading = false;
      notifyListeners();
    });

    _isInitialLoading = false;
    notifyListeners();
  }

  // Chỉ bật mock auth khi chủ động truyền:
  // flutter run --dart-define=USE_MOCK_AUTH=true
  static const bool _defaultUseMockAuth = bool.fromEnvironment(
    'USE_MOCK_AUTH',
    defaultValue: false,
  );
  bool _useMockAuth = _defaultUseMockAuth;

  Future<String?> register({
    required String name,
    required String username,
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
      if (_useMockAuth) {
        // GIẢ LẬP ĐĂNG KÝ THÀNH CÔNG
        await Future.delayed(const Duration(milliseconds: 500));
        _currentUser = AppUser(
          id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
          name: trimmedName,
          username: username.trim().toLowerCase(),
          email: normalizedEmail,
          createdAt: DateTime.now(),
        );
        return null;
      }

      final isUsernameUnique = await _isUsernameUniqueSafely(username);
      if (!isUsernameUnique) {
        return 'Tên người dùng đã tồn tại.';
      }
      _currentUser = await _authRepository.registerWithEmail(
        name: trimmedName,
        username: username.trim().toLowerCase(),
        email: normalizedEmail,
        password: trimmedPassword,
      );
      return null;
    } on FirebaseAuthException catch (error) {
      final message = _mapFirebaseAuthError(error);
      _lastError = message;
      return message;
    } on FirebaseException catch (error) {
      final message = 'Lỗi dữ liệu: ${error.message ?? error.code}';
      _lastError = message;
      return message;
    } catch (e) {
      final message = 'Lỗi không xác định: $e';
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
      if (_useMockAuth) {
        // GIẢ LẬP ĐĂNG NHẬP THÀNH CÔNG
        await Future.delayed(const Duration(milliseconds: 500));
        _currentUser = AppUser(
          id: 'mock_user_123',
          name: 'Người dùng Thử nghiệm',
          username: 'tester',
          email: normalizedEmail,
          createdAt: DateTime.now(),
        );
        return null;
      }

      _currentUser = await _authRepository.loginWithEmail(
        email: normalizedEmail,
        password: trimmedPassword,
      );
      return null;
    } on FirebaseAuthException catch (error) {
      final message = _mapFirebaseAuthError(error);
      _lastError = message;
      return message;
    } on FirebaseException catch (error) {
      final message = 'Lỗi đăng nhập: ${error.message ?? error.code}';
      _lastError = message;
      return message;
    } catch (e) {
      final message = 'Lỗi không xác định: $e';
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
        return '[Email] này chưa được đăng ký tài khoản.';
      case 'wrong-password':
      case 'invalid-credential':
        return '[Mật khẩu] không chính xác hoặc Email chưa tồn tại.';
      case 'email-already-in-use':
        return '[Email] này đã được đăng ký tài khoản khác.';
      case 'weak-password':
        return '[Mật khẩu] quá yếu (tối thiểu 6 ký tự).';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập chưa được bật trên Firebase.';
      case 'network-request-failed':
        return 'Lỗi mạng. Vui lòng kiểm tra kết nối internet.';
      default:
        return '[Email] Lỗi: ${error.message ?? error.code} (Vui lòng kiểm tra tab Authentication trên Firebase)';
    }
  }

  Future<bool> _isUsernameUniqueSafely(String username) async {
    try {
      return await _authRepository.isUsernameUnique(username);
    } on FirebaseException catch (error) {
      if (error.code == 'permission-denied') {
        debugPrint(
          'Skip username uniqueness pre-check due Firestore rules: ${error.message}',
        );
        return true;
      }
      rethrow;
    }
  }
}
