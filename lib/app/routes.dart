import 'package:flutter/material.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import 'home_shell.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomeShell(),
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        notifications: (_) => const NotificationsScreen(),
      };
}
