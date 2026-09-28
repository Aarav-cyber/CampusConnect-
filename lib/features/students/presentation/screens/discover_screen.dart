import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../shared/widgets/campus_card.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../providers/students_provider.dart';
import 'student_detail_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 350);

  final List<String> _departments = [
    'All',
    'Computer Science',
    'AI & Data Science',
    'Cyber Security',
    'Electronics & Comm',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentsProvider>().fetchStudents();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsProv = context.watch<StudentsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Discover Students', style: AppStyles.h2),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (text) {
                _debouncer.run(() {
                  studentsProv.updateSearch(text);
                });
              },
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by name, skills, interests...',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryLight),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textMuted),
                        onPressed: () {
                          _searchController.clear();
                          studentsProv.updateSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: AppStyles.radiusMedium,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Department Filters
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _departments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final dept = _departments[index];
                final isSelected = studentsProv.selectedDepartment == dept;

                return ChoiceChip(
                  label: Text(dept),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppStyles.radiusPill,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                  onSelected: (_) => studentsProv.updateDepartmentFilter(dept),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Student List
          Expanded(
            child: studentsProv.isLoading
                ? const LoadingView(message: 'Finding peers on campus...')
                : studentsProv.students.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.person_search_rounded,
                        title: 'No Students Found',
                        description: 'Try adjusting your search terms or filters.',
                      )
                    : RefreshIndicator(
                        onRefresh: () => studentsProv.fetchStudents(refresh: true),
                        color: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: studentsProv.students.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final student = studentsProv.students[index];
                            return CampusCard(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => StudentDetailScreen(student: student),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Avatar with Online badge
                                      Stack(
                                        children: [
                                          CircleAvatar(
                                            radius: 26,
                                            backgroundColor: AppColors.surfaceElevated,
                                            backgroundImage: student.profileImage != null
                                                ? NetworkImage(student.profileImage!)
                                                : null,
                                            child: student.profileImage == null
                                                ? Text(
                                                    student.fullName.isNotEmpty
                                                        ? student.fullName[0].toUpperCase()
                                                        : 'S',
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold),
                                                  )
                                                : null,
                                          ),
                                          if (student.isOnline)
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                width: 13,
                                                height: 13,
                                                decoration: BoxDecoration(
                                                  color: AppColors.success,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: AppColors.surfaceCard,
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 14),

                                      // Student Info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              student.fullName,
                                              style: AppStyles.h3,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${student.department} · ${student.year}',
                                              style: AppStyles.bodySecondary,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              student.university,
                                              style: AppStyles.caption,
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Connect Button
                                      ElevatedButton(
                                        onPressed: () {
                                          studentsProv.toggleConnect(student.userId);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: student.isConnected
                                              ? AppColors.surfaceElevated
                                              : AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: AppStyles.radiusPill,
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          student.isConnected ? 'Connected' : 'Connect',
                                          style: const TextStyle(
                                              fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Bio preview
                                  if (student.bio.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      student.bio,
                                      style: AppStyles.bodySecondary,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],

                                  // Skills Wrap
                                  if (student.skills.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: student.skills.take(4).map((s) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceElevated.withOpacity(0.6),
                                            borderRadius: AppStyles.radiusPill,
                                            border: Border.all(
                                                color: AppColors.border.withOpacity(0.5)),
                                          ),
                                          child: Text(
                                            s,
                                            style: const TextStyle(
                                              color: AppColors.accent,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
