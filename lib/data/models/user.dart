/// User model representing users table structure
class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? profilePic;
  final String? bio;
  final bool isVerified;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profilePic,
    this.bio,
    required this.isVerified,
    required this.createdAt,
  });

  /// Create User from database map
  factory User.fromMap(Map<String, dynamic> map) {
    try {
      return User(
        id: map['id'] as String,
        name: map['name'] as String? ?? 'Unknown User',
        email: map['email'] as String? ?? '',
        role: map['role'] as String? ?? 'student',
        profilePic: map['profile_pic'] as String?,
        bio: map['bio'] as String?,
        isVerified: map['is_verified'] as bool? ?? false,
        createdAt: map['created_at'] != null
            ? DateTime.parse(map['created_at'] as String)
            : DateTime.now(),
      );
    } catch (e) {
      print('❌ Error creating User from map: $e');
      print('   Map data: $map');
      rethrow;
    }
  }

  /// Convert User to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'profile_pic': profilePic,
      'bio': bio,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get formatted role for display
  String get formattedRole {
    switch (role.toLowerCase()) {
      case 'student':
        return 'Student';
      case 'instructor':
        return 'Instructor';
      case 'admin':
        return 'Admin';
      default:
        return role.substring(0, 1).toUpperCase() +
            role.substring(1).toLowerCase();
    }
  }

  /// Get user status based on verification
  String get status => isVerified ? 'Active' : 'Pending';

  /// Get user initials for avatar
  String get initials {
    final nameParts = name.trim().split(' ');
    if (nameParts.length >= 2) {
      return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    }
    return 'U';
  }

  /// Get formatted registration date
  String get formattedRegistrationDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  /// Create copy with updated values
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? profilePic,
    String? bio,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profilePic: profilePic ?? this.profilePic,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, name: $name, email: $email, role: $role, isVerified: $isVerified}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.role == role &&
        other.profilePic == profilePic &&
        other.bio == bio &&
        other.isVerified == isVerified &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        role.hashCode ^
        profilePic.hashCode ^
        bio.hashCode ^
        isVerified.hashCode ^
        createdAt.hashCode;
  }
}
