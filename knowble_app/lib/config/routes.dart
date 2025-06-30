// routes.dart
// Sets up all named routes for navigation in the Knowble app.
// This file defines the AppRoutes class, which contains the initial route and a map of all route names to their corresponding widgets.
// It is imported by app.dart to configure MaterialApp's routing.
// Each route points to a screen in the features/ directory.

import 'package:flutter/material.dart';
import '../features/common/home_page.dart';
import '../features/common/settings_page.dart';
import '../features/common/chatbot/chatbot_page.dart';
import '../features/course/course_list_page.dart';
import '../features/course/course_detail_page.dart';
import '../features/course/course_content_page.dart';
import '../features/course/quiz_page.dart';
import '../features/chat/chat_list_page.dart';
import '../features/chat/chat_detail_page.dart';
import '../features/student/dashboard_page.dart';
import '../features/student/enrolled_courses_page.dart';
import '../features/instructor/dashboard_page.dart';
import '../features/instructor/create_course_page.dart';
import '../features/instructor/manage_students_page.dart';
import '../features/admin/dashboard_page.dart';
import '../features/admin/user_management_page.dart';
import '../features/admin/course_approval_page.dart';

// AppRoutes holds all route names and their corresponding widget builders.
class AppRoutes {
  static const String initial = '/'; // The initial route (home/login)

  // Map of route names to widget builders for navigation throughout the app.
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const HomePage(),
    '/settings': (context) => const SettingsPage(),
    '/chatbot': (context) => const ChatbotPage(),
    '/courses': (context) => const CourseListPage(),
    '/course_detail': (context) => const CourseDetailPage(),
    '/course_content': (context) => const CourseContentPage(),
    '/quiz': (context) => const QuizPage(),
    '/chats': (context) => const ChatListPage(),
    '/chat_detail': (context) => const ChatDetailPage(),
    '/student_dashboard': (context) => const StudentDashboardPage(),
    '/enrolled_courses': (context) => const EnrolledCoursesPage(),
    '/instructor_dashboard': (context) => const InstructorDashboardPage(),
    '/create_course': (context) => const CreateCoursePage(),
    '/manage_students': (context) => const ManageStudentsPage(),
    '/admin_dashboard': (context) => const AdminDashboardPage(),
    '/user_management': (context) => const UserManagementPage(),
    '/course_approval': (context) => const CourseApprovalPage(),
  };
}
