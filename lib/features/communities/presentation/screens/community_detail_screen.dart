import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../shared/widgets/campus_card.dart';
import '../domain/entities/community_entity.dart';
import '../providers/communities_provider.dart';

class CommunityDetailScreen extends StatefulWidget {
  final CommunityEntity community;
  const CommunityDetailScreen({super.key, required this.community});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  CommunityEntity? _detailedCommunity;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() async {
    final comm = await context
        .read<CommunitiesProvider>()
        .getCommunityDetails(widget.community.id);
    if (mounted) {
      setState(() {
        _detailedCommunity = comm ?? widget.community;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final commProv = context.watch<CommunitiesProvider>();
    final activeComm = commProv.communities.firstWhere(
      (c) => c.id == widget.community.id,
      orElse: () => _detailedCommunity ?? widget.community,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Collapsible Banner Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                activeComm.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                ),
              ),
              background: activeComm.coverImage != null
                  ? Image.network(
                      activeComm.coverImage!,
                      fit: BoxFit.cover,
                    )
                  : Container(color: AppColors.primaryDark),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Action Banner
                  CampusCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${activeComm.memberCount} Members',
                              style: AppStyles.h3,
                            ),
                            const Text(
                              'Active Campus Club',
                              style: AppStyles.caption,
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            commProv.toggleJoin(activeComm.id);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeComm.isMember
                                ? AppColors.surfaceElevated
                                : AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: AppStyles.radiusPill),
                          ),
                          child: Text(
                            activeComm.isMember ? 'Leave' : 'Join Community',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  CampusCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('About Community', style: AppStyles.h3),
                        const SizedBox(height: 8),
                        Text(activeComm.description, style: AppStyles.body),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Members List
                  CampusCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Members & Leads', style: AppStyles.h3),
                        const SizedBox(height: 12),
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(color: AppColors.primary),
                            ),
                          )
                        else if (_detailedCommunity?.members.isEmpty ?? true)
                          const Text('No members listed yet.', style: AppStyles.bodySecondary)
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _detailedCommunity!.members.length,
                            separatorBuilder: (_, __) => const Divider(color: AppColors.border),
                            itemBuilder: (context, idx) {
                              final m = _detailedCommunity!.members[idx];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.surfaceElevated,
                                  backgroundImage: m.profileImage != null
                                      ? NetworkImage(m.profileImage!)
                                      : null,
                                  child: m.profileImage == null
                                      ? Text(m.fullName[0].toUpperCase())
                                      : null,
                                ),
                                title: Text(m.fullName, style: AppStyles.body),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: m.role == 'ADMIN'
                                        ? AppColors.primary.withOpacity(0.2)
                                        : AppColors.surfaceElevated,
                                    borderRadius: AppStyles.radiusSmall,
                                  ),
                                  child: Text(
                                    m.role,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: m.role == 'ADMIN'
                                          ? AppColors.primaryLight
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
