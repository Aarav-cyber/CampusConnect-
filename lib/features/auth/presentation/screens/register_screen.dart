import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _deptController = TextEditingController(text: 'Computer Science');
  final _yearController = TextEditingController(text: '3rd Year');
  final _uniController = TextEditingController(text: 'SRM University-AP');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _deptController.dispose();
    _yearController.dispose();
    _uniController.dispose();
    super.dispose();
  }

  void _submit() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out all required fields')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      email: email,
      password: password,
      fullName: name,
      department: _deptController.text.trim(),
      year: _yearController.text.trim(),
      university: _uniController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Registration failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isLoading = auth.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Create Student Account', style: AppStyles.h1),
              const SizedBox(height: 8),
              const Text(
                'Join your university community on CampusConnect',
                style: AppStyles.bodySecondary,
              ),
              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppStyles.radiusLarge,
                  border: Border.all(color: AppColors.border.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    _buildTextField(_nameController, 'Full Name', Icons.person_outline_rounded),
                    const SizedBox(height: 14),
                    _buildTextField(_emailController, 'University Email', Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 14),
                    _buildTextField(_passwordController, 'Password', Icons.lock_outline_rounded,
                        obscureText: true),
                    const SizedBox(height: 14),
                    _buildTextField(_deptController, 'Department / Major', Icons.school_outlined),
                    const SizedBox(height: 14),
                    _buildTextField(_yearController, 'Academic Year (e.g. 3rd Year)', Icons.calendar_today_outlined),
                    const SizedBox(height: 14),
                    _buildTextField(_uniController, 'University Name', Icons.account_balance_outlined),
                    const SizedBox(height: 24),

                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusMedium),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Create Profile & Join',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primaryLight, size: 20),
        filled: true,
        fillColor: AppColors.surfaceElevated.withOpacity(0.4),
        border: OutlineInputBorder(
          borderRadius: AppStyles.radiusMedium,
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
