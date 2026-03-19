import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            title: Text('Settings & Utilities (Member 5)'),
            subtitle: Text('TODO: unit, profile, notifications, 1RM tool'),
          ),
        ),
      ],
    );
  }
}
