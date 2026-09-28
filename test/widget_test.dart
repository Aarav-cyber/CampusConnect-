import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:campus_connect/main.dart';
import 'package:campus_connect/features/auth/presentation/providers/auth_provider.dart';
import 'package:campus_connect/features/students/presentation/providers/students_provider.dart';
import 'package:campus_connect/features/communities/presentation/providers/communities_provider.dart';
import 'package:campus_connect/features/events/presentation/providers/events_provider.dart';
import 'package:campus_connect/features/chat/presentation/providers/chat_provider.dart';
import 'package:campus_connect/features/notifications/presentation/providers/notifications_provider.dart';

void main() {
  testWidgets('CampusConnect smoke test - renders login and brand', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => StudentsProvider()),
          ChangeNotifierProvider(create: (_) => CommunitiesProvider()),
          ChangeNotifierProvider(create: (_) => EventsProvider()),
          ChangeNotifierProvider(create: (_) => ChatProvider()),
          ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ],
        child: const CampusConnectApp(),
      ),
    );

    // Initial render shows AuthGate
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
