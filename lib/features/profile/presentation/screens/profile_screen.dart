import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weeklyTargetController = TextEditingController();
  final _targetWeightController = TextEditingController();

  static const List<String> _goalOptions = ['tăng cơ', 'giảm mỡ', 'duy trì'];
  static const List<String> _unitOptions = ['kg', 'lbs'];

  String _selectedGoal = 'duy trì';
  String _selectedUnit = 'kg';
  String _email = '';
  String? _photoUrl;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _weeklyTargetController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _bindFromProvider(ProfileProvider provider) {
    final profile = provider.profile;
    if (profile == null) {
      return;
    }

    if (_isInitialized) {
      return;
    }

    _nameController.text = profile.displayName;
    _weeklyTargetController.text = profile.weeklyTarget.toString();
    _targetWeightController.text = profile.targetWeight?.toString() ?? '';
    _selectedGoal = _goalOptions.contains(profile.goal)
        ? profile.goal
        : 'duy trì';
    _selectedUnit = _unitOptions.contains(profile.unit) ? profile.unit : 'kg';
    _email = profile.email;
    _photoUrl = profile.photoUrl;
    _isInitialized = true;
  }

  Future<void> _save(ProfileProvider provider) async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    final weeklyTarget = int.parse(_weeklyTargetController.text.trim());
    final targetWeightText = _targetWeightController.text.trim();
    final targetWeight = targetWeightText.isEmpty
        ? null
        : double.tryParse(targetWeightText);

    final message = await provider.saveProfile(
      displayName: _nameController.text,
      goal: _selectedGoal,
      unit: _selectedUnit,
      weeklyTarget: weeklyTarget,
      targetWeight: targetWeight,
    );

    if (!mounted) {
      return;
    }

    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã lưu hồ sơ thành công.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Goals')),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          _bindFromProvider(provider);

          if (provider.isLoading && provider.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.profile == null && provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(provider.errorMessage!),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: provider.refresh,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 44,
                    backgroundImage: _photoUrl != null && _photoUrl!.isNotEmpty
                        ? NetworkImage(_photoUrl!)
                        : null,
                    child: (_photoUrl == null || _photoUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 42)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _email,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tên hiển thị'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Tên người dùng không được để trống.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedGoal,
                  decoration: const InputDecoration(
                    labelText: 'Mục tiêu tập luyện',
                  ),
                  items: _goalOptions
                      .map(
                        (goal) => DropdownMenuItem<String>(
                          value: goal,
                          child: Text(goal),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedGoal = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: const InputDecoration(labelText: 'Đơn vị đo'),
                  items: _unitOptions
                      .map(
                        (unit) => DropdownMenuItem<String>(
                          value: unit,
                          child: Text(unit),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _selectedUnit = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _weeklyTargetController,
                  decoration: const InputDecoration(
                    labelText: 'Số buổi tập mỗi tuần',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final weeklyTarget = int.tryParse(value?.trim() ?? '');
                    if (weeklyTarget == null || weeklyTarget <= 0) {
                      return 'Nhập số nguyên > 0.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _targetWeightController,
                  decoration: InputDecoration(
                    labelText: 'Mức tạ mục tiêu (optional - $_selectedUnit)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return null;
                    }
                    final parsed = double.tryParse(text);
                    if (parsed == null || parsed <= 0) {
                      return 'Nhập số > 0 hoặc để trống.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: provider.isSaving ? null : () => _save(provider),
                  child: provider.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
