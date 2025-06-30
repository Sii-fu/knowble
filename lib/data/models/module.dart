// module.dart
// Module model for Knowble, matching the modules table in the database.

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
}
