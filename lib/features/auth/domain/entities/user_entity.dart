class UserEntity {
  final String id;
  final String email;
  final String fullName;
  final String university;
  final String department;
  final String year;
  final String bio;
  final String? profileImage;
  final List<String> skills;
  final List<String> interests;

  const UserEntity({
    required this.id,
    required this.email,
    required this.fullName,
    required this.university,
    required this.department,
    required this.year,
    this.bio = '',
    this.profileImage,
    this.skills = const [],
    this.interests = const [],
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    final profile = (json['profile'] is Map) ? json['profile'] as Map<String, dynamic> : json;
    return UserEntity(
      id: json['id']?.toString() ?? profile['userId']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: profile['fullName']?.toString() ?? 'Student',
      university: profile['university']?.toString() ?? 'University',
      department: profile['department']?.toString() ?? 'Computer Science',
      year: profile['year']?.toString() ?? '1st Year',
      bio: profile['bio']?.toString() ?? '',
      profileImage: profile['profileImage']?.toString(),
      skills: (profile['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      interests: (profile['interests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'profile': {
        'fullName': fullName,
        'university': university,
        'department': department,
        'year': year,
        'bio': bio,
        'profileImage': profileImage,
        'skills': skills,
        'interests': interests,
      },
    };
  }

  UserEntity copyWith({
    String? fullName,
    String? university,
    String? department,
    String? year,
    String? bio,
    String? profileImage,
    List<String>? skills,
    List<String>? interests,
  }) {
    return UserEntity(
      id: id,
      email: email,
      fullName: fullName ?? this.fullName,
      university: university ?? this.university,
      department: department ?? this.department,
      year: year ?? this.year,
      bio: bio ?? this.bio,
      profileImage: profileImage ?? this.profileImage,
      skills: skills ?? this.skills,
      interests: interests ?? this.interests,
    );
  }
}
