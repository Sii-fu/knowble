import 'package:supabase_flutter/supabase_flutter.dart';

/// AIChatHistoryService handles all AI chat history operations with PostgreSQL database
/// Manages saving and retrieving chat conversations between students and AI assistant
class AIChatHistoryService {
  // Get Supabase client instance
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Save a new question-answer pair to the ai_chat_history table
  /// 
  /// Parameters:
  /// - [studentId]: UUID of the student asking the question
  /// - [courseId]: UUID of the course context (can be null for general questions)
  /// - [contentId]: UUID of the specific content/lesson context (can be null)
  /// - [question]: The student's question text
  /// - [answer]: The AI's response text
  /// 
  /// Returns:
  /// - Map with chat record data if successful
  /// - null if failed with error logging
  Future<Map<String, dynamic>?> saveChatMessage({
    required String studentId,
    String? contentId,
    required String question,
    required String answer,
  }) async {
    try {
      print('🤖 AIChatHistoryService: Saving chat message...');
      print('   Student ID: $studentId');
      print('   Content ID: ${contentId ?? "null"}');
      print('   Question length: ${question.length} characters');
      print('   Answer length: ${answer.length} characters');

      // Validate required parameters
      if (studentId.trim().isEmpty) {
        print('❌ Error: Student ID cannot be empty');
        return null;
      }

      if (question.trim().isEmpty) {
        print('❌ Error: Question cannot be empty');
        return null;
      }

      if (answer.trim().isEmpty) {
        print('❌ Error: Answer cannot be empty');
        return null;
      }

      // Prepare data for insertion
      final chatData = {
        'student_id': studentId.trim(),
        'content_id': contentId?.trim(), // Can be null
        'question': question.trim(),
        'answer': answer.trim(),
        'timestamp': DateTime.now().toUtc().toIso8601String(), // UTC timestamp
      };

      // Insert into ai_chat_history table and return the created record
      final response = await _supabase
          .from('ai_chat_history')
          .insert(chatData)
          .select()
          .single();

      print('✅ Chat message saved successfully with ID: ${response['id']}');
      return response;

    } on PostgrestException catch (e) {
      print('❌ PostgreSQL Error saving chat message: ${e.message}');
      print('   Error code: ${e.code}');
      print('   Error details: ${e.details}');
      return null;
    } catch (e) {
      print('❌ Unexpected error saving chat message: $e');
      return null;
    }
  }

  /// Load all chat history for a specific student and content context
  /// 
  /// Parameters:
  /// - [studentId]: UUID of the student
  /// - [courseId]: UUID of the course (optional filter)
  /// - [contentId]: UUID of the content (optional filter)
  /// - [limit]: Maximum number of messages to retrieve (default: 50)
  /// 
  /// Returns:
  /// - List of chat messages ordered by timestamp (oldest first)
  /// - Empty list if no messages found or on error
  Future<List<Map<String, dynamic>>> loadChatHistory({
    required String studentId,
    String? contentId,
    int limit = 50,
  }) async {
    try {
      print('🔍 AIChatHistoryService: Loading chat history...');
      print('   Student ID: $studentId');
      print('   Content ID: ${contentId ?? "null"}');
      print('   Limit: $limit');

      // Validate required parameters
      if (studentId.trim().isEmpty) {
        print('❌ Error: Student ID cannot be empty');
        return [];
      }

      if (limit <= 0) {
        print('❌ Error: Limit must be greater than 0');
        return [];
      }

      // Build query with student_id filter
      var query = _supabase
          .from('ai_chat_history')
          .select('''
            id,
            student_id,
            content_id,
            question,
            answer,
            timestamp
          ''')
          .eq('student_id', studentId.trim());

      // Add optional content_id filter
      if (contentId != null && contentId.trim().isNotEmpty) {
        query = query.eq('content_id', contentId.trim());
      }

      // Order by timestamp (oldest first) and apply limit
      final response = await query
          .order('timestamp', ascending: true)
          .limit(limit);

      print('✅ Chat history loaded successfully: ${response.length} messages');
      
      // Return the list of chat messages
      return List<Map<String, dynamic>>.from(response);

    } on PostgrestException catch (e) {
      print('❌ PostgreSQL Error loading chat history: ${e.message}');
      print('   Error code: ${e.code}');
      print('   Error details: ${e.details}');
      return [];
    } catch (e) {
      print('❌ Unexpected error loading chat history: $e');
      return [];
    }
  }

  /// Get chat history statistics for a student
  /// 
  /// Parameters:
  /// - [studentId]: UUID of the student
  /// - [courseId]: Optional course filter
  /// 
  /// Returns:
  /// - Map with statistics (total_messages, total_questions, etc.)
  /// - Empty map if error occurred
  Future<Map<String, dynamic>> getChatStatistics({
    required String studentId,
  }) async {
    try {
      print('📊 AIChatHistoryService: Getting chat statistics...');
      print('   Student ID: $studentId');

      // Validate required parameters
      if (studentId.trim().isEmpty) {
        print('❌ Error: Student ID cannot be empty');
        return {};
      }

      // Build query for counting messages
      var query = _supabase
          .from('ai_chat_history')
          .select('id, timestamp');

      // Apply filters
      query = query.eq('student_id', studentId.trim());

      final response = await query;

      // Calculate statistics
      final totalMessages = response.length;
      
      // Get date range
      DateTime? firstMessage, lastMessage;
      if (response.isNotEmpty) {
        final timestamps = response
            .map((r) => DateTime.parse(r['timestamp']))
            .toList()
          ..sort();
        
        firstMessage = timestamps.first;
        lastMessage = timestamps.last;
      }

      final statistics = {
        'total_messages': totalMessages,
        'student_id': studentId,
        'first_message_date': firstMessage?.toIso8601String(),
        'last_message_date': lastMessage?.toIso8601String(),
        'generated_at': DateTime.now().toUtc().toIso8601String(),
      };

      print('✅ Chat statistics generated successfully');
      return statistics;

    } on PostgrestException catch (e) {
      print('❌ PostgreSQL Error getting chat statistics: ${e.message}');
      return {};
    } catch (e) {
      print('❌ Unexpected error getting chat statistics: $e');
      return {};
    }
  }

