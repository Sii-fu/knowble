// chatbot_query.dart
// ChatbotQuery model for Knowble, matching the chatbot_queries table in the database.

class ChatbotQuery {
  final String id;
  final String studentId;
  final String courseId;
  final String context;
  final String question;
  final String response;
  final DateTime timestamp;

  ChatbotQuery({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.context,
    required this.question,
    required this.response,
    required this.timestamp,
  });
}
