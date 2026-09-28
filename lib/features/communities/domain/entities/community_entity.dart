class CommunityEntity {
  final String id;
  final String name;
  final String description;
  final String? coverImage;
  final String createdBy;
  final int memberCount;
  final bool isMember;
  final List<CommunityMemberEntity> members;

  const CommunityEntity({
    required this.id,
    required this.name,
    required this.description,
    this.coverImage,
    required this.createdBy,
    this.memberCount = 1,
    this.isMember = false,
    this.members = const [],
  });

  factory CommunityEntity.fromJson(Map<String, dynamic> json) {
    return CommunityEntity(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      coverImage: json['coverImage']?.toString(),
      createdBy: json['createdBy']?.toString() ?? '',
      memberCount: (json['memberCount'] as num?)?.toInt() ?? 1,
      isMember: json['isMember'] == true,
      members: (json['members'] as List<dynamic>?)
              ?.map((m) => CommunityMemberEntity.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  CommunityEntity copyWith({
    bool? isMember,
    int? memberCount,
  }) {
    return CommunityEntity(
      id: id,
      name: name,
      description: description,
      coverImage: coverImage,
      createdBy: createdBy,
      memberCount: memberCount ?? this.memberCount,
      isMember: isMember ?? this.isMember,
      members: members,
    );
  }
}

class CommunityMemberEntity {
  final String userId;
  final String role;
  final String fullName;
  final String? profileImage;

  const CommunityMemberEntity({
    required this.userId,
    required this.role,
    required this.fullName,
    this.profileImage,
  });

  factory CommunityMemberEntity.fromJson(Map<String, dynamic> json) {
    return CommunityMemberEntity(
      userId: json['userId']?.toString() ?? '',
      role: json['role']?.toString() ?? 'MEMBER',
      fullName: json['fullName']?.toString() ?? 'Member',
      profileImage: json['profileImage']?.toString(),
    );
  }
}
