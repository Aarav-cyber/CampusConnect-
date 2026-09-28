import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../shared/widgets/campus_card.dart';
import '../domain/entities/student_entity.dart';
import '../providers/students_provider.dart';
import '../../chat/presentation/providers/chat_provider.dart';
import '../../chat/presentation/screens/chat_screen.dart';

class StudentDetailScreen extends StatelessWidget {
  final StudentEntity student;
  const StudentDetailScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final studentsProv = context.watch<StudentsProvider>();
    final currentStudent = studentsProv.students.firstWhere(
      (s) => s.userId == student.userId,
      orElse: () => student,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textSecondary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile link copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header card
            CampusCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: AppColors.surfaceElevated,
                        backgroundImage: currentStudent.profileImage != null
                            ? NetworkImage(currentStudent.profileImage!)
                            : null,
                        child: currentStudent.profileImage == null
                            ? Text(
                                currentStudent.fullName.isNotEmpty
                                    ? currentStudent.fullName[0].toUpperCase()
                                    : 'S',
                                style: const TextStyle(
                                    fontSize: 32,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )
                            : null,
                      ),
                      if (currentStudent.isOnline)
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.surfaceCard, width: 3),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(currentStudent.fullName, style: AppStyles.h2),
                  const SizedBox(height: 4),
                  Text(
                    '${currentStudent.department} · ${currentStudent.year}',
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.primaryLight, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(currentStudent.university, style: AppStyles.caption),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentStudent.isOnline ? AppColors.success : AppColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currentStudent.isOnline ? 'Online now' : 'Offline',
                        style: AppStyles.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Actions: Connect & Chat
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: Icon(
                            currentStudent.isConnected
                                ? Icons.check_circle_outline_rounded
                                : Icons.person_add_outlined,
                            size: 18,
                          ),
                          label: Text(currentStudent.isConnected ? 'Connected' : 'Connect'),
                          onPressed: () {
                            context.read<StudentsProvider>().toggleConnect(currentStudent.userId);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentStudent.isConnected
                                ? AppColors.surfaceElevated
                                : AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusMedium),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                          label: const Text('Message'),
                          onPressed: () async {
                            final chatProv = context.read<ChatProvider>();
                            final conv = await chatProv.openDirectConversation(currentStudent.userId);
                            if (conv != null && context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(conversation: conv),
                                ),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accent,
                            side: const BorderSide(color: AppColors.accent),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusMedium),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // About Bio
            if (currentStudent.bio.isNotEmpty) ...[
              CampusCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('About', style: AppStyles.h3),
                    const SizedBox(height: 8),
                    Text(currentStudent.bio, style: AppStyles.body),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Skills
            if (currentStudent.skills.isNotEmpty) ...[
              CampusCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Skills & Tech Stack', style: AppStyles.h3),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currentStudent.skills.map((skill) {
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
            ],

            // Interests
            if (currentStudent.interests.isNotEmpty) ...[
              CampusCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Interests & Hobbies', style: AppStyles.h3),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currentStudent.interests.map((interest) {
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
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
