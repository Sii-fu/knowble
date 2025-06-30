// enrollment.dart
// Enrollment model for Knowble, matching the enrollments table in the database.

class Enrollment {
  final String id;
  final String studentId;
  final String courseId;
  final DateTime enrolledAt;
  final double progress;

  Enrollment({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.enrolledAt,
    required this.progress,
  });
}
