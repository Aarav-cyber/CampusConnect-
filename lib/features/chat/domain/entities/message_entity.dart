enum MessageStatus { pending, sending, sent, delivered, read, failed }

class MessageEntity {
  final String id;
  final String conversationId;
  final String senderId;
  final String? senderName;
  final String? senderAvatar;
  final String content;
  final String messageType;
  final MessageStatus status;
  final String createdAt;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.content,
    this.messageType = 'TEXT',
    this.status = MessageStatus.sent,
    required this.createdAt,
  });

  factory MessageEntity.fromJson(Map<String, dynamic> json) {
    MessageStatus parsedStatus = MessageStatus.sent;
    final statusStr = json['status']?.toString().toUpperCase();
    if (statusStr == 'PENDING') parsedStatus = MessageStatus.pending;
    if (statusStr == 'SENDING') parsedStatus = MessageStatus.sending;
    if (statusStr == 'DELIVERED') parsedStatus = MessageStatus.delivered;
    if (statusStr == 'READ') parsedStatus = MessageStatus.read;
    if (statusStr == 'FAILED') parsedStatus = MessageStatus.failed;

    return MessageEntity(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString(),
      senderAvatar: json['senderAvatar']?.toString(),
      content: json['content']?.toString() ?? '',
      messageType: json['messageType']?.toString() ?? 'TEXT',
      status: parsedStatus,
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    );
  }

  MessageEntity copyWith({
    MessageStatus? status,
  }) {
    return MessageEntity(
      id: id,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      content: content,
      messageType: messageType,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
