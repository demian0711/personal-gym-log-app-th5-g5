import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  
  String? _usernameError;
  String? _emailError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() {
      _usernameError = null;
      _emailError = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final error = await auth.register(
      name: _nameController.text,
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error != null) {
      setState(() {
        if (error.contains('Tên người dùng')) {
          _usernameError = error;
        } else if (error.contains('[Email]')) {
          _emailError = error.replaceAll('[Email] ', '').replaceAll('[Email]', '');
        } else if (error.contains('[Mật khẩu]')) {
          // Show password error directly under confirm password for visibility if needed
          // or just under password. Here we use a generic email error as fallback if unsure.
          _emailError = error.replaceAll('[Mật khẩu] ', '').replaceAll('[Mật khẩu]', '');
        } else {
          _emailError = error;
        }
      });
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authLoading = context.watch<AuthProvider>().isLoading;
    final disabled = _isSubmitting || authLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tạo tài khoản mới',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Dữ liệu luyện tập sẽ được lưu riêng theo tài khoản.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Họ tên',
                          ),
                          validator: (value) {
                            if ((value?.trim() ?? '').isEmpty) return 'Nhập họ tên';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Tên người dùng (Username)',
                            hintText: 'VD: ngoctrang.22',
                            helperText: '6-30 ký tự, chữ cái, số, dấu chấm.',
                            errorText: _usernameError,
                          ),
                          onChanged: (_) {
                            if (_usernameError != null) {
                              setState(() => _usernameError = null);
                            }
                          },
                          validator: (value) {
                            final username = value?.trim() ?? '';
                            if (username.isEmpty) return 'Bắt buộc nhập Username';
                            if (username.length < 6 || username.length > 30) {
                              return 'Username từ 6-30 ký tự';
                            }
                            final regex = RegExp(r'^[a-z0-9.]+$');
                            if (!regex.hasMatch(username.toLowerCase())) {
                              return 'Chỉ dùng chữ cái (a-z), số (0-9) và dấu chấm (.)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            errorText: _emailError,
                          ),
                          onChanged: (_) {
                            if (_emailError != null) {
                              setState(() => _emailError = null);
                            }
                          },
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) return 'Bắt buộc nhập Email';
                            final gmailRegex = RegExp(r'^[\w-\.]+@gmail\.com$');
                            if (!gmailRegex.hasMatch(trimmed.toLowerCase())) {
                              return 'Email phải đúng cú pháp @gmail.com';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Mật khẩu',
                          ),
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) {
                              return 'Nhập mật khẩu';
                            }
                            if (trimmed.length < 6) {
                              return 'Tối thiểu 6 ký tự';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _confirmController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Nhập lại mật khẩu',
                          ),
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) {
                              return 'Nhập lại mật khẩu';
                            }
                            if (trimmed != _passwordController.text.trim()) {
                              return 'Mật khẩu không khớp';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: disabled ? null : _handleRegister,
                            child: Text(
                              disabled ? 'Đang tạo...' : 'Tạo tài khoản',
                            ),
                          ),
                        ),
                      ],
                    ),
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
