// lesson.dart
// Lesson model for Knowble, matching the lessons/contents table in the database.

class Lesson {
  final String id;
  final String sectionId;
  final String title;
  final String content;
  final int order;

  Lesson({
    required this.id,
    required this.sectionId,
    required this.title,
    required this.content,
    required this.order,
  });
}
