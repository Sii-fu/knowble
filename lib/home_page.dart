//not a valid page. dummy placement page for first version
import 'package:flutter/material.dart';
import 'core/services/notification_service.dart';
import 'features/student/search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    SearchPage(), // Modern search page implementation
    Center(child: Text('Dashboard Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Profile Page', style: TextStyle(fontSize: 24))),
    Center(child: Text('Chat Page', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(child: _pages[_selectedIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withOpacity(0.7),
        backgroundColor: colorScheme.surface,
        items: [
          BottomNavigationBarItem(
            icon: _NavBarIcon(
              icon: Icons.explore,
              isActive: _selectedIndex == 0,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: _NavBarIcon(
              icon: Icons.dashboard,
              isActive: _selectedIndex == 1,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: _NavBarIcon(
              icon: Icons.person,
              isActive: _selectedIndex == 2,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: _NavBarIcon(
              icon: Icons.chat_bubble,
              isActive: _selectedIndex == 3,
              isDark: isDark,
              colorScheme: colorScheme,
            ),
            label: 'Chat',
          ),
        ],
      ),
      // Temporary test button for notifications - REMOVE after testing
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Test immediate notification
          await NotificationService.showImmediateNotification(
            title: 'Test Notification',
            description: 'This is a test notification!',
            priority: 'high',
          );

          // Test scheduled notification (10 seconds from now)
          await NotificationService.testNotification();

          // Test database insertion directly
          await NotificationService.testDatabaseInsertion();

          // Show snackbar confirmation
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '🧪 Tests triggered! Check console & notification table.',
                ),
                duration: Duration(seconds: 3),
              ),
            );
          }
        },
        child: const Icon(Icons.notifications_active),
        tooltip: 'Test Notifications',
      ),
    );
  }
}

class _NavBarIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final bool isDark;
  final ColorScheme colorScheme;

  const _NavBarIcon({
    required this.icon,
    required this.isActive,
    required this.isDark,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          icon,
          size: 28,
          color: isActive
              ? (isDark ? colorScheme.primary : colorScheme.primary)
              : colorScheme.onSurface.withOpacity(0.7),
        ),
        if (isActive && isDark)
          Positioned(
            bottom: 0,
            child: Container(
              width: 24,
              height: 3,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
      ],
    );
  }
}
