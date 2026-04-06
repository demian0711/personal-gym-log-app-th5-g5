import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/data/services/profile_firestore_service.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/utilities_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/auth/auth_gate.dart';
import 'services/local_storage_service.dart';

class PersonalGymLogApp extends StatelessWidget {
  const PersonalGymLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = LocalStorageService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(storage)),
        ChangeNotifierProxyProvider<AuthProvider, WorkoutProvider>(
          create: (_) => WorkoutProvider(storage),
          update: (_, auth, workout) {
            final provider = workout ?? WorkoutProvider(storage);
            provider.bindUser(auth.currentUser?.id);
            return provider;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, ProfileProvider>(
          create: (_) =>
              ProfileProvider(ProfileRepositoryImpl(ProfileFirestoreService())),
          update: (_, auth, profile) {
            final provider =
                profile ??
                ProfileProvider(
                  ProfileRepositoryImpl(ProfileFirestoreService()),
                );
            provider.bindUser(
              userId: auth.currentUser?.id,
              email: auth.currentUser?.email ?? '',
              fallbackDisplayName: auth.currentUser?.name ?? '',
            );
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => UtilitiesProvider()),
      ],
      child: MaterialApp(
        title: 'Personal Gym Log',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}
