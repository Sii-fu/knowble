// user_model.dart
// (Deprecated) Use user.dart instead. This file can be deleted.

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
