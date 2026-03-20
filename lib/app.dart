import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/auth/auth_gate.dart';
import 'services/local_storage_service.dart';

class PersonalGymLogApp extends StatelessWidget {
  final LocalStorageService storageService;

  const PersonalGymLogApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: storageService),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(storageService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, WorkoutProvider>(
          create: (_) => WorkoutProvider(storageService),
          update: (_, auth, workout) {
            final provider = workout ?? WorkoutProvider(storageService);
            provider.bindUser(auth.currentUser?.id);
            return provider;
          },
        ),
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
