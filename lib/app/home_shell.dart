import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/students/presentation/screens/discover_screen.dart';
import '../features/chat/presentation/screens/conversations_screen.dart';
import '../features/events/presentation/screens/events_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  void _navigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onNavigateTab: _navigateToTab),
      const DiscoverScreen(),
      const ConversationsScreen(),
      const EventsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.5))),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withOpacity(0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.home_rounded, color: AppColors.primaryLight),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.explore_rounded, color: AppColors.primaryLight),
              label: 'Discover',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.chat_bubble_rounded, color: AppColors.primaryLight),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_outlined, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.event_rounded, color: AppColors.primaryLight),
              label: 'Events',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryLight),
              label: 'Me',
            ),
          ],
        ),
      ),
    );
  }
}
