import 'package:flutter/material.dart';

import '../widgets/app_bottom_nav.dart';
import 'dashboard/dashboard_screen.dart';
import 'history/workout_history_screen.dart';
import 'settings/settings_screen.dart';
import 'templates/template_screen.dart';
import 'workout/active_workout_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    DashboardScreen(),
    TemplateScreen(),
    ActiveWorkoutScreen(),
    WorkoutHistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TH5 - Personal Gym Log')),
      body: SafeArea(child: _screens[_currentIndex]),
      bottomNavigationBar: AppBottomNav(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
