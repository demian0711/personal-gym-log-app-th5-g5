import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/exercise.dart';
import '../../models/exercise_set.dart';
import '../../models/workout.dart';
import '../../providers/workout_provider.dart';
import 'muscle_groups_screen.dart';
import 'qr_scanner_screen.dart';

class TemplateScreen extends StatefulWidget {
  const TemplateScreen({super.key});

  @override
  State<TemplateScreen> createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showTemplateDialog({Workout? template}) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: template?.title ?? '');
    const violetBlue = Color(0xFF3D5A80);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(template == null ? 'New Template' : 'Edit Template'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Template name',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: violetBlue),
                ),
              ),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) return 'Required';
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: violetBlue)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: violetBlue),
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;

                final provider = context.read<WorkoutProvider>();
                final now = DateTime.now();
                if (template == null) {
                  provider.addTemplate(
                    Workout(
                      id: 'template_${now.millisecondsSinceEpoch}',
                      title: titleController.text.trim(),
                      date: now,
                      exercises: const [],
                    ),
                  );
                } else {
                  provider.updateTemplate(
                    template.copyWith(title: titleController.text.trim()),
                  );
                }

                Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showExerciseDialog(Workout template) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final muscleController = TextEditingController();
    final setsController = TextEditingController();
    const violetBlue = Color(0xFF3D5A80);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Add Exercise'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Exercise name',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: violetBlue),
                    ),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: muscleController,
                  decoration: const InputDecoration(
                    labelText: 'Muscle group',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: violetBlue),
                    ),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: setsController,
                  decoration: const InputDecoration(
                    labelText: 'Number of sets',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: violetBlue),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    final parsed = int.tryParse(trimmed);
                    if (parsed == null || parsed <= 0) return 'Invalid';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: violetBlue)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: violetBlue),
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final setsCount = int.parse(setsController.text.trim());
                final now = DateTime.now();
                final exercise = Exercise(
                  id: 'exercise_${now.millisecondsSinceEpoch}',
                  name: nameController.text.trim(),
                  muscleGroup: muscleController.text.trim(),
                  sets: List.generate(
                    setsCount,
                    (index) =>
                        ExerciseSet(order: index + 1, weight: 0, reps: 0),
                  ),
                );

                final updated = template.copyWith(
                  exercises: [...template.exercises, exercise],
                );
                context.read<WorkoutProvider>().updateTemplate(updated);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditExerciseDialog(Workout template, Exercise exercise) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: exercise.name);
    final muscleController = TextEditingController(text: exercise.muscleGroup);
    final setsController = TextEditingController(
      text: exercise.sets.length.toString(),
    );
    const violetBlue = Color(0xFF3D5A80);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Edit Exercise'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Exercise name',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: violetBlue),
                    ),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: muscleController,
                  decoration: const InputDecoration(
                    labelText: 'Muscle group',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: violetBlue),
                    ),
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Required';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: setsController,
                  decoration: const InputDecoration(
                    labelText: 'Number of sets',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: violetBlue),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    final parsed = int.tryParse(trimmed);
                    if (parsed == null || parsed <= 0) return 'Invalid';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel', style: TextStyle(color: violetBlue)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: violetBlue),
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;

                final setsCount = int.parse(setsController.text.trim());
                final updatedExercise = exercise.copyWith(
                  name: nameController.text.trim(),
                  muscleGroup: muscleController.text.trim(),
                  sets: List.generate(
                    setsCount,
                    (index) =>
                        ExerciseSet(order: index + 1, weight: 0, reps: 0),
                  ),
                );

                final updated = template.copyWith(
                  exercises: template.exercises.map((item) {
                    if (item.id != exercise.id) return item;
                    return updatedExercise;
                  }).toList(),
                );

                context.read<WorkoutProvider>().updateTemplate(updated);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _removeExercise(Workout template, Exercise exercise) {
    final updated = template.copyWith(
      exercises: template.exercises
          .where((item) => item.id != exercise.id)
          .toList(),
    );
    context.read<WorkoutProvider>().updateTemplate(updated);
  }

  Future<bool> _confirmDeleteTemplate(Workout template) async {
    const violetBlue = Color(0xFF3D5A80);
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Confirm template deletion'),
          content: Text(
            'Are you sure you want to delete template "${template.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel', style: TextStyle(color: violetBlue)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade400,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _deleteTemplate(Workout template) async {
    await context.read<WorkoutProvider>().removeTemplate(template.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Template "${template.title}" deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const violetBlue = Color(0xFF3D5A80);

    final templates = context.watch<WorkoutProvider>().templates.where((t) {
      return t.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Templates'),
        actions: [
          IconButton(
            tooltip: 'General QR Scan',
            icon: const Icon(Icons.qr_code_scanner_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const QRScannerScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 16),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFF0F6B6E),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade500,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 13,
              ),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.list_alt, size: 18),
                      SizedBox(width: 8),
                      Text('My Templates'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center, size: 18),
                      SizedBox(width: 8),
                      Text('Training Guide'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTemplatesList(templates), const MuscleGroupsScreen()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTemplateDialog(),
        backgroundColor: violetBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeroImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/images/gym_banner.png',
        height: 150,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTemplatesList(List<Workout> templates) {
    final filteredTemplates = templates.where((t) {
      return t.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
    const violetBlue = Color(0xFF3D5A80);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeroImage(),
        const SizedBox(height: 16),
        SearchBar(
          backgroundColor: MaterialStateProperty.all(
            violetBlue.withOpacity(0.1),
          ),
          elevation: MaterialStateProperty.all(0),
          hintText: 'Search templates by name...',
          leading: const Icon(Icons.search),
          trailing: _searchQuery.isNotEmpty
              ? [
                  IconButton(
                    tooltip: 'Clear search',
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    icon: const Icon(Icons.close),
                  ),
                ]
              : null,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        const SizedBox(height: 14),
        if (templates.isEmpty)
          Card(
            color: violetBlue.withOpacity(0.1),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No templates yet. Create one to start workouts.'),
            ),
          ),
        if (templates.isNotEmpty && filteredTemplates.isEmpty)
          Card(
            color: violetBlue.withOpacity(0.1),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No templates match your search keyword.'),
            ),
          ),
        for (final template in filteredTemplates)
          Dismissible(
            key: ValueKey('template_${template.id}'),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => _confirmDeleteTemplate(template),
            onDismissed: (_) => _deleteTemplate(template),
            background: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.red.shade400,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              color: violetBlue.withOpacity(0.1),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            template.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () =>
                              _showTemplateDialog(template: template),
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () async {
                            final confirmed = await _confirmDeleteTemplate(
                              template,
                            );
                            if (!confirmed) return;
                            await _deleteTemplate(template);
                          },
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Exercises: ${template.exercises.length}'),
                    const SizedBox(height: 12),
                    if (template.exercises.isEmpty)
                      const Text('No exercises yet. Add one below.'),
                    for (final exercise in template.exercises)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(exercise.name),
                        subtitle: Text(
                          '${exercise.muscleGroup} • ${exercise.sets.length} sets',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () =>
                                  _showEditExerciseDialog(template, exercise),
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: () =>
                                  _removeExercise(template, exercise),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: violetBlue,
                          ),
                          onPressed: () => _showExerciseDialog(template),
                          icon: const Icon(Icons.add),
                          label: const Text('Add Exercise'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
