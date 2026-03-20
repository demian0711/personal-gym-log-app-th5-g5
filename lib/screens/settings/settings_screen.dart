import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/workout_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final workout = context.watch<WorkoutProvider>();
    final user = auth.currentUser;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(user?.name ?? 'Tài khoản'),
            subtitle: Text(user?.email ?? 'Không có email'),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Dữ liệu cá nhân'),
            subtitle: Text(
              'Templates: ${workout.templates.length} • Lịch sử: ${workout.history.length}',
            ),
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
                    'Bạn có chắc muốn xóa toàn bộ templates và lịch sử của tài khoản này?',
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
              workout.clearAll();
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
          onPressed: () => auth.logout(),
          icon: const Icon(Icons.logout),
          label: const Text('Đăng xuất'),
        ),
      ],
    );
  }
}
