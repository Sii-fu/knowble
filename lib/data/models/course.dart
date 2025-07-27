// TODO: Define Course model
class Course {
  final String id;
  final String instructorId;
  final String title;
  final String description;
  final double price;
  final bool isPaid;
  final int durationDays;
  final DateTime createdAt;
  final String banner;

  Course({
    required this.id,
    required this.instructorId,
    required this.title,
    required this.description,
    required this.price,
    required this.isPaid,
    required this.durationDays,
    required this.createdAt,
    required this.banner,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] ?? '',
      instructorId: map['instructor_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      isPaid: map['is_paid'] ?? false,
      durationDays: map['duration_days'] ?? 0,
      createdAt: DateTime.parse(map['created_at']),
      banner: map['banner'] ?? 'banner',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'instructor_id': instructorId,
      'title': title,
      'description': description,
      'price': price,
      'is_paid': isPaid,
      'duration_days': durationDays,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Course copyWith({
    String? id,
    String? instructorId,
    String? title,
    String? description,
    double? price,
    bool? isPaid,
    int? durationDays,
    DateTime? createdAt,
  }) {
    return Course(
      id: id ?? this.id,
      instructorId: instructorId ?? this.instructorId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      isPaid: isPaid ?? this.isPaid,
      durationDays: durationDays ?? this.durationDays,
      createdAt: createdAt ?? this.createdAt,
      banner: banner, 
    );
  }
}
