import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../app_shell.dart';
import '../profile/setup_profile_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, ProfileProvider>(
      builder: (context, auth, profileProvider, _) {
        if (auth.isInitialLoading || profileProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!auth.isAuthenticated) {
          return const LoginScreen();
        }

        final profile = profileProvider.profile;
        
        // Nếu đã auth nhưng chưa có hồ sơ hoặc hồ sơ chưa hoàn thiện (thiếu chiều cao/cân nặng)
        // thì bắt buộc chuyển đến màn hình setup
        if (profile == null || profile.height == null || profile.currentWeight == null) {
          return const SetupProfileScreen();
        }

        return const AppShell();
      },
    );
  }
}
