class Content {
  final String id;
  final String sectionId;
  final String type; // 'video', 'pdf', 'link'
  final String title;
  final String url;
  final int order;

  Content({
    required this.id,
    required this.sectionId,
    required this.type,
    required this.title,
    required this.url,
    required this.order,
  });

  factory Content.fromMap(Map<String, dynamic> map) {
    return Content(
      id: map['id'] ?? '',
      sectionId: map['section_id'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      url: map['url'] ?? '',
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'section_id': sectionId,
      'type': type,
      'title': title,
      'url': url,
      'order': order,
    };
  }

  Content copyWith({
    String? id,
    String? sectionId,
    String? type,
    String? title,
    String? url,
    int? order,
  }) {
    return Content(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      type: type ?? this.type,
      title: title ?? this.title,
      url: url ?? this.url,
      order: order ?? this.order,
    );
  }
}
