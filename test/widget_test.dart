import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:personal_gym_log_app_th5_g5/features/profile/data/models/user_model.dart';
import 'package:personal_gym_log_app_th5_g5/features/profile/domain/repositories/profile_repository.dart';
import 'package:personal_gym_log_app_th5_g5/features/profile/presentation/providers/profile_provider.dart';
import 'package:personal_gym_log_app_th5_g5/features/auth/domain/repositories/auth_repository.dart';
import 'package:personal_gym_log_app_th5_g5/models/app_user.dart';
import 'package:personal_gym_log_app_th5_g5/providers/auth_provider.dart';
import 'package:personal_gym_log_app_th5_g5/screens/auth/auth_gate.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<AppUser?> authStateChanges() => Stream<AppUser?>.value(null);

  @override
  AppUser? get currentUser => null;

  @override
  Future<AppUser> loginWithEmail({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppUser?> loginWithGoogle() async => null;

  @override
  Future<void> logout() async {}

  @override
  Future<AppUser> registerWithEmail({
    required String name,
    required String username,
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isUsernameUnique(String username) async => true;
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<UserModel> fetchOrCreateProfile({
    required String userId,
    required String email,
    required String fallbackDisplayName,
    String? photoUrl,
  }) async {
    return UserModel(
      userId: userId,
      email: email,
      displayName: fallbackDisplayName,
      photoUrl: photoUrl,
      goal: 'maintain',
      unit: 'kg',
      weeklyTarget: 3,
      targetWeight: null,
    );
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async => user;

  @override
  Future<UserModel> updateProfilePhoto(
    String userId,
    List<int> bytes,
    String fileName,
  ) async {
    return UserModel(
      userId: userId,
      email: '',
      displayName: '',
      photoUrl: null,
      goal: 'maintain',
      unit: 'kg',
      weeklyTarget: 3,
      targetWeight: null,
    );
  }
}

void main() {
  testWidgets('Auth gate shows login screen when signed out', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => AuthProvider(authRepository: _FakeAuthRepository()),
          ),
          ChangeNotifierProvider(
            create: (_) => ProfileProvider(_FakeProfileRepository()),
          ),
        ],
        child: const MaterialApp(home: AuthGate()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
