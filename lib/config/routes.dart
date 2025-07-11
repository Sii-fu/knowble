// routes.dart
// Sets up all named routes for navigation in the Knowble app.
// This file defines the AppRoutes class, which contains the initial route and a map of all route names to their corresponding widgets.
// It is imported by app.dart to configure MaterialApp's routing.
// Each route points to a screen in the features/ directory.

import 'package:flutter/material.dart';

import '../features/course/course_list_page.dart';
import '../features/course/course_detail_page.dart';
import '../features/course/course_content_page.dart';
import '../features/course/quiz_page.dart';


import '../features/student/chat/chat_list_page.dart';

import '../features/instructor/course_screen.dart';
import '../features/instructor/manage_students_page.dart';
import '../features/instructor/home_teacher.dart'; 


import '../features/admin/dashboard_page.dart';
import '../features/admin/user_management_page.dart';
import '../features/admin/course_approval_page.dart';

import '../features/common/splash_screen.dart';
import '../features/common/settings_page.dart';
import '../features/common/onboarding_screens.dart';
import '../features/common/onboarding_screen_1/onboarding_screen_1.dart';
import '../features/common/onboarding_screen_2/onboarding_screen_2.dart';
import '../features/common/onboarding_screen_3/onboarding_screen_3.dart';
import '../features/common/auth/login_screen.dart';
import '../features/common/auth/registration_screen.dart';

import '../features/student/widgets/student_layout.dart';
import '../features/student/dashboard_page.dart';
import '../features/student/home_page.dart';
import '../features/student/courses_page.dart';
import '../features/student/schedule_page.dart';
import '../features/student/profile_page.dart';
import '../features/student/calendar_dashboard.dart';
import '../features/student/scheduler/task_creation_modal.dart';
import '../features/student/scheduler/task_edit_modal.dart';
import '../features/student/scheduler/task_detail_view.dart';
import '../features/student/scheduler/full_month_calendar_view.dart';

// AppRoutes holds all route names and their corresponding widget builders.
class AppRoutes {
  static const String initial = '/'; // The initial route (SplashScreen)

  // Map of route names to widget builders for navigation throughout the app.
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/onboarding': (context) => const OnboardingScreen(),
    '/onboarding-screen-1': (context) => const OnboardingScreen1(),
    '/onboarding-screen-2': (context) => const OnboardingScreen2(),
    '/onboarding-screen-3': (context) => const OnboardingScreen3(),
    '/login': (context) => const LoginScreen(),
    '/registration': (context) => const RegistrationScreen(),
    '/settings': (context) => const SettingsPage(),
    '/courses': (context) => const CourseListPage(),
    '/course_detail': (context) => const CourseDetailPage(),
    '/course_content': (context) => const CourseContentPage(),
    '/quiz': (context) => const QuizPage(),
    '/chats': (context) => const ChatListPage(),
    '/student_dashboard': (context) => const StudentDashboardPage(),
    '/course_screen': (context) => const CourseScreen(),

    '/student': (context) => const StudentLayout(),
    '/manage_students': (context) => const ManageStudentsPage(),
    '/admin_dashboard': (context) => const AdminDashboardPage(),
    '/user_management': (context) => const UserManagementPage(),
    '/course_approval': (context) => const CourseApprovalPage(),
    '/student_home': (context) => const StudentHomePage(),
    '/student_courses': (context) => const StudentCoursesPage(),
    '/student_schedule': (context) => const StudentSchedulePage(),
    '/student_profile': (context) => const StudentProfilePage(),
    '/calendar-dashboard': (context) => const CalendarDashboard(),
    '/task-creation-modal': (context) => const TaskCreationModal(),
    '/task-edit-modal': (context) => const TaskEditModal(),
    '/task-detail-view': (context) => const TaskDetailView(),
    '/full-month-calendar-view': (context) => const FullMonthCalendarView(),
    '/home_teacher': (context) => const TeacherHomePage(), 
  };
}
