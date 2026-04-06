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
              const SizedBox(height: 32),
              const Text(
                'Mục tiêu tập luyện',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Mục tiêu chính',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                value: 'Tăng cơ', // Giá trị mặc định ban đầu
                items:
                    ['Tăng cơ', 'Giảm mỡ', 'Duy trì vóc dáng', 'Tăng sức mạnh']
                        .map(
                          (goal) =>
                              DropdownMenuItem(value: goal, child: Text(goal)),
                        )
                        .toList(),
                onChanged: (value) {
                  // Xử lý khi người dùng chọn mục tiêu khác
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.number,
                // Thêm validator bắt lỗi cho ô này luôn cho xịn
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập';
                  if (int.tryParse(value) == null) return 'Chỉ nhập số nguyên';
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'Số buổi tập mục tiêu (buổi/tuần)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_month),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double
                    .infinity, // Kéo dài nút ra cho dễ bấm bằng 1 tay (chuẩn đề cương)
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // Kích hoạt kiểm tra lỗi (Validator)
                    if (_formKey.currentState!.validate()) {
                      // Nếu không có lỗi đỏ nào, hiện thông báo thành công!
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Đã lưu thông tin hồ sơ thành công! 🚀',
                          ),
                          backgroundColor:
                              Colors.green, // Hiện màu xanh lá cho đẹp
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Lưu thông tin',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
