import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Trang Dương');
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ & Mục tiêu')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin cá nhân',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // --- Ô NHẬP CHIỀU CAO ĐÃ CÓ VALIDATOR ---
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      keyboardType: TextInputType.number,
                      // ĐÂY LÀ ĐOẠN CHẶN LỖI (VALIDATOR)
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Trống!'; // Báo lỗi nếu chưa nhập gì
                        }
                        if (double.tryParse(value) == null) {
                          return 'Chỉ nhập số'; // Báo lỗi nếu nhập chữ cái
                        }
                        return null; // Không có lỗi gì
                      },
                      decoration: const InputDecoration(
                        labelText: 'Chiều cao (cm)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.height),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16), // Khoảng cách giữa 2 ô
                  // --- Ô NHẬP CÂN NẶNG ĐÃ CÓ VALIDATOR ---
                  Expanded(
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      // ĐÂY LÀ ĐOẠN CHẶN LỖI (VALIDATOR)
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Trống!';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Chỉ nhập số';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Cân nặng (kg)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.monitor_weight),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
