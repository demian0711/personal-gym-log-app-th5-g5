import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/progress_photos/presentation/screens/progress_photos_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/utilities_provider.dart';
import '../../providers/workout_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  double? _oneRmResult;

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _calculateOneRm(UtilitiesProvider utilities) {
    final weight = double.tryParse(_weightController.text.trim()) ?? 0;
    final reps = int.tryParse(_repsController.text.trim()) ?? 0;
    final result = utilities.calculateOneRepMax(weight, reps);

    setState(() {
      _oneRmResult = result > 0 ? result : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final workout = context.watch<WorkoutProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.currentUser;

    return Consumer<UtilitiesProvider>(
      builder: (context, utilities, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(user?.name ?? 'Account'),
                subtitle: Text(user?.email ?? 'No email'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Personal Data'),
                subtitle: Text(
                  'Templates: ${workout.templates.length} • History: ${workout.history.length}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.analytics_outlined),
                title: const Text('Analytics'),
                subtitle: const Text('Volume và 1RM theo thời gian'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AnalyticsScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.photo_camera_back_outlined),
                title: const Text('Progress Photos (Cloudinary)'),
                subtitle: const Text(
                  'Chụp ảnh, upload Cloudinary, lưu URL lên Firestore',
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProgressPhotosScreen(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                subtitle: const Text('Giao diện tối dễ nhìn khi dùng ban đêm'),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.setDarkMode(value);
                },
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('Delete data'),
                      content: const Text(
                        'Delete all templates and workout history for this account?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  await workout.clearAll();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Data deleted.')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete personal data'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => auth.logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rest Timer',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Auto Rest Timer'),
                      subtitle: const Text(
                        'Start timer automatically when a set is checked.',
                      ),
                      value: utilities.autoRestTimerEnabled,
                      onChanged: utilities.setAutoRestTimerEnabled,
                    ),
                    const SizedBox(height: 8),
                    Text('Duration: ${utilities.restDurationSeconds}s'),
                    Slider(
                      min: 15,
                      max: 300,
                      divisions: 19,
                      value: utilities.restDurationSeconds.toDouble(),
                      label: '${utilities.restDurationSeconds}s',
                      onChanged: (value) {
                        utilities.setRestDurationSeconds(value.toInt());
                      },
                    ),
                    if (utilities.isRestTimerRunning)
                      Text(
                        'Remaining: ${utilities.remainingRestSeconds}s',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'One Rep Max (1RM)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Reps'),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _calculateOneRm(utilities),
                      icon: const Icon(Icons.calculate),
                      label: const Text('Calculate'),
                    ),
                    if (_oneRmResult != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Estimated 1RM: ${_oneRmResult!.toStringAsFixed(1)} kg',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      const Text('Formula: weight × (1 + reps/30)'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Local Notifications',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Workout reminder (daily)'),
                      subtitle: Text(
                        'Giờ nhắc: ${utilities.workoutReminderTime.format(context)}',
                      ),
                      value: utilities.workoutReminderEnabled,
                      onChanged: (value) async {
                        await utilities.setWorkoutReminderEnabled(value);
                      },
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final selected = await showTimePicker(
                          context: context,
                          initialTime: utilities.workoutReminderTime,
                        );
                        if (selected == null) {
                          return;
                        }
                        await utilities.setWorkoutReminderTime(selected);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đã đặt giờ nhắc: ${selected.format(context)}',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.schedule_outlined),
                      label: const Text('Set reminder time'),
                    ),
                    OutlinedButton.icon(
                      onPressed: utilities.sendTestNotification,
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: const Text('Send test notification'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
