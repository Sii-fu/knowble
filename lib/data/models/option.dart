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

  factory Option.fromMap(Map<String, dynamic> map) {
    return Option(
      id: map['id'] ?? '',
      questionId: map['question_id'] ?? '',
      optionText: map['option_text'] ?? '',
      isCorrect: map['is_correct'] ?? false,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_id': questionId,
      'option_text': optionText,
      'is_correct': isCorrect,
      'order': order,
    };
  }

  Option copyWith({
    String? id,
    String? questionId,
    String? optionText,
    bool? isCorrect,
    int? order,
  }) {
    return Option(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      optionText: optionText ?? this.optionText,
      isCorrect: isCorrect ?? this.isCorrect,
      order: order ?? this.order,
    );
  }
}
