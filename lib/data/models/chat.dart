// chat.dart
// Chat model for Knowble, matching the chats table in the database.

class Chat {
  final String id;
  final String courseId;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  Chat({
    required this.id,
    required this.courseId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });
}
