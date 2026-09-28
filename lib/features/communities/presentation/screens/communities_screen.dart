import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../shared/widgets/campus_card.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../domain/entities/community_entity.dart';
import '../providers/communities_provider.dart';
import 'community_detail_screen.dart';

class CommunitiesScreen extends StatefulWidget {
  const CommunitiesScreen({super.key});

  @override
  State<CommunitiesScreen> createState() => _CommunitiesScreenState();
}

class _CommunitiesScreenState extends State<CommunitiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunitiesProvider>().fetchCommunities();
    });
  }

  void _showCreateCommunityDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusLarge),
        title: const Text('Create New Community', style: AppStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Community Name',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: AppStyles.radiusMedium),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              maxLines: 3,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surfaceElevated,
                border: OutlineInputBorder(borderRadius: AppStyles.radiusMedium),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final desc = descController.text.trim();
              if (name.isNotEmpty && desc.isNotEmpty) {
                await context.read<CommunitiesProvider>().createCommunity(
                      name: name,
                      description: desc,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final commProv = context.watch<CommunitiesProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Campus Communities', style: AppStyles.h2),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryLight),
            onPressed: _showCreateCommunityDialog,
          ),
        ],
      ),
      body: commProv.isLoading
          ? const LoadingView(message: 'Loading campus clubs & communities...')
          : commProv.communities.isEmpty
              ? const EmptyStateView(
                  icon: Icons.groups_outlined,
                  title: 'No Communities Yet',
                  description: 'Be the first to create a community for your club or interest!',
                )
              : RefreshIndicator(
                  onRefresh: () => commProv.fetchCommunities(),
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: commProv.communities.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final comm = commProv.communities[index];
                      return CampusCard(
                        padding: EdgeInsets.zero,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CommunityDetailScreen(community: comm),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cover banner
                            if (comm.coverImage != null)
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                                child: Image.network(
                                  comm.coverImage!,
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 120,
                                    color: AppColors.surfaceElevated,
                                    child: const Center(
                                      child: Icon(Icons.groups_rounded,
                                          size: 40, color: AppColors.textMuted),
                                    ),
                                  ),
                                ),
                              ),

                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          comm.name,
                                          style: AppStyles.h3,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          commProv.toggleJoin(comm.id);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: comm.isMember
                                              ? AppColors.surfaceElevated
                                              : AppColors.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: AppStyles.radiusPill,
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          comm.isMember ? 'Joined' : 'Join',
                                          style: const TextStyle(
                                              fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    comm.description,
                                    style: AppStyles.bodySecondary,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.people_alt_outlined,
                                          size: 16, color: AppColors.accent),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${comm.memberCount} members',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
