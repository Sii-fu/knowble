// section.dart
// Section model for Knowble, matching the sections table in the database.

class Section {
  final String id;
  final String moduleId;
  final String title;
  final String? description;
  final int order;

  Section({
    required this.id,
    required this.moduleId,
    required this.title,
    this.description,
    required this.order,
  });
}
