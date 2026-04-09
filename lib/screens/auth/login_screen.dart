import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String? _emailError;
  String? _passwordError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final error = await auth.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error != null) {
      setState(() {
        if (error.contains('[Email]')) {
          _emailError = error.replaceAll('[Email] ', '').replaceAll('[Email]', '');
        } else if (error.contains('[Mật khẩu]')) {
          _passwordError = error.replaceAll('[Mật khẩu] ', '').replaceAll('[Mật khẩu]', '');
        } else {
          // Fallback
          _emailError = error;
        }
      });
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isSubmitting = true);

    final auth = context.read<AuthProvider>();
    final error = await auth.loginWithGoogle();

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final authLoading = context.watch<AuthProvider>().isLoading;
    final disabled = _isSubmitting || authLoading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(textTheme),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            errorText: _emailError,
                            helperText: 'VD: example@gmail.com',
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
                              return 'Email phải có cú pháp @gmail.com';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu',
                            errorText: _passwordError,
                          ),
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(() => _passwordError = null);
                            }
                          },
                          validator: (value) {
                            final trimmed = value?.trim() ?? '';
                            if (trimmed.isEmpty) return 'Bắt buộc nhập Mật khẩu';
                            if (trimmed.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: disabled ? null : _handleLogin,
                            child: Text(
                              disabled ? 'Đang đăng nhập...' : 'Đăng nhập',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: disabled ? null : _handleGoogleLogin,
                            icon: const Icon(Icons.account_circle_outlined),
                            label: const Text('Đăng nhập với Google'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text('Chưa có tài khoản? Đăng ký'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Image.asset(
            'assets/images/gym_banner.png',
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Chào mừng quay lại',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          'Đăng nhập để cá nhân hóa dữ liệu luyện tập của bạn.',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}
