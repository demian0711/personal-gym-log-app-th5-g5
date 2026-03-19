import 'package:flutter/material.dart';

class TemplateScreen extends StatelessWidget {
  const TemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            title: Text('Workout Templates (Member 3)'),
            subtitle: Text('TODO: CRUD template Push/Pull/Legs, Upper/Lower'),
          ),
        ),
      ],
    );
  }
}
