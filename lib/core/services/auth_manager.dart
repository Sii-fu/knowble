// auth_manager.dart
// Handles Supabase authentication state, user tracking, and navigation guards for Knowble.
// - Checks login status on app launch
// - Redirects to dashboard or login
// - Provides logout and user info helpers
// - Can be used for route guards

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_manager.dart';

class AuthManager {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Returns the current logged-in user, or null if not logged in
  static User? get currentUser => _client.auth.currentUser;

  /// Returns the current user's UUID, or null if not logged in
  static String? get currentUserId => currentUser?.id;

  /// Returns the current user's email, or null if not logged in
  static String? get currentUserEmail => currentUser?.email;

  /// Checks auth state and navigates accordingly (call on app launch)
  /// Now fetches user role from Supabase and redirects to the correct dashboard
  ///
  /// CRITICAL: This relies on auth.users.id being IDENTICAL to public.users.id
  /// Registration process MUST insert the same UUID into both tables
  static Future<void> handleInitialAuth(
    BuildContext context, {
    bool fromLogin = false,
  }) async {
    // Show splash/loading while checking
    await Future.delayed(
      Duration(milliseconds: fromLogin ? 1000 : 500),
    ); // Longer delay after login

    if (currentUser != null) {
      // Get the user ID from Supabase Auth - this comes from auth.users.id
      final userId = currentUserId;
      final userEmail = currentUserEmail;

      print('🔍 AuthManager: Checking authentication for user:');
      print('   Auth User ID: $userId');
      print('   Auth Email: $userEmail');
      print('   Called from login: $fromLogin');

      if (userId != null) {
        try {
          // Look up user profile using the SAME ID from auth.users
          // This will only work if registration created both records with identical IDs
          final response = await _client
              .from('users')
              .select('id, email, role')
              .eq('id', userId)
              .maybeSingle(); // Use maybeSingle instead of single to handle missing users

          if (response == null) {
            // User exists in auth.users but not in public.users table
            // This indicates a broken registration or data inconsistency
            print('❌ ID MISMATCH DETECTED!');
            print('   ✅ User exists in auth.users with ID: $userId');
            print('   ❌ No matching record in public.users with ID: $userId');
            print(
              '   🔧 This suggests registration failed to create users table entry',
            );
            print('   🔄 Redirecting to logout for cleanup...');
            await logout(context);
            return;
          }

          // Verify data consistency
          final dbUserId = response['id'] as String?;
          final dbUserEmail = response['email'] as String?;

          print('✅ ID CONSISTENCY VERIFIED!');
          print('   Auth ID: $userId');
          print('   DB ID: $dbUserId');
          print('   Auth Email: $userEmail');
          print('   DB Email: $dbUserEmail');
          print('   IDs Match: ${userId == dbUserId}');
          print('   Emails Match: ${userEmail == dbUserEmail}');

          final role = response['role'] as String?;
          print('   User Role: $role');
          print('');

          if (role == 'student') {
            print('🎓 Redirecting to student dashboard');
            // Push instant notifications for unread notifications BEFORE navigation
            await NotificationManager.pushInstantNotificationsForUnread();
            Navigator.pushReplacementNamed(context, '/student');
          } else if (role == 'instructor') {
            // Check if instructor has completed their profile
            // This uses the same consistent user ID
            final instructorResponse = await _client
                .from('instructor_info')
                .select('id')
                .eq('user_id', userId)
                .maybeSingle();

            if (instructorResponse == null) {
              // Instructor hasn't completed profile, redirect to completion screen
              print(
                '📝 Instructor profile incomplete - redirecting to completion',
              );
              Navigator.pushReplacementNamed(context, '/teacher-profile');
            } else {
              // Instructor has completed profile, redirect to instructor dashboard
              print('👨‍🏫 Redirecting to instructor dashboard');
              // Push instant notifications for unread notifications BEFORE navigation
              await NotificationManager.pushInstantNotificationsForUnread();
              Navigator.pushReplacementNamed(context, '/instructor');
            }
          } else if (role == 'admin') {
            print('🔧 Redirecting to admin dashboard');
            // Push instant notifications for unread notifications BEFORE navigation
            await NotificationManager.pushInstantNotificationsForUnread();
            Navigator.pushReplacementNamed(context, '/admin/dashboard');
          } else {
            print('❓ Unknown user role: $role - redirecting to login');
            Navigator.pushReplacementNamed(context, '/login');
          }
        } catch (e) {
          // Handle database errors
          print('❌ Error fetching user role: $e');
          print('🔄 Redirecting to login due to database error');
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        print('❌ User ID is null - redirecting to login');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      print('🔐 No user logged in - redirecting to onboarding');
      Navigator.pushReplacementNamed(context, '/onboarding');
      // print('🔐 No user logged in - redirecting to login');
      // Navigator.pushReplacementNamed(context, '/login');
    }
  }

  /// Logs out the user and navigates to login
  static Future<void> logout(BuildContext context) async {
    // Clean up notification services before logout
    await NotificationManager.cleanup();

    await _client.auth.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  /// Auth guard: returns true if user is logged in, false otherwise
  static bool isAuthenticated() => currentUser != null;
}

/// SplashScreen widget that checks auth status and redirects
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    AuthManager.handleInitialAuth(context);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
