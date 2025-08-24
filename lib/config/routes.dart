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
import '../features/instructor/home_teacher_new.dart';
import '../features/instructor/instructor_profile_page2.dart';
import '../features/instructor/instructor_profile_page.dart';
import '../features/admin/admin_dashboard.dart';
import '../features/admin/admin_users_management.dart';
import '../features/admin/admin_courses_management.dart';
import '../features/admin/admin_instructors_management.dart';

import '../features/common/screens/splash_screen.dart';
import '../features/common/screens/settings_page.dart';
import '../features/common/screens/onboarding/onboarding_screens.dart';
import '../features/common/screens/auth/login_screen.dart';
import '../features/common/screens/auth/registration_screen.dart';
import '../features/common/screens/auth/profile_completion/student_interest_selection_screen.dart';
import '../features/common/screens/auth/profile_completion/teacher_profile_completion_screen.dart';
import '../features/instructor/verification/teacher_verification_pending_screen.dart';

// Forgot Password Screens
import '../features/common/screens/forgot_password/email_selection_screen.dart';
import '../features/common/screens/forgot_password/otp_verification_screen.dart';
import '../features/common/screens/forgot_password/new_password_creation_screen.dart';

// Notifications Screen
import '../features/common/screens/notifications/notifications_screen.dart';

import '../features/instructor/widgets/instructor_layout.dart';
import '../features/student/widgets/student_layout.dart';
import '../features/student/dashboard_page.dart';
import '../features/student/courses_page_refactored.dart';
import '../features/student/profile_page.dart';
import '../features/student/calendar_dashboard.dart';
import '../features/student/scheduler/task_creation_modal.dart';
import '../features/student/scheduler/task_edit_modal.dart';
import '../features/student/scheduler/task_detail_view.dart';
import '../features/student/scheduler/full_month_calendar_view.dart';
import '../features/student/chatbot/chatbotpage.dart';
import '../features/student/invite_friends_page.dart';
import '../features/student/terms_conditions_page.dart';
// import '../features/student/category_page.dart';
// Feedback screens
import '../features/student/feedback pages/feedback_form_screen.dart';
import '../features/student/feedback pages/feedback_history_screen.dart';
import '../features/instructor/feedback pages/instructor_feedback_history_screen.dart';

// AppRoutes holds all route names and their corresponding widget builders.
class AppRoutes {
  static const String initial = '/'; // The initial route (SplashScreen)

  // Map of route names to widget builders for navigation throughout the app.
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => const SplashScreen(),
    '/onboarding': (context) => const OnboardingScreen(),
    '/login': (context) => const LoginScreen(),
    '/registration': (context) => const RegistrationScreen(),
    '/student-interest': (context) => const StudentInterestSelectionScreen(),
    '/teacher-profile': (context) => const TeacherProfileCompletionScreen(),
    '/teacher-verification': (context) =>
        const TeacherVerificationPendingScreen(),
    '/settings': (context) => const SettingsPage(),
    '/courses': (context) => const CourseListPage(),
    '/course_detail': (context) => const CourseDetailPage(),
    '/course_content': (context) => const CourseContentPage(),
    '/quiz': (context) => const QuizPage(),
    '/chats': (context) => const ChatListPage(),
    '/student_dashboard': (context) => const StudentDashboardPage(),
    '/course_screen': (context) => const CourseScreen(),

    // '/category_page': (context) => const CategoryPage(),
    '/student': (context) => const StudentLayout(),
    '/instructor': (context) => const InstructorLayout(),
    '/manage_students': (context) => const ManageStudentsPage(),

    // Admin routes with new structure
    '/admin/dashboard': (context) => const AdminDashboard(),
    '/admin/users': (context) => const AdminUsersManagement(),
    '/admin/courses': (context) => const AdminCoursesManagement(),
    '/admin/instructors': (context) => const AdminInstructorsManagement(),

    '/student_courses': (context) => const StudentCoursesPageRefactored(),
    '/student_profile': (context) => const StudentProfilePage(),
    '/calendar-dashboard': (context) => const CalendarDashboard(),
    '/task-creation-modal': (context) => const TaskCreationModal(),
    '/task-edit-modal': (context) => const TaskEditModal(),
    '/task-detail-view': (context) => const TaskDetailView(),
    '/full-month-calendar-view': (context) => const FullMonthCalendarView(),
    // '/home_teacher': (context) => const TeacherHomePage(),
    // '/home_teacher': (context) => const old_teacher.TeacherHomePage(),
    '/home_teacher': (context) => const TeacherHomePage(),

    '/instructor_profile_page2': (context) => const InstructorProfilePage2(),
    '/instructor_profile_page': (context) => const InstructorProfilePage(),
    '/chatbot': (context) => const ChatBotPage(),

    // Forgot Password routes
    '/forgot-password': (context) => const EmailSelectionScreen(),
    '/forgot-password/otp-verification': (context) =>
        const OtpVerificationScreen(),
    '/forgot-password/new-password': (context) =>
        const NewPasswordCreationScreen(),

    // Notifications route
    '/notifications': (context) => const NotificationsScreen(),

    // New settings pages
    '/invite-friends': (context) => const InviteFriendsPage(),
    '/terms-conditions': (context) => const TermsAndConditionsPage(),

    // Feedback pages
    '/feedback-form': (context) => const FeedbackFormScreen(),
    '/feedback-history': (context) => const FeedbackHistoryScreen(),
    '/instructor-feedback-history': (context) =>
        const InstructorFeedbackHistoryScreen(),
  };
}
