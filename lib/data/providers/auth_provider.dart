// auth_provider.dart
// Provides state management for user authentication in Knowble.
// This file defines the AuthProvider class, which uses AuthService to manage login/logout state.
// Used by the login page and any widget that needs to react to authentication changes.

import '../models/user_model.dart';
import '../../core/services/auth_service.dart';
import 'package:flutter/material.dart';

// AuthProvider manages authentication state and notifies listeners on changes.
class AuthProvider extends ChangeNotifier {
  // Returns the current user (or null if not logged in)
  User? get user => AuthService.currentUser;
  // Returns true if a user is logged in
  bool get isLoggedIn => user != null;

  // Attempts to log in and notifies listeners if successful
  Future<bool> login(String email, String password) async {
    final result = await AuthService.login(email, password);
    notifyListeners();
    return result;
  }

  // Logs out the user and notifies listeners
  void logout() {
    AuthService.logout();
    notifyListeners();
  }
}
