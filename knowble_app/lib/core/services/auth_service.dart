// auth_service.dart
// Provides authentication logic for the Knowble app.
// This file contains the AuthService class, which simulates login and logout functionality for demo purposes.
// It is used by the login page and AuthProvider for managing user authentication state.
// Connects to the User model for user data.

// import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';

// AuthService simulates user authentication and stores the current user in memory.
class AuthService {
  static User? _currentUser; // Holds the currently logged-in user (if any)

  // Returns the current user, or null if not logged in.
  static User? get currentUser => _currentUser;

  // Simulates a login process. Accepts three hardcoded emails for demo roles.
  static Future<bool> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'student@knowble.com') {
      // Log in as student
      _currentUser = User(name: 'Student User', email: email, role: UserRole.student);
      return true;
    } else if (email == 'instructor@knowble.com') {
      // Log in as instructor
      _currentUser = User(name: 'Instructor User', email: email, role: UserRole.instructor);
      return true;
    } else if (email == 'admin@knowble.com') {
      // Log in as admin
      _currentUser = User(name: 'Admin User', email: email, role: UserRole.admin);
      return true;
    }
    // Invalid credentials
    return false;
  }

  // Logs out the current user.
  static void logout() {
    _currentUser = null;
  }
}
