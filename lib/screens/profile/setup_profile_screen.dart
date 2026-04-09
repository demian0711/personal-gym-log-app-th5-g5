import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../features/profile/domain/constants/profile_goal_options.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  final _chestController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();
  String _selectedGoal = ProfileGoalOptions.defaultGoal;
  int _weeklyTarget = 3;
  final Map<int, String> _weeklyPlan = {};

  final List<String> _daysOfWeek = [
    'Thứ 2',
    'Thứ 3',
    'Thứ 4',
    'Thứ 5',
    'Thứ 6',
    'Thứ 7',
    'Chủ nhật',
  ];

  final List<String> _goals = ProfileGoalOptions.labels;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    if (profile != null) {
      _nameController.text = profile.displayName;
      _selectedGoal = ProfileGoalOptions.normalize(profile.goal);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _chestController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ProfileProvider>();
    final error = await provider.saveProfile(
      displayName: _nameController.text,
      goal: _selectedGoal,
      unit: 'kg',
      weeklyTarget: _weeklyTarget,
      height: double.tryParse(_heightController.text),
      currentWeight: double.tryParse(_weightController.text),
      targetWeight: double.tryParse(_targetWeightController.text),
      chest: double.tryParse(_chestController.text),
      waist: double.tryParse(_waistController.text),
      hips: double.tryParse(_hipsController.text),
      weeklyPlan: _weeklyPlan,
    );

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    } else if (mounted) {
      // Chuyển hướng sau khi lưu thành công
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final provider = context.read<ProfileProvider>();

    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Chụp ảnh mới'),
            onTap: () async {
              Navigator.pop(sheetContext);
              final image = await picker.pickImage(source: ImageSource.camera);
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
              final image = await picker.pickImage(source: ImageSource.gallery);
              if (image != null) {
                final bytes = await image.readAsBytes();
                await provider.updateProfilePhoto(bytes, image.name);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primaryContainer.withOpacity(0.3),
              colorScheme.surface,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Chào mừng bạn!',
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hãy hoàn thiện hồ sơ để bắt đầu hành trình tập luyện chuyên nghiệp.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Stack(
                      children: [
                        Consumer<ProfileProvider>(
                          builder: (context, provider, _) {
                            final photoUrl = provider.profile?.photoUrl;
                            return CircleAvatar(
                              radius: 50,
                              backgroundColor: colorScheme.surfaceVariant,
                              backgroundImage: photoUrl != null
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: photoUrl == null
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: colorScheme.onSurfaceVariant,
                                    )
                                  : null,
                            );
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: colorScheme.primary,
                            child: IconButton(
                              icon: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                              onPressed: () => _pickImage(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionTitle('Thông tin cơ bản'),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Họ và tên',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 16),
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
                    label: 'Cân nặng',
                    controller: _weightController,
                    icon: Icons.monitor_weight_outlined,
                    suffix: 'kg',
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Số đo cơ thể (cm)'),
                  const SizedBox(height: 16),
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

                  const SizedBox(height: 32),
                  _buildSectionTitle('Mục tiêu của bạn'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGoal,
                    decoration: const InputDecoration(
                      labelText: 'Mục tiêu chính',
                      prefixIcon: Icon(Icons.flag_outlined),
                    ),
                    items: _goals
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedGoal = v!),
                  ),
                  const SizedBox(height: 16),
                  _buildMeasurementField(
                    context,
                    label: 'Cân nặng mục tiêu',
                    controller: _targetWeightController,
                    icon: Icons.ads_click,
                    suffix: 'kg',
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Tần suất tập luyện'),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            '$_weeklyTarget buổi / tuần',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                          Slider(
                            value: _weeklyTarget.toDouble(),
                            min: 1,
                            max: 7,
                            divisions: 6,
                            onChanged: (v) =>
                                setState(() => _weeklyTarget = v.toInt()),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chọn các ngày mong muốn:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 0,
                            children: List.generate(7, (index) {
                              final dayIndex = index + 1;
                              final isSelected = _weeklyPlan.containsKey(
                                dayIndex,
                              );
                              return FilterChip(
                                label: Text(_daysOfWeek[index]),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _weeklyPlan[dayIndex] = 'Tập luyện';
                                    } else {
                                      _weeklyPlan.remove(dayIndex);
                                    }
                                  });
                                },
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: context.watch<ProfileProvider>().isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Bắt đầu ngay',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
