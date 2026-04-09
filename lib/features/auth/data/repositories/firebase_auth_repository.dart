import 'package:firebase_auth/firebase_auth.dart';

import '../../../../models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../services/firebase_auth_service.dart';
import '../services/user_firestore_service.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuthService _authService;
  final UserFirestoreService _userFirestoreService;

  FirebaseAuthRepository({
    required FirebaseAuthService authService,
    required UserFirestoreService userFirestoreService,
  }) : _authService = authService,
       _userFirestoreService = userFirestoreService;

  @override
  Stream<AppUser?> authStateChanges() {
    return _authService.authStateChanges().map(_mapUser);
  }

  @override
  AppUser? get currentUser => _mapUser(_authService.currentUser);

  @override
  Future<AppUser> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final appUser = _mapUser(credential.user);
    if (appUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Không tìm thấy thông tin người dùng.',
      );
    }

    await _userFirestoreService.upsertUserDocument(
      uid: appUser.id,
      email: appUser.email,
      displayName: appUser.name,
      photoUrl: appUser.photoUrl,
      authProvider: 'email',
    );

    return appUser;
  }

  @override
  Future<AppUser> registerWithEmail({
    required String name,
    required String username,
    required String email,
    required String password,
  }) async {
    final credential = await _authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _authService.updateDisplayName(name);

    final refreshedUser = _authService.currentUser ?? credential.user;
    final appUser = _mapUser(refreshedUser);
    if (appUser == null) {
      throw FirebaseAuthException(
        code: 'operation-not-allowed',
        message: 'Không thể khởi tạo tài khoản.',
      );
    }

    await _userFirestoreService.upsertUserDocument(
      uid: appUser.id,
      username: username,
      email: appUser.email,
      displayName: appUser.name,
      photoUrl: appUser.photoUrl,
      authProvider: 'email',
    );

    return appUser;
  }

  @override
  Future<AppUser?> loginWithGoogle() async {
    final credential = await _authService.signInWithGoogle();
    if (credential == null) return null;

    final appUser = _mapUser(credential.user);
    if (appUser == null) {
      throw FirebaseAuthException(
        code: 'operation-not-allowed',
        message: 'Không thể đăng nhập Google.',
      );
    }

    await _userFirestoreService.upsertUserDocument(
      uid: appUser.id,
      email: appUser.email,
      displayName: appUser.name,
      photoUrl: appUser.photoUrl,
      authProvider: 'google',
    );

    return appUser;
  }

  @override
  Future<void> logout() {
    return _authService.signOut();
  }

  @override
  Future<bool> isUsernameUnique(String username) {
    return _userFirestoreService.isUsernameUnique(username);
  }

  AppUser? _mapUser(User? user) {
    if (user == null) return null;

    final normalizedDisplayName = (user.displayName ?? '').trim().isEmpty
        ? user.email?.split('@').first ?? 'Gym User'
        : user.displayName!.trim();

    return AppUser(
      id: user.uid,
      username: null, // Sẽ được load từ Firestore qua ProfileProvider
      name: normalizedDisplayName,
      email: user.email ?? '',
      photoUrl: user.photoURL,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }
}
