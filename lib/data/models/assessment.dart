// assessment.dart
// Assessment model for Knowble, matching the assessments table in the database.

enum AssessmentType { quiz, assignment, other }

class Assessment {
  final String id;
  final String courseId;
  final String title;
  final AssessmentType type;
  final int totalMarks;

  Assessment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.type,
    required this.totalMarks,
  });
}
