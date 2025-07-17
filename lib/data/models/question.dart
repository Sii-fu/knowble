class Question {
  final String id;
  final String assessmentId;
  final String questionText;
  final String type; // 'mcq', 'text', 'code'
  final int marks;

  Question({
    required this.id,
    required this.assessmentId,
    required this.questionText,
    required this.type,
    required this.marks,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] ?? '',
      assessmentId: map['assessment_id'] ?? '',
      questionText: map['question_text'] ?? '',
      type: map['type'] ?? '',
      marks: map['marks'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'assessment_id': assessmentId,
      'question_text': questionText,
      'type': type,
      'marks': marks,
    };
  }

  Question copyWith({
    String? id,
    String? assessmentId,
    String? questionText,
    String? type,
    int? marks,
  }) {
    return Question(
      id: id ?? this.id,
      assessmentId: assessmentId ?? this.assessmentId,
      questionText: questionText ?? this.questionText,
      type: type ?? this.type,
      marks: marks ?? this.marks,
    );
  }

  // Helper
  bool get isMCQ => type == 'mcq';
  bool get isCode => type == 'code';
  bool get isText => type == 'text';
}
