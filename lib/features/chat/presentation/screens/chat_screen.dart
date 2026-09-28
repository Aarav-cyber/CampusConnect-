import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/network/websocket_client.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../domain/entities/conversation_entity.dart';
import '../domain/entities/message_entity.dart';
import '../providers/chat_provider.dart';

class ChatScreen extends StatefulWidget {
  final ConversationEntity conversation;
  const ChatScreen({super.key, required this.conversation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    final chatProv = context.read<ChatProvider>();
    chatProv.fetchMessages(widget.conversation.id);
    chatProv.markAsRead(widget.conversation.id);

    // Join room for real-time WebSocket events
    WebSocketClient().joinRoom(widget.conversation.id);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged(String text) {
    if (text.trim().isNotEmpty && !_isTyping) {
      _isTyping = true;
      context.read<ChatProvider>().sendTyping(
            conversationId: widget.conversation.id,
            isTyping: true,
          );
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      if (_isTyping) {
        _isTyping = false;
        context.read<ChatProvider>().sendTyping(
              conversationId: widget.conversation.id,
              isTyping: false,
            );
      }
    });
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final currentUserId = context.read<AuthProvider>().currentUser?.id ?? '';
    context.read<ChatProvider>().sendMessage(
          conversationId: widget.conversation.id,
          currentUserId: currentUserId,
          content: text,
        );

    _textController.clear();
    _isTyping = false;

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.watch<AuthProvider>().currentUser?.id ?? '';
    final chatProv = context.watch<ChatProvider>();
    final messages = chatProv.getMessages(widget.conversation.id);
    final typingUser = chatProv.getTypingUser(widget.conversation.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.surfaceElevated,
              backgroundImage: widget.conversation.avatar != null
                  ? NetworkImage(widget.conversation.avatar!)
                  : null,
              child: widget.conversation.avatar == null
                  ? Text(
                      widget.conversation.title.isNotEmpty
                          ? widget.conversation.title[0].toUpperCase()
                          : 'C',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.conversation.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: widget.conversation.isOnline
                              ? AppColors.success
                              : AppColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        widget.conversation.isOnline ? 'Active now' : 'Offline',
                        style: AppStyles.caption,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages ListView
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet. Say hello!',
                      style: AppStyles.bodySecondary,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == currentUserId;
                      final time = DateTime.tryParse(msg.createdAt);
                      final formattedTime =
                          time != null ? DateFormat('h:mm a').format(time) : '';

                      return _buildMessageBubble(msg, isMe, formattedTime);
                    },
                  ),
          ),

          // Typing Indicator Bar
          if (typingUser != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$typingUser is typing...',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.5))),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onChanged: _onTextChanged,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surfaceElevated.withOpacity(0.5),
                        border: OutlineInputBorder(
                          borderRadius: AppStyles.radiusPill,
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: _sendMessage,
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

  Widget _buildMessageBubble(MessageEntity msg, bool isMe, String formattedTime) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && msg.senderAvatar != null)
            CircleAvatar(
              radius: 14,
              backgroundImage: NetworkImage(msg.senderAvatar!),
            ),
          if (!isMe && msg.senderAvatar != null) const SizedBox(width: 8),

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primary : AppColors.surfaceCard,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe && msg.senderName != null && widget.conversation.isGroup)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        msg.senderName!,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    msg.content,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formattedTime,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          msg.status == MessageStatus.read
                              ? Icons.done_all_rounded
                              : Icons.done_rounded,
                          size: 13,
                          color: msg.status == MessageStatus.read
                              ? AppColors.accent
                              : Colors.white.withOpacity(0.6),
                        ),
                      ],
                    ],
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
