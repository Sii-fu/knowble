// course_review.dart
// CourseReview model for Knowble, matching the course_reviews table in the database.

class CourseReview {
  final String id;
  final String courseId;
  final String studentId;
  final int rating;
  final String? reviewText;
  final DateTime createdAt;
  final bool isVisible;

  CourseReview({
    required this.id,
    required this.courseId,
    required this.studentId,
    required this.rating,
    this.reviewText,
    required this.createdAt,
    required this.isVisible,
  });
}
