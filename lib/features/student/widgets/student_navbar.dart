import 'package:flutter/material.dart';
import '../../../config/theme.dart';

/// A reusable bottom navigation bar for student dashboard screens.
///
/// Usage:
///   StudentBottomNavbar(
///     currentIndex: selectedIndex,
///     onTap: (index) => setState(() => selectedIndex = index),
///   )
class StudentBottomNavbar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const StudentBottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
  return Container(
      decoration: BoxDecoration(
    color: AppTheme.surfaceWhite,
        // Removed boxShadow to eliminate navbar shadow
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.07),
        //     blurRadius: 12,
        //     offset: const Offset(0, -2),
        //   ),
        // ],
        // borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTap,
        elevation: 0, // Set to 0 to remove Material elevation shadow
  backgroundColor: AppTheme.surfaceWhite,
  selectedItemColor: AppTheme.primaryTeal,
  unselectedItemColor: AppTheme.textSecondary,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Jost'),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontFamily: 'Jost'),
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
