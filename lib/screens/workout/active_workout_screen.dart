import 'package:flutter/material.dart';

class ActiveWorkoutScreen extends StatelessWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            title: Text('Active Workout (Member 4)'),
            subtitle: Text(
              'TODO: DataTable sets, check set, rest timer trigger',
            ),
          ),
        ),
      ],
    );
  }
}
