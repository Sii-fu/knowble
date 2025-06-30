// role_checker.dart
// Utility functions to check a user's role in the Knowble app.
// This file provides helper functions to determine if a user is a student, instructor, or admin.
// Used throughout the app for role-based navigation and UI logic.

import '../../data/models/user_model.dart';

// Returns true if the user is a student.
bool isStudent(User? user) => user?.role == UserRole.student;
// Returns true if the user is an instructor.
bool isInstructor(User? user) => user?.role == UserRole.instructor;
// Returns true if the user is an admin.
bool isAdmin(User? user) => user?.role == UserRole.admin;
