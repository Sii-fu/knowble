// course_tag.dart
// CourseTag model for Knowble, matching the course_tags table in the database.

class CourseTag {
  final String courseId;
  final String tagId;
  final bool isPrimary;
  final String? note;

  CourseTag({
    required this.courseId,
    required this.tagId,
    required this.isPrimary,
    this.note,
  });
}
