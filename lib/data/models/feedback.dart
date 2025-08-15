/// Feedback model representing feedback_issues table structure
class Feedback {
  final String id;
  final String userId;
  final String? userRole;
  final String type;
  final String category;
  final String message;
  final String status;
  final DateTime submittedAt;
  final DateTime? resolvedAt;
  final String? adminNotes;

  const Feedback({
    required this.id,
    required this.userId,
    this.userRole,
    required this.type,
    required this.category,
    required this.message,
    required this.status,
    required this.submittedAt,
    this.resolvedAt,
    this.adminNotes,
  });

  /// Create Feedback from database map
  factory Feedback.fromMap(Map<String, dynamic> map) {
    try {
      print('🔍 Creating Feedback from map: $map');
      return Feedback(
        id: map['id'] as String,
        userId: map['user_id'] as String,
        userRole: map['user_role'] as String?,
        type: map['type'] as String,
        category: map['category'] as String,
        message: map['message'] as String,
        status: map['status'] as String,
        submittedAt: DateTime.parse(map['submitted_at'] as String),
        resolvedAt: map['resolved_at'] != null
            ? DateTime.parse(map['resolved_at'] as String)
            : null,
        adminNotes: map['admin_notes'] as String?,
      );
    } catch (e, stackTrace) {
      print('❌ Error creating Feedback from map: $e');
      print('📊 Map data: $map');
      print('📚 Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Convert Feedback to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'user_role': userRole,
      'type': type,
      'category': category,
      'message': message,
      'status': status,
      'submitted_at': submittedAt.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'admin_notes': adminNotes,
    };
  }

  /// Create a copy of this feedback with some fields updated
  Feedback copyWith({
    String? id,
    String? userId,
    String? userRole,
    String? type,
    String? category,
    String? message,
    String? status,
    DateTime? submittedAt,
    DateTime? resolvedAt,
    String? adminNotes,
  }) {
    return Feedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userRole: userRole ?? this.userRole,
      type: type ?? this.type,
      category: category ?? this.category,
      message: message ?? this.message,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }

  /// Get formatted submission date
  String get formattedSubmittedAt {
    return '${submittedAt.day}/${submittedAt.month}/${submittedAt.year}';
  }

  /// Get formatted submission time
  String get formattedSubmittedTime {
    final hour = submittedAt.hour.toString().padLeft(2, '0');
    final minute = submittedAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get formatted resolution date (if resolved)
  String? get formattedResolvedAt {
    if (resolvedAt == null) return null;
    return '${resolvedAt!.day}/${resolvedAt!.month}/${resolvedAt!.year}';
  }

  /// Check if feedback is resolved
  bool get isResolved {
    return status == 'resolved' || status == 'closed';
  }

  /// Check if feedback is pending
  bool get isPending {
    return status == 'submitted' || status == 'in_review';
  }

  /// Check if feedback is in progress
  bool get isInProgress {
    return status == 'in_progress';
  }

  /// Get status color for UI
  String get statusColor {
    switch (status) {
      case 'submitted':
        return '#FFA500'; // Orange
      case 'in_review':
        return '#4285F4'; // Blue
      case 'in_progress':
        return '#FF9800'; // Amber
      case 'resolved':
        return '#4CAF50'; // Green
      case 'closed':
        return '#757575'; // Grey
      default:
        return '#9E9E9E'; // Default grey
    }
  }

  /// Get status display text
  String get statusDisplay {
    switch (status) {
      case 'submitted':
        return 'Submitted';
      case 'in_review':
        return 'Under Review';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status.toUpperCase();
    }
  }

  /// Get priority based on type and category
  int get priority {
    // Bug reports have higher priority
    if (type == 'Bug Report') return 1;

    // Performance issues are high priority
    if (type == 'Performance Issue') return 2;

    // Content issues are medium-high priority
    if (type == 'Content Issue') return 3;

    // Feature requests are medium priority
    if (type == 'Feature Request') return 4;

    // General feedback is lower priority
    return 5;
  }

  /// Get estimated resolution time in days
  int get estimatedResolutionDays {
    switch (priority) {
      case 1:
        return 1; // Critical bugs - 1 day
      case 2:
        return 3; // Performance issues - 3 days
      case 3:
        return 5; // Content issues - 5 days
      case 4:
        return 7; // Feature requests - 1 week
      default:
        return 14; // General feedback - 2 weeks
    }
  }

  @override
  String toString() {
    return 'Feedback{id: $id, type: $type, category: $category, status: $status, submittedAt: $submittedAt}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Feedback &&
        other.id == id &&
        other.userId == userId &&
        other.userRole == userRole &&
        other.type == type &&
        other.category == category &&
        other.message == message &&
        other.status == status &&
        other.submittedAt == submittedAt &&
        other.resolvedAt == resolvedAt &&
        other.adminNotes == adminNotes;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        userRole.hashCode ^
        type.hashCode ^
        category.hashCode ^
        message.hashCode ^
        status.hashCode ^
        submittedAt.hashCode ^
        resolvedAt.hashCode ^
        adminNotes.hashCode;
  }
}
