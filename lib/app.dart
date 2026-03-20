import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/workout_provider.dart';
import 'screens/app_shell.dart';

class PersonalGymLogApp extends StatelessWidget {
  const PersonalGymLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider()..loadData(),
        ),
      ],
      child: MaterialApp(
        title: 'Personal Gym Log',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AppShell(),
      ),
    );
  }
}
