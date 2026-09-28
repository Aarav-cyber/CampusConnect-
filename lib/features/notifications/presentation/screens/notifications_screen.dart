import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../shared/widgets/campus_card.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../providers/notifications_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().fetchNotifications();
    });
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toUpperCase()) {
      case 'EVENTS':
        return Icons.event_available_rounded;
      case 'CONNECTIONS':
        return Icons.person_add_rounded;
      case 'COMMUNITIES':
        return Icons.groups_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'EVENTS':
        return AppColors.accent;
      case 'CONNECTIONS':
        return AppColors.primaryLight;
      case 'COMMUNITIES':
        return AppColors.accentPink;
      default:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifProv = context.watch<NotificationsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications', style: AppStyles.h2),
      ),
      body: notifProv.isLoading
          ? const LoadingView(message: 'Loading updates...')
          : notifProv.notifications.isEmpty
              ? const EmptyStateView(
                  icon: Icons.notifications_none_rounded,
                  title: 'All Caught Up!',
                  description: 'You have no new notifications right now.',
                )
              : RefreshIndicator(
                  onRefresh: () => notifProv.fetchNotifications(),
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: notifProv.notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final n = notifProv.notifications[index];
                      final time = DateTime.tryParse(n.createdAt);
                      final formattedTime = time != null ? DateFormat('MMM d · h:mm a').format(time) : '';

                      return CampusCard(
                        backgroundColor: n.isRead
                            ? AppColors.surfaceCard
                            : AppColors.surfaceElevated.withOpacity(0.4),
                        onTap: () {
                          notifProv.markAsRead(n.id);
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(n.category).withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getCategoryIcon(n.category),
                                color: _getCategoryColor(n.category),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          n.title,
                                          style: AppStyles.h3,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (!n.isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(n.body, style: AppStyles.bodySecondary),
                                  const SizedBox(height: 6),
                                  Text(formattedTime, style: AppStyles.caption),
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
