// home_page.dart
// Handles the main entry point for users after launching Knowble.
// This file contains the HomePage widget, which redirects users to the correct dashboard based on their role.
// Also contains the _LoginPage widget for user authentication.
// Connects to AuthService for login state and uses role_checker for navigation logic.

import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/role_checker.dart';

// HomePage checks the current user and redirects to the correct dashboard.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    if (user == null) {
      // If not logged in, show the login page
      return _LoginPage();
    } else if (isStudent(user)) {
      // Redirect students to their dashboard
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/student_dashboard'));
    } else if (isInstructor(user)) {
      // Redirect instructors to their dashboard
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/instructor_dashboard'));
    } else if (isAdmin(user)) {
      // Redirect admins to their dashboard
      Future.microtask(() => Navigator.pushReplacementNamed(context, '/admin_dashboard'));
    }
    // Show a loading spinner while redirecting
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// _LoginPage is a private widget for user login.
class _LoginPage extends StatefulWidget {
  @override
  State<_LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<_LoginPage> {
  final _emailController = TextEditingController(); // Controller for email input
  final _passwordController = TextEditingController(); // Controller for password input
  bool _loading = false; // Loading state for login
  String? _error; // Error message for failed login

  // Handles login logic and updates UI state
  void _login() async {
    setState(() { _loading = true; _error = null; });
    final ok = await AuthService.login(_emailController.text, _passwordController.text);
    setState(() { _loading = false; });
    if (!ok) setState(() { _error = 'Invalid credentials'; });
    else Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Knowble Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Email input field
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
              // Password input field
              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              const SizedBox(height: 16),
              // Show loading spinner if logging in
              if (_loading) const CircularProgressIndicator(),
              // Show error message if login fails
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              // Login button
              if (!_loading) ElevatedButton(onPressed: _login, child: const Text('Login')),
              const SizedBox(height: 16),
              // Show demo credentials for testing
              const Text('student@knowble.com, instructor@knowble.com, admin@knowble.com'),
            ],
          ),
        ),
      ),
    );
  }
}
