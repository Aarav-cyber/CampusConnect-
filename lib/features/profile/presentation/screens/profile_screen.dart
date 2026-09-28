import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../shared/widgets/campus_card.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Not signed in', style: AppStyles.bodySecondary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('My Profile', style: AppStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryLight),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  title: const Text('Sign Out', style: AppStyles.h3),
                  content: const Text('Are you sure you want to sign out of CampusConnect?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<AuthProvider>().logout();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                      child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            CampusCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: AppColors.surfaceElevated,
                    backgroundImage: user.profileImage != null
                        ? NetworkImage(user.profileImage!)
                        : null,
                    child: user.profileImage == null
                        ? Text(
                            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                            style: const TextStyle(
                                fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(user.fullName, style: AppStyles.h2),
                  const SizedBox(height: 4),
                  Text(
                    '${user.department} · ${user.year}',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.primaryLight, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(user.university, style: AppStyles.caption),
                  const SizedBox(height: 8),
                  Text(user.email, style: AppStyles.bodySecondary),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bio
            CampusCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('About Me', style: AppStyles.h3),
                  const SizedBox(height: 8),
                  Text(
                    user.bio.isNotEmpty ? user.bio : 'No bio added yet. Tap edit to write something about yourself!',
                    style: AppStyles.body,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Skills
            CampusCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Skills & Technologies', style: AppStyles.h3),
                  const SizedBox(height: 12),
                  user.skills.isEmpty
                      ? const Text('Add your skills (e.g. Flutter, Python, ML)', style: AppStyles.bodySecondary)
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: user.skills.map((skill) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: AppStyles.radiusPill,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                skill,
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Interests
            CampusCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Interests & Clubs', style: AppStyles.h3),
                  const SizedBox(height: 12),
                  user.interests.isEmpty
                      ? const Text('Add your interests (e.g. AI, Robotics, Music)', style: AppStyles.bodySecondary)
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: user.interests.map((interest) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevated,
                                borderRadius: AppStyles.radiusPill,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Text(
                                interest,
                                style: const TextStyle(
                                  color: AppColors.accentPink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
