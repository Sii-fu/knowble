class Section {
  final String id;
  final String moduleId;
  final String title;
  final String description;
  final int order;

  Section({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.description,
    required this.order,
  });

  factory Section.fromMap(Map<String, dynamic> map) {
    return Section(
      id: map['id'] ?? '',
      moduleId: map['module_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'module_id': moduleId,
      'title': title,
      'description': description,
      'order': order,
    };
  }

  Section copyWith({
    String? id,
    String? moduleId,
    String? title,
    String? description,
    int? order,
  }) {
    return Section(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      title: title ?? this.title,
      description: description ?? this.description,
      order: order ?? this.order,
    );
  }
}
