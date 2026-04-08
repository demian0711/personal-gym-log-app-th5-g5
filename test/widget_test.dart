import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

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

void main() {
  testWidgets('Auth gate shows login screen when signed out', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(authRepository: _FakeAuthRepository()),
        child: const MaterialApp(home: AuthGate()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Đăng nhập'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
  });
}
