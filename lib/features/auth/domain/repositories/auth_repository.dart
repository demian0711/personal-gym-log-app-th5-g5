import '../../../../models/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  Future<AppUser> loginWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<AppUser?> loginWithGoogle();

  Future<void> logout();
}
