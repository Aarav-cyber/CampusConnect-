import 'package:flutter_test/flutter_test.dart';
import 'package:campus_connect/features/auth/domain/entities/user_entity.dart';
import 'package:campus_connect/features/events/domain/entities/event_entity.dart';
import 'package:campus_connect/features/communities/domain/entities/community_entity.dart';

void main() {
  group('CampusConnect Domain Entity Unit Tests', () {
    test('UserEntity deserializes properly from JSON', () {
      final json = {
        'id': 'usr_100',
        'email': 'student@university.edu',
        'profile': {
          'fullName': 'Aarav Shrestha',
          'university': 'SRM University-AP',
          'department': 'Computer Science',
          'year': '3rd Year',
          'skills': ['Flutter', 'Dart', 'Python'],
          'interests': ['AI', 'Open Source'],
        }
      };

      final user = UserEntity.fromJson(json);
      expect(user.id, 'usr_100');
      expect(user.fullName, 'Aarav Shrestha');
      expect(user.skills.length, 3);
      expect(user.interests.length, 2);
    });

    test('EventEntity deserializes and supports copyWith', () {
      final json = {
        'id': 'evt_1',
        'title': 'HackSRM 2026',
        'description': '36hr Hackathon',
        'location': 'Auditorium',
        'startTime': '2026-10-20T09:00:00Z',
        'endTime': '2026-10-21T21:00:00Z',
        'capacity': 300,
        'registeredCount': 100,
        'category': 'Hackathons',
        'isRegistered': false,
      };

      final event = EventEntity.fromJson(json);
      expect(event.title, 'HackSRM 2026');
      expect(event.isRegistered, false);

      final registeredEvent = event.copyWith(isRegistered: true, registeredCount: 101);
      expect(registeredEvent.isRegistered, true);
      expect(registeredEvent.registeredCount, 101);
    });

    test('CommunityEntity deserializes properly', () {
      final json = {
        'id': 'comm_1',
        'name': 'Flutter Developers',
        'description': 'Mobile community',
        'createdBy': 'usr_100',
        'memberCount': 50,
        'isMember': true,
      };

      final comm = CommunityEntity.fromJson(json);
      expect(comm.name, 'Flutter Developers');
      expect(comm.isMember, true);
      expect(comm.memberCount, 50);
    });
  });
}
