import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/progress_photos/presentation/screens/progress_photos_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
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
    final profileProvider = context.watch<ProfileProvider>();
    final workout = context.watch<WorkoutProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    
    final profile = profileProvider.profile;
    final user = auth.currentUser;
    
    final displayName = profile?.displayName ?? user?.name ?? 'Tài khoản';
    final email = profile?.email ?? user?.email ?? 'Không có email';
    final photoUrl = profile?.photoUrl;

    return Consumer<UtilitiesProvider>(
      builder: (context, utilities, _) {
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
                title: const Text('Phân tích chuyên sâu'),
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
                title: const Text('Ảnh tiến trình (Cloudinary)'),
                subtitle: const Text(
                  'Theo dõi sự thay đổi hình thể qua ảnh',
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
                subtitle: const Text('Giao diện tối giúp bảo vệ mắt'),
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
                      title: const Text('Xóa dữ liệu'),
                      content: const Text(
                        'Bạn có chắc chắn muốn xóa toàn bộ mẫu tập và lịch sử cho tài khoản này?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                          child: const Text('Hủy'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(dialogContext).pop(true),
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
                      const SnackBar(content: Text('Đã xóa toàn bộ dữ liệu.')),
                    );
                  }
                }
              },
              icon: const Icon(Icons.delete_outline),
              label: const Text('Xóa dữ liệu cá nhân'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => auth.logout(),
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
                        'Bắt đầu đếm ngược ngay khi hoàn thành một hiệp.',
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
                        labelText: 'Khối lượng (kg)',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Số lần (reps)'),
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
                        'Ước tính 1RM: ${_oneRmResult!.toStringAsFixed(1)} kg',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      const Text('Công thức: khối lượng × (1 + reps/30)'),
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
                      'Thông báo địa phương',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Nhắc nhở tập luyện (hàng ngày)'),
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
                      label: const Text('Đặt giờ nhắc nhở'),
                    ),
                    OutlinedButton.icon(
                      onPressed: utilities.sendTestNotification,
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: const Text('Gửi thông báo thử nghiệm'),
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
