// auth_manager.dart
// Handles Supabase authentication state, user tracking, and navigation guards for Knowble.
// - Checks login status on app launch
// - Redirects to dashboard or login
// - Provides logout and user info helpers
// - Can be used for route guards

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  static Future<void> handleInitialAuth(BuildContext context) async {
    // Show splash/loading while checking
    await Future.delayed(const Duration(milliseconds: 500));
    if (currentUser != null) {
      // Fetch user role from Supabase users table
      final userId = currentUserId;
      if (userId != null) {
        final response = await _client
            .from('users')
            .select('role')
            .eq('id', userId)
            .single();
        final role = response['role'] as String?;
        if (role == 'student') {
          Navigator.pushReplacementNamed(context, '/student_dashboard');
        } else if (role == 'instructor') {
          Navigator.pushReplacementNamed(context, '/instructor_dashboard');
        } else if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        } else {
          print('User role is unknown, redirecting to login');
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        print('User ID is null, redirecting to login');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      print('No user logged in, redirecting to login');
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  /// Logs out the user and navigates to login
  static Future<void> logout(BuildContext context) async {
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
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
