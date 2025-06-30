// submission.dart
// Submission model for Knowble, matching the submissions table in the database.

class Submission {
  final String id;
  final String studentId;
  final String questionId;
  final List<String> selectedOptionIds;
  final bool isCorrect;
  final int marksAwarded;

  Submission({
    required this.id,
    required this.studentId,
    required this.questionId,
    required this.selectedOptionIds,
    required this.isCorrect,
    required this.marksAwarded,
  });
}
