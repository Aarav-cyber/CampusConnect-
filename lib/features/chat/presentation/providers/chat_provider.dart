import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/websocket_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/conversation_entity.dart';

class ChatProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  StreamSubscription? _msgSub;
  StreamSubscription? _typingSub;
  StreamSubscription? _presenceSub;

  ChatProvider({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient() {
    _initWebSocketSubscriptions();
  }

  List<ConversationEntity> _conversations = [];
  final Map<String, List<MessageEntity>> _messagesByConv = {};
  final Map<String, String> _typingUsersByConv = {}; // convId -> typingUserName
  bool _isLoadingConversations = false;
  String? _errorMessage;

  List<ConversationEntity> get conversations => _conversations;
  bool get isLoadingConversations => _isLoadingConversations;
  String? get errorMessage => _errorMessage;

  List<MessageEntity> getMessages(String conversationId) {
    return _messagesByConv[conversationId] ?? [];
  }

  String? getTypingUser(String conversationId) {
    return _typingUsersByConv[conversationId];
  }

  void _initWebSocketSubscriptions() {
    final ws = WebSocketClient();

    // 1. Message received event
    _msgSub = ws.messageStream.listen((event) {
      if (event['type'] == 'message.created' && event['message'] != null) {
        final msgJson = event['message'] as Map<String, dynamic>;
        final newMsg = MessageEntity.fromJson(msgJson);
        final convId = newMsg.conversationId;

        if (_messagesByConv.containsKey(convId)) {
          // Avoid duplicate insertion
          if (!_messagesByConv[convId]!.any((m) => m.id == newMsg.id)) {
            _messagesByConv[convId]!.add(newMsg);
          }
        } else {
          _messagesByConv[convId] = [newMsg];
        }

        // Update conversation summary
        final convIdx = _conversations.indexWhere((c) => c.id == convId);
        if (convIdx != -1) {
          final c = _conversations[convIdx];
          _conversations[convIdx] = c.copyWith(
            lastMessage: newMsg.content,
            lastMessageTime: newMsg.createdAt,
          );
          // Re-sort to top
          final updated = _conversations.removeAt(convIdx);
          _conversations.insert(0, updated);
        }

        notifyListeners();
      }
    });

    // 2. Typing indicator event
    _typingSub = ws.typingStream.listen((event) {
      final convId = event['conversationId']?.toString();
      final userName = event['userName']?.toString();
      final isTyping = event['isTyping'] == true;

      if (convId != null) {
        if (isTyping && userName != null) {
          _typingUsersByConv[convId] = userName;
        } else {
          _typingUsersByConv.remove(convId);
        }
        notifyListeners();
      }
    });

    // 3. Presence event
    _presenceSub = ws.presenceStream.listen((event) {
      final userId = event['userId']?.toString();
      final isOnline = event['isOnline'] == true;
      if (userId == null) return;

      bool changed = false;
      _conversations = _conversations.map((c) {
        if (!c.isGroup && c.memberIds.contains(userId)) {
          changed = true;
          return c.copyWith(isOnline: isOnline);
        }
        return c;
      }).toList();

      if (changed) notifyListeners();
    });
  }

  Future<void> fetchConversations() async {
    _isLoadingConversations = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _apiClient.get(ApiConstants.conversations);
      if (res is List) {
        _conversations = res
            .map((e) => ConversationEntity.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      _isLoadingConversations = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  Future<void> fetchMessages(String conversationId) async {
    try {
      final res = await _apiClient.get(ApiConstants.messages(conversationId));
      if (res is List) {
        _messagesByConv[conversationId] = res
            .map((e) => MessageEntity.fromJson(e as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }
  }

  Future<ConversationEntity?> openDirectConversation(String recipientUserId) async {
    try {
      final res = await _apiClient.post(
        ApiConstants.directConversation,
        body: {'recipientId': recipientUserId},
      );
      if (res != null) {
        final conv = ConversationEntity.fromJson(res as Map<String, dynamic>);
        if (!_conversations.any((c) => c.id == conv.id)) {
          _conversations.insert(0, conv);
          notifyListeners();
        }
        return conv;
      }
    } catch (e) {
      debugPrint('Error opening direct conversation: $e');
    }
    return null;
  }

  void sendMessage({
    required String conversationId,
    required String currentUserId,
    required String content,
  }) {
    if (content.trim().isEmpty) return;

    // Send via WebSocket (with auto fallback and offline queueing)
    WebSocketClient().sendChatMessage(
      conversationId: conversationId,
      content: content.trim(),
    );

    // Send typing stop
    sendTyping(conversationId: conversationId, isTyping: false);
  }

  void sendTyping({required String conversationId, required bool isTyping}) {
    WebSocketClient().sendTyping(
      conversationId: conversationId,
      isTyping: isTyping,
    );
  }

  void markAsRead(String conversationId) {
    WebSocketClient().markMessageRead(conversationId: conversationId);
    _apiClient.post(ApiConstants.markRead(conversationId));
  }

  @override
  void dispose() {
    _msgSub?.cancel();
    _typingSub?.cancel();
    _presenceSub?.cancel();
    super.dispose();
  }
}
