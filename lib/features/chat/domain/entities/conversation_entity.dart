class ConversationEntity {
  final String id;
  final bool isGroup;
  final String title;
  final String? avatar;
  final bool isOnline;
  final String? lastMessage;
  final String lastMessageTime;
  final List<String> memberIds;

  const ConversationEntity({
    required this.id,
    required this.isGroup,
    required this.title,
    this.avatar,
    this.isOnline = false,
    this.lastMessage,
    required this.lastMessageTime,
    this.memberIds = const [],
  });

  factory ConversationEntity.fromJson(Map<String, dynamic> json) {
    return ConversationEntity(
      id: json['id']?.toString() ?? '',
      isGroup: json['isGroup'] == true,
      title: json['title']?.toString() ?? 'Conversation',
      avatar: json['avatar']?.toString(),
      isOnline: json['isOnline'] == true,
      lastMessage: json['lastMessage']?.toString(),
      lastMessageTime: json['lastMessageTime']?.toString() ?? DateTime.now().toIso8601String(),
      memberIds: (json['memberIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  ConversationEntity copyWith({
    String? lastMessage,
    String? lastMessageTime,
    bool? isOnline,
  }) {
    return ConversationEntity(
      id: id,
      isGroup: isGroup,
      title: title,
      avatar: avatar,
      isOnline: isOnline ?? this.isOnline,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      memberIds: memberIds,
    );
  }
}
