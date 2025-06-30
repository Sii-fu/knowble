// question.dart
// Question model for Knowble, matching the questions table in the database.

enum QuestionType { mcq, text, code }

class Question {
  final String id;
  final String assessmentId;
  final String questionText;
  final QuestionType type;
  final int marks;

  Question({
    required this.id,
    required this.assessmentId,
    required this.questionText,
    required this.type,
    required this.marks,
  });
}
