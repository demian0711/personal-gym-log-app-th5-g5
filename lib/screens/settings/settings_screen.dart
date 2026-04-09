import 'package:flutter/foundation.dart';
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
    if (score >= 80) return 'Cao';
    if (score >= 60) return 'Tốt';
    if (score >= 40) return 'Trung bình';
    return 'Thấp';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final workout = context.watch<WorkoutProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final profile = profileProvider.profile;
    final user = auth.currentUser;
    final supportsLocalNotifications = !kIsWeb;

    final displayName = profile?.displayName ?? user?.name ?? 'Tài khoản';
    final email = profile?.email ?? user?.email ?? 'Không có email';
    final photoUrl = profile?.photoUrl;

    return Consumer<UtilitiesProvider>(
      builder: (context, utilities, _) {
        final smartSuggestions = utilities.buildSmartOneRmSuggestions(
          workout.history,
          targetReps: _smartTargetReps,
          maxItems: 8,
        );

        final effectiveSelectedExercise =
            smartSuggestions.any(
              (item) => item.exerciseName == _selectedExerciseName,
            )
            ? _selectedExerciseName
            : (smartSuggestions.isNotEmpty
                  ? smartSuggestions.first.exerciseName
                  : null);

        final selectedSuggestion = effectiveSelectedExercise == null
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
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                      ? NetworkImage(photoUrl)
                      : null,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(displayName),
                subtitle: Text(email),
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
                title: const Text('Dữ liệu cá nhân'),
                subtitle: Text(
                  'Mẫu tập: ${workout.templates.length} • Lịch sử: ${workout.history.length}',
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.analytics_outlined),
                title: const Text('Phân tích'),
                subtitle: const Text('Khối lượng và 1RM theo thời gian'),
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
                title: const Text('Ảnh tiến độ (Cloudinary)'),
                subtitle: const Text(
                  'Theo dõi sự thay đổi cơ thể qua hình ảnh',
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
                title: const Text('Chế độ tối'),
                subtitle: const Text('Giao diện tối dễ nhìn khi dùng ban đêm'),
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
                      title: const Text('Xóa dữ liệu'),
                      content: const Text(
                        'Xóa tất cả mẫu tập và lịch sử tập luyện của tài khoản này?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(false),
                          child: const Text('Hủy'),
                        ),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(true),
                          child: const Text('Xóa'),
                        ),
                      ],
                    );
                  },
                );

                if (confirm == true) {
                  await workout.clearAll();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã xóa dữ liệu.')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Xóa dữ liệu cá nhân'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: auth.logout,
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hẹn giờ nghỉ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Tự động hẹn giờ'),
                      subtitle: const Text(
                        'Bắt đầu hẹn giờ tự động khi hoàn thành một hiệp.',
                      ),
                      value: utilities.autoRestTimerEnabled,
                      onChanged: utilities.setAutoRestTimerEnabled,
                    ),
                    const SizedBox(height: 8),
                    Text('Thời gian: ${utilities.restDurationSeconds} giây'),
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
                        'Còn lại: ${utilities.remainingRestSeconds} giây',
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
                    Row(
                      children: [
                        Text(
                          'Smart 1RM Coach',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        const Tooltip(
                          message:
                              'Dự đoán tự động từ lịch sử tập có đánh dấu hoàn thành.',
                          child: Icon(Icons.info_outline, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Gợi ý mức tạ an toàn cho số reps mục tiêu dựa trên dữ liệu thật của bạn.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 14),
                    if (smartSuggestions.isEmpty)
                      const Text(
                        'Chưa đủ dữ liệu set hoàn thành. Hãy tập thêm vài buổi để mở khóa gợi ý thông minh.',
                      ),
                    if (smartSuggestions.isNotEmpty) ...[
                      DropdownButtonFormField<String>(
                        initialValue: effectiveSelectedExercise,
                        decoration: const InputDecoration(
                          labelText: 'Bài tập',
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
                      Text('Reps mục tiêu: $_smartTargetReps'),
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
                              label: '1RM dự đoán',
                              value:
                                  '${selectedSuggestion.estimatedOneRm.toStringAsFixed(1)} kg',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MetricTile(
                              label: 'Mức tạ đề xuất',
                              value:
                                  '${selectedSuggestion.suggestedWeight.toStringAsFixed(1)} kg',
                              subtitle: 'cho $_smartTargetReps reps',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.verified, size: 16),
                            label: Text(
                              'Độ tin cậy ${selectedSuggestion.confidenceScore}% (${_confidenceLabel(selectedSuggestion.confidenceScore)})',
                            ),
                          ),
                          Chip(
                            avatar: const Icon(
                              Icons.dataset_outlined,
                              size: 16,
                            ),
                            label: Text(
                              'Mẫu dữ liệu ${selectedSuggestion.sampleCount}',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Set tốt nhất: ${selectedSuggestion.bestSample.weight.toStringAsFixed(1)} kg × ${selectedSuggestion.bestSample.reps} reps (${_formatDate(selectedSuggestion.bestSample.workoutDate)})',
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedSuggestion
                            .recommendationByReps
                            .entries
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
                      'Sức mạnh tối đa (1RM)',
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
                        labelText: 'Trọng lượng (kg)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Số lần (reps)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => _calculateOneRm(utilities),
                      icon: const Icon(Icons.calculate),
                      label: const Text('Tính toán'),
                    ),
                    if (_oneRmResult != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        '1RM ước tính: ${_oneRmResult!.toStringAsFixed(1)} kg',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      const Text('Công thức: Trọng lượng × (1 + reps/30)'),
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
                      'Thông báo nhắc nhở',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Nhắc nhở tập luyện (hàng ngày)'),
                      subtitle: Text(
                        supportsLocalNotifications
                            ? 'Giờ nhắc: ${utilities.workoutReminderTime.format(context)}'
                            : 'Tính năng này hiện chỉ hỗ trợ trên mobile.',
                      ),
                      value: utilities.workoutReminderEnabled,
                      onChanged: supportsLocalNotifications
                          ? (value) async {
                              await utilities.setWorkoutReminderEnabled(value);
                            }
                          : null,
                    ),
                    OutlinedButton.icon(
                      onPressed: supportsLocalNotifications
                          ? () async {
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
                            }
                          : null,
                      icon: const Icon(Icons.schedule_outlined),
                      label: const Text('Set reminder time'),
                    ),
                    OutlinedButton.icon(
                      onPressed: supportsLocalNotifications
                          ? utilities.sendTestNotification
                          : null,
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

  const _MetricTile({required this.label, required this.value, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
