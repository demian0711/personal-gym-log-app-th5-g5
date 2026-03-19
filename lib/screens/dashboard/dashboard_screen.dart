import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            title: Text('Dashboard (Member 2)'),
            subtitle: Text('TODO: recent workouts + line chart (fl_chart)'),
          ),
        ),
      ],
    );
  }
}
