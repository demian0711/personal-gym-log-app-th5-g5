import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/progress_photos/presentation/screens/progress_photos_screen.dart';
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
  int _smartTargetReps = 8;
  String? _selectedExerciseName;

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

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _confidenceLabel(int score) {
    if (score >= 80) return 'High';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Medium';
    return 'Low';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final workout = context.watch<WorkoutProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final profile = profileProvider.profile;
    final user = auth.currentUser;
    final displayName = profile?.displayName ?? user?.name ?? 'Account';
    final email = profile?.email ?? user?.email ?? 'No email';
    final photoUrl = profile?.photoUrl;

    return Consumer<UtilitiesProvider>(
      builder: (context, utilities, _) {
        final smartSuggestions = utilities.buildSmartOneRmSuggestions(
          workout.history,
          targetReps: _smartTargetReps,
          maxItems: 8,
        );
        final effectiveSelectedExercise =
            (smartSuggestions.any(
                  (item) => item.exerciseName == _selectedExerciseName,
                ))
            ? _selectedExerciseName
            : (smartSuggestions.isNotEmpty
                  ? smartSuggestions.first.exerciseName
                  : null);
        final selectedSuggestion =
            effectiveSelectedExercise == null
            ? null
            : utilities.buildExerciseOneRmSuggestion(
                workout.history,
                effectiveSelectedExercise,
                targetReps: _smartTargetReps,
              );

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null ? const Icon(Icons.person) : null,
                ),
                title: Text(displayName),
                subtitle: Text(email),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.bar_chart),
                title: const Text('Personal data'),
                subtitle: Text(
                  'Templates: ${workout.templates.length} - History: ${workout.history.length}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.analytics_outlined),
                title: const Text('Advanced analytics'),
                subtitle: const Text('Volume and 1RM trend over time'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const AnalyticsScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.photo_camera_back_outlined),
                title: const Text('Progress photos (Cloudinary)'),
                subtitle: const Text('Track physique changes by photo timeline'),
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
                title: const Text('Dark mode'),
                subtitle: const Text('Use a darker theme for low-light viewing'),
                value: themeProvider.isDarkMode,
                onChanged: themeProvider.setDarkMode,
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
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(dialogContext).pop(true),
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
                      const SnackBar(content: Text('All workout data deleted.')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Delete personal data'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: auth.logout,
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
                      'Rest timer',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Auto start timer'),
                      subtitle: const Text(
                        'Start countdown right after a completed set.',
                      ),
                      value: utilities.autoRestTimerEnabled,
                      onChanged: utilities.setAutoRestTimerEnabled,
                    ),
                    const SizedBox(height: 8),
                    Text('Duration: ${utilities.restDurationSeconds} seconds'),
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
                        'Remaining: ${utilities.remainingRestSeconds} seconds',
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
                      'One Rep Max (manual)',
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
                      const Text('Formula: weight x (1 + reps/30)'),
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
                    Row(
                      children: [
                        Text(
                          'Smart 1RM Coach',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Tooltip(
                          message:
                              'Auto prediction from completed workout logs using Epley.',
                          child: Icon(Icons.info_outline, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Reads training history and suggests safe working weight for your target reps.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    if (smartSuggestions.isEmpty)
                      const Text(
                        'Not enough completed sets yet. Finish a few workouts to unlock smart suggestions.',
                      ),
                    if (smartSuggestions.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        initialValue: effectiveSelectedExercise,
                        decoration: const InputDecoration(
                          labelText: 'Exercise',
                          border: OutlineInputBorder(),
                        ),
                        items: smartSuggestions
                            .map(
                              (item) => DropdownMenuItem<String>(
                                value: item.exerciseName,
                                child: Text(item.exerciseName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedExerciseName = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Text('Target reps: $_smartTargetReps'),
                      Slider(
                        min: 3,
                        max: 12,
                        divisions: 9,
                        value: _smartTargetReps.toDouble(),
                        label: '$_smartTargetReps reps',
                        onChanged: (value) {
                          setState(() {
                            _smartTargetReps = value.toInt();
                          });
                        },
                      ),
                    ],
                    if (selectedSuggestion != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _MetricTile(
                              label: 'Predicted 1RM',
                              value:
                                  '${selectedSuggestion.estimatedOneRm.toStringAsFixed(1)} kg',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              label: 'Suggested load',
                              value:
                                  '${selectedSuggestion.suggestedWeight.toStringAsFixed(1)} kg',
                              subtitle: 'for $_smartTargetReps reps',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Chip(
                            avatar: const Icon(Icons.verified, size: 16),
                            label: Text(
                              'Confidence ${selectedSuggestion.confidenceScore}% (${_confidenceLabel(selectedSuggestion.confidenceScore)})',
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            avatar: const Icon(Icons.dataset_outlined, size: 16),
                            label: Text('Samples ${selectedSuggestion.sampleCount}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Best logged set: ${selectedSuggestion.bestSample.weight.toStringAsFixed(1)} kg x ${selectedSuggestion.bestSample.reps} reps '
                        '(${_formatDate(selectedSuggestion.bestSample.workoutDate)})',
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedSuggestion.recommendationByReps.entries
                            .map(
                              (entry) => Chip(
                                label: Text(
                                  '${entry.key} reps: ${entry.value.toStringAsFixed(1)} kg',
                                ),
                              ),
                            )
                            .toList(),
                      ),
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
                      'Local notifications',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Daily workout reminder'),
                      subtitle: Text(
                        'Reminder time: ${utilities.workoutReminderTime.format(context)}',
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
                                'Reminder set to ${selected.format(context)}',
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

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;

  const _MetricTile({
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.outline.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