  /// Delete all chat history for a student (optional: within a specific course/content)
  /// 
  /// Parameters:
  /// - [studentId]: UUID of the student
  /// - [courseId]: Optional course filter
  /// - [contentId]: Optional content filter
  /// 
  /// Returns:
  /// - true if deletion successful
  /// - false if deletion failed
  Future<bool> deleteChatHistory({
    required String studentId,
    String? contentId,
  }) async {
    try {
      print('🗑️ AIChatHistoryService: Deleting chat history...');
      print('   Student ID: $studentId');
      print('   Content ID: ${contentId ?? "null"}');

      // Validate required parameters
      if (studentId.trim().isEmpty) {
        print('❌ Error: Student ID cannot be empty');
        return false;
      }

      // Build delete query
      var deleteQuery = _supabase
          .from('ai_chat_history')
          .delete()
          .eq('student_id', studentId.trim());

      if (contentId != null && contentId.trim().isNotEmpty) {
        deleteQuery = deleteQuery.eq('content_id', contentId.trim());
      }

      // Execute deletion
      await deleteQuery;

      print('✅ Chat history deleted successfully');
      return true;

    } on PostgrestException catch (e) {
      print('❌ PostgreSQL Error deleting chat history: ${e.message}');
      print('   Error code: ${e.code}');
      return false;
    } catch (e) {
      print('❌ Unexpected error deleting chat history: $e');
      return false;
    }
  }

  /// Get recent chat messages across all courses for a student
  /// Useful for showing recent activity or continuing conversations
  /// 
  /// Parameters:
  /// - [studentId]: UUID of the student
  /// - [limit]: Number of recent messages to get (default: 10)
  /// 
  /// Returns:
  /// - List of recent chat messages with course context
  Future<List<Map<String, dynamic>>> getRecentChatMessages({
    required String studentId,
    int limit = 10,
  }) async {
    try {
      print('⏰ AIChatHistoryService: Getting recent chat messages...');
      print('   Student ID: $studentId');
      print('   Limit: $limit');

      // Validate parameters
      if (studentId.trim().isEmpty) {
        print('❌ Error: Student ID cannot be empty');
        return [];
      }

      if (limit <= 0) {
        print('❌ Error: Limit must be greater than 0');
        return [];
      }

      // Get recent messages
      final response = await _supabase
          .from('ai_chat_history')
          .select('''
            id,
            student_id,
            content_id,
            question,
            answer,
            timestamp
          ''')
          .eq('student_id', studentId.trim())
          .order('timestamp', ascending: false)
          .limit(limit);

      print('✅ Recent chat messages loaded: ${response.length} messages');
      return List<Map<String, dynamic>>.from(response);

    } on PostgrestException catch (e) {
      print('❌ PostgreSQL Error getting recent chat messages: ${e.message}');
      return [];
    } catch (e) {
      print('❌ Unexpected error getting recent chat messages: $e');
      return [];
    }
  }

  /// Search chat history by question content
  /// 
  /// Parameters:
  /// - [studentId]: UUID of the student
  /// - [searchQuery]: Text to search for in questions
  /// - [courseId]: Optional course filter
  /// - [limit]: Maximum results to return (default: 20)
  /// 
  /// Returns:
  /// - List of matching chat messages
  Future<List<Map<String, dynamic>>> searchChatHistory({
    required String studentId,
    required String searchQuery,
    int limit = 20,
  }) async {
    try {
  print('🔍 AIChatHistoryService: Searching chat history...');
  print('   Student ID: $studentId');
  print('   Search Query: "$searchQuery"');
  print('   Limit: $limit');

      // Validate parameters
      if (studentId.trim().isEmpty || searchQuery.trim().isEmpty) {
        print('❌ Error: Student ID and search query cannot be empty');
        return [];
      }

      // Build search query
      var query = _supabase
          .from('ai_chat_history')
          .select('''
            id,
            student_id,
            content_id,
            question,
            answer,
            timestamp
          ''')
          .eq('student_id', studentId.trim())
          .ilike('question', '%${searchQuery.trim()}%');

      // Order by relevance (most recent first) and apply limit
      final response = await query
          .order('timestamp', ascending: false)
          .limit(limit);

      print('✅ Chat history search completed: ${response.length} matches found');
      return List<Map<String, dynamic>>.from(response);

    } on PostgrestException catch (e) {
      print('❌ PostgreSQL Error searching chat history: ${e.message}');
      return [];
    } catch (e) {
      print('❌ Unexpected error searching chat history: $e');
      return [];
    }
  }
}