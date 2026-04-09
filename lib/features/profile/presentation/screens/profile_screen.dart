import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../domain/constants/profile_goal_options.dart';
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
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();

  static const List<String> _goalOptions = ProfileGoalOptions.labels;
  static const List<String> _unitOptions = ['kg', 'lbs'];

  String _selectedGoal = ProfileGoalOptions.defaultGoal;
  String _selectedUnit = 'kg';
  String _email = '';
  String? _photoUrl;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _weeklyTargetController.dispose();
    _targetWeightController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
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
    _heightController.text = profile.height?.toString() ?? '';
    _weightController.text = profile.currentWeight?.toString() ?? '';
    _chestController.text = profile.chest?.toString() ?? '';
    _waistController.text = profile.waist?.toString() ?? '';
    _hipsController.text = profile.hips?.toString() ?? '';
    _selectedGoal = ProfileGoalOptions.normalize(profile.goal);
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
      height: double.tryParse(_heightController.text),
      currentWeight: double.tryParse(_weightController.text),
      chest: double.tryParse(_chestController.text),
      waist: double.tryParse(_waistController.text),
      hips: double.tryParse(_hipsController.text),
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

  Future<void> _showPhotoOptions(
    BuildContext context,
    ProfileProvider provider,
  ) async {
    final picker = ImagePicker();
    await showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Chụp ảnh'),
              onTap: () async {
                Navigator.pop(sheetContext);
                final image = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  final bytes = await image.readAsBytes();
                  await provider.updateProfilePhoto(bytes, image.name);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Chọn từ thư viện'),
              onTap: () async {
                Navigator.pop(sheetContext);
                final image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  final bytes = await image.readAsBytes();
                  await provider.updateProfilePhoto(bytes, image.name);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ & mục tiêu')),
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
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundImage:
                            _photoUrl != null && _photoUrl!.isNotEmpty
                            ? NetworkImage(_photoUrl!)
                            : null,
                        child: (_photoUrl == null || _photoUrl!.isEmpty)
                            ? const Icon(Icons.person, size: 42)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _showPhotoOptions(context, provider),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                const SizedBox(height: 16),
                _buildSectionLabel(context, 'Thông số cơ bản'),
                const SizedBox(height: 12),
                _buildMeasurementField(
                  context,
                  label: 'Chiều cao',
                  controller: _heightController,
                  icon: Icons.height,
                  suffix: 'cm',
                ),
                const SizedBox(height: 12),
                _buildMeasurementField(
                  context,
                  label: 'Cân nặng hiện tại',
                  controller: _weightController,
                  icon: Icons.monitor_weight_outlined,
                  suffix: _selectedUnit,
                ),
                const SizedBox(height: 12),
                _buildMeasurementField(
                  context,
                  label: 'Cân nặng mục tiêu',
                  controller: _targetWeightController,
                  icon: Icons.ads_click,
                  suffix: _selectedUnit,
                ),
                const SizedBox(height: 24),
                _buildSectionLabel(context, 'Số đo cơ thể (cm)'),
                const SizedBox(height: 12),
                _buildMeasurementField(
                  context,
                  label: 'Ngực',
                  controller: _chestController,
                  icon: Icons.compress,
                ),
                const SizedBox(height: 12),
                _buildMeasurementField(
                  context,
                  label: 'Eo',
                  controller: _waistController,
                  icon: Icons.settings_ethernet,
                ),
                const SizedBox(height: 12),
                _buildMeasurementField(
                  context,
                  label: 'Hông',
                  controller: _hipsController,
                  icon: Icons.unfold_more,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: provider.isSaving ? null : () => _save(provider),
                  child: provider.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Lưu'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildMeasurementField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String suffix = 'cm',
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: IconButton(
          icon: Icon(
            icon,
            size: 22,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () =>
              _showNumberPicker(context, label, controller, suffix),
          tooltip: 'Chọn nhanh $label',
        ),
        suffixText: suffix,
      ),
    );
  }

  void _showNumberPicker(
    BuildContext context,
    String title,
    TextEditingController controller,
    String suffix,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          height: 400,
          child: Column(
            children: [
              Text(
                'Chọn $title ($suffix)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: 500,
                  itemBuilder: (context, index) {
                    final val = index + 1;
                    return ListTile(
                      title: Text('$val $suffix', textAlign: TextAlign.center),
                      onTap: () {
                        controller.text = val.toString();
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
