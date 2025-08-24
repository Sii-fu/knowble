import 'package:flutter/material.dart';


import 'package:Knowble/features/instructor/widgets/instructor_navbar.dart';
import 'package:Knowble/features/instructor/home_teacher_new.dart';
import 'package:Knowble/features/instructor/course_screen.dart';
import 'package:Knowble/features/instructor/instructor_profile_page.dart';
import 'package:Knowble/features/instructor/chat/chat_list_page.dart';

/// InstructorLayout is a root wrapper for all instructor-facing pages with a persistent bottom navbar.
class InstructorLayout extends StatefulWidget {
  const InstructorLayout({super.key});

  @override
  State<InstructorLayout> createState() => _InstructorLayoutState();
}

class _InstructorLayoutState extends State<InstructorLayout> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const TeacherHomePage(),
    const CourseScreen(),
    const ChatListPage(),
    const InstructorProfilePage(),
    // Add more instructor-specific pages here
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
      bottomNavigationBar: InstructorBottomNavbar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
