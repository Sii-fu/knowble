// option.dart
// Option model for Knowble, matching the options table in the database.

class Option {
  final String id;
  final String questionId;
  final String optionText;
  final bool isCorrect;
  final int order;

  Option({
    required this.id,
    required this.questionId,
    required this.optionText,
    required this.isCorrect,
    required this.order,
  });
}
