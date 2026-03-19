import 'package:flutter/material.dart';

class WorkoutHistoryScreen extends StatelessWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            title: Text('Workout History (Member 3)'),
            subtitle: Text('TODO: ListView.builder log sessions by date'),
          ),
        ),
      ],
    );
  }
}
