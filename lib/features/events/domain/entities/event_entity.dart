class EventEntity {
  final String id;
  final String title;
  final String description;
  final String? coverImage;
  final String location;
  final String startTime;
  final String endTime;
  final int capacity;
  final int registeredCount;
  final String category;
  final bool isRegistered;
  final String? communityId;
  final List<EventParticipantEntity> participants;

  const EventEntity({
    required this.id,
    required this.title,
    required this.description,
    this.coverImage,
    required this.location,
    required this.startTime,
    required this.endTime,
    this.capacity = 100,
    this.registeredCount = 0,
    this.category = 'Technology',
    this.isRegistered = false,
    this.communityId,
    this.participants = const [],
  });

  factory EventEntity.fromJson(Map<String, dynamic> json) {
    return EventEntity(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      coverImage: json['coverImage']?.toString(),
      location: json['location']?.toString() ?? 'Campus Hall',
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 100,
      registeredCount: (json['registeredCount'] as num?)?.toInt() ?? 0,
      category: json['category']?.toString() ?? 'Technology',
      isRegistered: json['isRegistered'] == true,
      communityId: json['communityId']?.toString(),
      participants: (json['participants'] as List<dynamic>?)
              ?.map((p) => EventParticipantEntity.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  EventEntity copyWith({
    bool? isRegistered,
    int? registeredCount,
  }) {
    return EventEntity(
      id: id,
      title: title,
      description: description,
      coverImage: coverImage,
      location: location,
      startTime: startTime,
      endTime: endTime,
      capacity: capacity,
      registeredCount: registeredCount ?? this.registeredCount,
      category: category,
      isRegistered: isRegistered ?? this.isRegistered,
      communityId: communityId,
      participants: participants,
    );
  }
}

class EventParticipantEntity {
  final String userId;
  final String fullName;
  final String? profileImage;
  final String registeredAt;

  const EventParticipantEntity({
    required this.userId,
    required this.fullName,
    this.profileImage,
    required this.registeredAt,
  });

  factory EventParticipantEntity.fromJson(Map<String, dynamic> json) {
    return EventParticipantEntity(
      userId: json['userId']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'Participant',
      profileImage: json['profileImage']?.toString(),
      registeredAt: json['registeredAt']?.toString() ?? '',
    );
  }
}
