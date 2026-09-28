import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../shared/widgets/campus_card.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../domain/entities/conversation_entity.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProv = context.watch<ChatProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('Messages', style: AppStyles.h2),
      ),
      body: chatProv.isLoadingConversations
          ? const LoadingView(message: 'Loading active conversations...')
          : chatProv.conversations.isEmpty
              ? const EmptyStateView(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'No Conversations Yet',
                  description: 'Discover peers or join a community group to start chatting in real time.',
                )
              : RefreshIndicator(
                  onRefresh: () => chatProv.fetchConversations(),
                  color: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: chatProv.conversations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final conv = chatProv.conversations[index];
                      final lastTime = DateTime.tryParse(conv.lastMessageTime);
                      final formattedTime = lastTime != null
                          ? DateFormat('h:mm a').format(lastTime)
                          : '';

                      return CampusCard(
                        padding: const EdgeInsets.all(14),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(conversation: conv),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            // Avatar + Online status
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: AppColors.surfaceElevated,
                                  backgroundImage: conv.avatar != null
                                      ? NetworkImage(conv.avatar!)
                                      : null,
                                  child: conv.avatar == null
                                      ? Icon(
                                          conv.isGroup
                                              ? Icons.groups_rounded
                                              : Icons.person_rounded,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                if (conv.isOnline && !conv.isGroup)
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

                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          conv.title,
                                          style: AppStyles.h3,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(formattedTime, style: AppStyles.caption),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    conv.lastMessage ?? 'No messages yet',
                                    style: AppStyles.bodySecondary,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
