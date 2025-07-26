// tag.dart
// Tag model for Knowble, matching the tags table in the database.

class Tag {
  final String id;
  final String name;
  final String? category;

  Tag({required this.id, required this.name, this.category});

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'category': category};
  }
}
