import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/utilities_provider.dart';

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
    return Consumer<UtilitiesProvider>(
      builder: (context, utilities, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rest Timer',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Auto Rest Timer'),
                      subtitle: Text(
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
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _weightController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Weight (kg)'),
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
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Workout reminder (hourly)'),
                      value: utilities.workoutReminderEnabled,
                      onChanged: (value) async {
                        await utilities.setWorkoutReminderEnabled(value);
                      },
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
