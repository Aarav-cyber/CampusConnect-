import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/home_shell.dart';
import 'app/routes.dart';
import 'app/theme.dart';
import 'core/storage/local_storage_service.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_styles.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/students/presentation/providers/students_provider.dart';
import 'features/communities/presentation/providers/communities_provider.dart';
import 'features/events/presentation/providers/events_provider.dart';
import 'features/chat/presentation/providers/chat_provider.dart';
import 'features/notifications/presentation/providers/notifications_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthStatus()),
        ChangeNotifierProvider(create: (_) => StudentsProvider()),
        ChangeNotifierProvider(create: (_) => CommunitiesProvider()),
        ChangeNotifierProvider(create: (_) => EventsProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
      ],
      child: const CampusConnectApp(),
    ),
  );
}

class CampusConnectApp extends StatelessWidget {
  const CampusConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CampusConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AuthGate(),
      routes: AppRoutes.routes,
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.status == AuthStatus.loading || auth.status == AuthStatus.initial) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.hub_rounded,
                  size: 54,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              const Text('CampusConnect', style: AppStyles.h1),
              const SizedBox(height: 8),
              const Text('Connecting campus peers in real-time', style: AppStyles.bodySecondary),
              const SizedBox(height: 32),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (auth.isAuthenticated) {
      return const HomeShell();
    }

    return const LoginScreen();
  }
}
