import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../shared/widgets/campus_card.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../events/presentation/providers/events_provider.dart';
import '../../events/presentation/screens/event_detail_screen.dart';
import '../../communities/presentation/providers/communities_provider.dart';
import '../../communities/presentation/screens/community_detail_screen.dart';
import '../../chat/presentation/providers/chat_provider.dart';
import '../../chat/presentation/screens/chat_screen.dart';
import '../../notifications/presentation/providers/notifications_provider.dart';
import '../../notifications/presentation/screens/notifications_screen.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateTab;
  const HomeScreen({super.key, required this.onNavigateTab});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final eventsProv = context.watch<EventsProvider>();
    final commProv = context.watch<CommunitiesProvider>();
    final chatProv = context.watch<ChatProvider>();
    final notifProv = context.watch<NotificationsProvider>();

    final firstName = user?.fullName.split(' ').first ?? 'Student';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()}, $firstName 👋',
              style: AppStyles.h2,
            ),
            Text(
              user?.university ?? 'CampusConnect',
              style: AppStyles.caption,
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded,
                    color: AppColors.textPrimary, size: 26),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
              if (notifProv.unreadCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${notifProv.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            eventsProv.fetchEvents(),
            commProv.fetchCommunities(),
            chatProv.fetchConversations(),
            notifProv.fetchNotifications(),
          ]);
        },
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppStyles.radiusLarge,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HackSRM 2026 is LIVE!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Collaborate with university peers, build products, and win prizes.',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => onNavigateTab(3), // Navigate to Events
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: AppStyles.radiusPill,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              elevation: 0,
                            ),
                            child: const Text('View Events',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.rocket_launch_rounded, size: 54, color: Colors.white70),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Upcoming Events Section
              _buildSectionHeader(
                title: 'Upcoming Campus Events',
                actionText: 'See All',
                onAction: () => onNavigateTab(3),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 195,
                child: eventsProv.events.isEmpty
                    ? const Center(
                        child: Text('No events scheduled', style: AppStyles.bodySecondary),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: eventsProv.events.take(4).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final evt = eventsProv.events[index];
                          final startDate = DateTime.tryParse(evt.startTime);
                          final dateStr = startDate != null
                              ? DateFormat('MMM d · h:mm a').format(startDate)
                              : '';

                          return SizedBox(
                            width: 240,
                            child: CampusCard(
                              padding: EdgeInsets.zero,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EventDetailScreen(event: evt),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(14)),
                                    child: evt.coverImage != null
                                        ? Image.network(
                                            evt.coverImage!,
                                            height: 95,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            height: 95,
                                            color: AppColors.primaryDark,
                                            child: const Center(child: Icon(Icons.event)),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dateStr,
                                          style: const TextStyle(
                                            color: AppColors.accent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          evt.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 13),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${evt.registeredCount} attending',
                                          style: AppStyles.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),

              // Communities Section
              _buildSectionHeader(
                title: 'Featured Communities',
                actionText: 'Explore',
                onAction: () => onNavigateTab(1), // Navigate to Discover
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110,
                child: commProv.communities.isEmpty
                    ? const Center(
                        child: Text('No communities found', style: AppStyles.bodySecondary),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: commProv.communities.take(4).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final comm = commProv.communities[index];
                          return SizedBox(
                            width: 170,
                            child: CampusCard(
                              padding: const EdgeInsets.all(12),
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.groups_rounded,
                                          color: AppColors.primaryLight, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${comm.memberCount} members',
                                        style: AppStyles.caption,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    comm.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    comm.isMember ? 'Joined' : 'Open to join',
                                    style: TextStyle(
                                      color: comm.isMember ? AppColors.success : AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 24),

              // Recent Conversations Section
              _buildSectionHeader(
                title: 'Recent Conversations',
                actionText: 'Open Chat',
                onAction: () => onNavigateTab(2), // Navigate to Chat
              ),
              const SizedBox(height: 12),
              if (chatProv.conversations.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('No messages yet', style: AppStyles.bodySecondary),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: chatProv.conversations.take(3).length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final conv = chatProv.conversations[index];
                    return CampusCard(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ChatScreen(conversation: conv)),
                        );
                      },
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.surfaceElevated,
                            backgroundImage: conv.avatar != null
                                ? NetworkImage(conv.avatar!)
                                : null,
                            child: conv.avatar == null
                                ? Text(conv.title.isNotEmpty ? conv.title[0].toUpperCase() : 'C')
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(conv.title, style: AppStyles.h3),
                                const SizedBox(height: 2),
                                Text(
                                  conv.lastMessage ?? 'Say hello!',
                                  style: AppStyles.bodySecondary,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              size: 14, color: AppColors.textMuted),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppStyles.h3),
        TextButton(
          onPressed: onAction,
          child: Text(
            actionText,
            style: const TextStyle(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
