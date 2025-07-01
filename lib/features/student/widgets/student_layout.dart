import 'package:flutter/material.dart';
import 'package:knowble_app/features/student/widgets/student_navbar.dart';
import 'package:knowble_app/features/student/dashboard_page.dart';
import 'package:knowble_app/features/chat/chat_list_page.dart';
import 'package:knowble_app/features/student/schedule_page.dart';
import 'package:knowble_app/features/student/profile_page.dart';
import 'package:knowble_app/features/student/courses_page.dart';

/// StudentLayout is a root wrapper for all student-facing pages with a persistent bottom navbar.
class StudentLayout extends StatefulWidget {
  const StudentLayout({super.key});

  @override
  State<StudentLayout> createState() => _StudentLayoutState();
}

class _StudentLayoutState extends State<StudentLayout> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = const [
    StudentDashboardPage(),
    StudentCoursesPage(),
    ChatListPage(),
    StudentSchedulePage(),
    StudentProfilePage(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: StudentBottomNavbar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
