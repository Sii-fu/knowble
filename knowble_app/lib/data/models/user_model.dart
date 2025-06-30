// user_model.dart
// Defines the User class and UserRole enum for Knowble.
// This file provides the data structure for user information, including name, email, and role.
// Used by authentication, providers, and role-based logic throughout the app.

// Enum representing the role of a user in the system.
enum UserRole { student, instructor, admin }

// User represents a single app user with a role, name, and email.
class User {
  final String name; // User's display name
  final String email; // User's email address
  final UserRole role; // User's role (student, instructor, admin)

  // Constructor for creating a new User instance.
  User({required this.name, required this.email, required this.role});
}
