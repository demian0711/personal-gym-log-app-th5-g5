import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/profile/presentation/providers/profile_provider.dart';

import '../providers/auth_provider.dart';
import '../providers/utilities_provider.dart';
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
  late final UtilitiesProvider _utilitiesProvider;

  static const List<Widget> _screens = [
    DashboardScreen(),
    TemplateScreen(),
    ActiveWorkoutScreen(),
    WorkoutHistoryScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _utilitiesProvider = UtilitiesProvider();
  }

  @override
  void dispose() {
    _utilitiesProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = context.watch<ProfileProvider>().profile;
    final userName = profile?.displayName ?? context.watch<AuthProvider>().currentUser?.name;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('TH5 - Personal Gym Log'),
            if (userName != null && userName.isNotEmpty)
              Text(
                'Xin chào, $userName',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colorScheme.surface, colorScheme.surfaceContainerLowest],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ChangeNotifierProvider<UtilitiesProvider>.value(
          value: _utilitiesProvider,
          child: SafeArea(child: _screens[_currentIndex]),
        ),
      ),
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
