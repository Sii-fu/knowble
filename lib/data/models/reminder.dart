// reminder.dart
// Reminder model for Knowble, matching the reminders table in the database.

class Reminder {
  final String id;
  final String userId;
  final String courseId;
  final String title;
  final DateTime time;
  final String createdBy;

  Reminder({
    required this.id,
    required this.userId,
    required this.courseId,
    required this.title,
    required this.time,
    required this.createdBy,
  });
}
