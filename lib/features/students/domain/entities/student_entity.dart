class StudentEntity {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String university;
  final String department;
  final String year;
  final String bio;
  final String? profileImage;
  final List<String> skills;
  final List<String> interests;
  final bool isOnline;
  final String? lastSeen;
  final bool isConnected;

  const StudentEntity({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.university,
    required this.department,
    required this.year,
    this.bio = '',
    this.profileImage,
    this.skills = const [],
    this.interests = const [],
    this.isOnline = false,
    this.lastSeen,
    this.isConnected = false,
  });

  factory StudentEntity.fromJson(Map<String, dynamic> json) {
    return StudentEntity(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? 'Student',
      email: json['email']?.toString() ?? '',
      university: json['university']?.toString() ?? 'Campus University',
      department: json['department']?.toString() ?? 'Computer Science',
      year: json['year']?.toString() ?? '1st Year',
      bio: json['bio']?.toString() ?? '',
      profileImage: json['profileImage']?.toString(),
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      interests: (json['interests'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isOnline: json['isOnline'] == true,
      lastSeen: json['lastSeen']?.toString(),
      isConnected: json['isConnected'] == true,
    );
  }

  StudentEntity copyWith({
    bool? isConnected,
    bool? isOnline,
  }) {
    return StudentEntity(
      id: id,
      userId: userId,
      fullName: fullName,
      email: email,
      university: university,
      department: department,
      year: year,
      bio: bio,
      profileImage: profileImage,
      skills: skills,
      interests: interests,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
