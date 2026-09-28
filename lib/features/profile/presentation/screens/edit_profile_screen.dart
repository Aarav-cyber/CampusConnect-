import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _bioController = TextEditingController();
  final _skillsController = TextEditingController();
  final _interestsController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _bioController.text = user.bio;
      _skillsController.text = user.skills.join(', ');
      _interestsController.text = user.interests.join(', ');
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _skillsController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  void _save() async {
    setState(() => _isSaving = true);

    final bio = _bioController.text.trim();
    final skills = _skillsController.text
        .split(',')
        .map((s) => s.trim())
        .filter((s) => s.isNotEmpty)
        .toList();
    final interests = _interestsController.text
        .split(',')
        .map((i) => i.trim())
        .filter((i) => i.isNotEmpty)
        .toList();

    final success = await context.read<AuthProvider>().updateProfile(
          bio: bio,
          skills: skills,
          interests: interests,
        );

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile', style: AppStyles.h2),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bio field
            const Text('Bio / Summary', style: AppStyles.h3),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Share a bit about what you study, build, and enjoy...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: AppStyles.radiusMedium),
              ),
            ),
            const SizedBox(height: 20),

            // Skills field
            const Text('Skills (comma separated)', style: AppStyles.h3),
            const SizedBox(height: 8),
            TextField(
              controller: _skillsController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Flutter, Python, Machine Learning, UI/UX, Docker',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: AppStyles.radiusMedium),
              ),
            ),
            const SizedBox(height: 20),

            // Interests field
            const Text('Interests (comma separated)', style: AppStyles.h3),
            const SizedBox(height: 8),
            TextField(
              controller: _interestsController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'AI Research, Hackathons, Robotics, Photography',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: AppStyles.radiusMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension FilterListExtension on Iterable<String> {
  Iterable<String> filter(bool Function(String) test) {
    return where(test);
  }
}
