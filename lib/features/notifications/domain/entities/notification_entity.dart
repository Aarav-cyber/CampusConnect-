class NotificationEntity {
  final String id;
  final String category; // MESSAGES, CONNECTIONS, EVENTS, COMMUNITIES
  final String title;
  final String body;
  final bool isRead;
  final String createdAt;
  final Map<String, dynamic> data;

  const NotificationEntity({
    required this.id,
    required this.category,
    required this.title,
    required this.body,
    this.isRead = false,
    required this.createdAt,
    this.data = const {},
  });

  factory NotificationEntity.fromJson(Map<String, dynamic> json) {
    return NotificationEntity(
      id: json['id']?.toString() ?? '',
      category: json['category']?.toString() ?? 'SYSTEM',
      title: json['title']?.toString() ?? 'Notification',
      body: json['body']?.toString() ?? '',
      isRead: json['isRead'] == true,
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      data: (json['data'] is Map) ? Map<String, dynamic>.from(json['data'] as Map) : {},
    );
  }

  NotificationEntity copyWith({
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id,
      category: category,
      title: title,
      body: body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      data: data,
    );
  }
}
