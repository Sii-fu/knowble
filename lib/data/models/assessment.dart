class Assessment {
  final String id;
  final String courseId;
  final String title;
  final String type; // 'quiz', 'assignment'
  final int totalMarks;

  Assessment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.type,
    required this.totalMarks,
  });

  factory Assessment.fromMap(Map<String, dynamic> map) {
    return Assessment(
      id: map['id'] ?? '',
      courseId: map['course_id'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      totalMarks: map['total_marks'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'type': type,
      'total_marks': totalMarks,
    };
  }

  Assessment copyWith({
    String? id,
    String? courseId,
    String? title,
    String? type,
    int? totalMarks,
  }) {
    return Assessment(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      type: type ?? this.type,
      totalMarks: totalMarks ?? this.totalMarks,
    );
  }
}
