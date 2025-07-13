class Module {
  final String id;
  final String courseId;
  final String title;
  final int order;

  Module({
    required this.id,
    required this.courseId,
    required this.title,
    required this.order,
  });

  factory Module.fromMap(Map<String, dynamic> map) {
    return Module(
      id: map['id'] ?? '',
      courseId: map['course_id'] ?? '',
      title: map['title'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'order': order,
    };
  }

  Module copyWith({
    String? id,
    String? courseId,
    String? title,
    int? order,
  }) {
    return Module(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      title: title ?? this.title,
      order: order ?? this.order,
    );
  }
}
