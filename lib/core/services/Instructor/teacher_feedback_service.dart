import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/feedback.dart';
import '../feedback_notification_service.dart';

/// TeacherFeedbackService handles all feedback-related operations with Supabase for instructors
/// Manages feedback submissions and retrieval for instructors
class TeacherFeedbackService {
  // Get Supabase client instance
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Submit new feedback to the feedback_issues table
  /// Returns null if successful, error message if failed
  Future<String?> submitFeedback({
    required String type,
    required String category,
    required String message,
    String? status, // Optional status parameter
  }) async {
    try {
      // Get current authenticated user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 'User not authenticated. Please log in again.';
      }

      // Validate inputs
      print('🔍 Validating input values:');
      print('   Type: "$type"');
      print('   Category: "$category"');
      print(
        '   Message: "${message.substring(0, message.length > 50 ? 50 : message.length)}..."',
      );
      print('   Status: "$status"');

      final validationError = _validateFeedbackInput(
        type,
        category,
        message,
        status,
      );
      if (validationError != null) {
        print('❌ Validation failed: $validationError');
        return validationError;
      }

      print('✅ Input validation passed');

      // Fetch user information from users table
      final userResponse = await _supabase
          .from('users')
          .select('name, role')
          .eq('id', user.id)
          .maybeSingle();

      if (userResponse == null) {
        return 'User information not found. Please contact support.';
      }

      final userName = userResponse['name'] as String?;
      final userRole = userResponse['role'] as String?;

      if (userName == null || userRole == null) {
        return 'Incomplete user profile. Please update your profile.';
      }

      // Use provided status or default to 'submitted'
      final feedbackStatus = status ?? 'submitted';

      // Prepare feedback data for insertion
      final feedbackData = {
        'user_id': user.id,
        'user_role': userRole,
        'type': type,
        'category': category,
        'message': message.trim(),
        'status': feedbackStatus,
        'submitted_at': DateTime.now().toIso8601String(),
      };

      print('🔄 Submitting feedback to database...');
      print('   📋 Type: $type');
      print('   🏷️ Category: $category');
      print('   📊 Status: $feedbackStatus');
      print('   👤 User: $userName ($userRole)');

      // Insert feedback into feedback_issues table
      final response = await _supabase
          .from('feedback_issues')
          .insert(feedbackData)
          .select()
          .single();

      print('✅ Feedback submitted successfully');
      print('   📝 Feedback ID: ${response['id']}');
      print('   ⏰ Submitted at: ${response['submitted_at']}');

      // Create notification for admins about new feedback
      try {
        await FeedbackNotificationService.createNotificationForNewFeedback(
          feedbackId: response['id'].toString(),
          feedbackType: type,
          feedbackCategory: category,
          submitterName: userName,
          submitterRole: userRole,
          submitterId: user.id,
        );
        print('✅ Admin notification created for new feedback');
      } catch (e) {
        print('⚠️ Failed to create admin notification: $e');
        // Don't fail the feedback submission if notification fails
      }

      return null; // Success
    } on PostgrestException catch (e) {
      print('❌ Database error while submitting feedback: ${e.message}');
      return 'Database error: ${e.message}';
    } catch (e) {
      print('❌ Unexpected error while submitting feedback: $e');
      return 'An unexpected error occurred. Please try again later.';
    }
  }

  /// Get feedback history for the current user
  /// Returns list of feedback submissions or empty list if none found
  Future<List<Feedback>> getFeedbackHistory({
    int? limit,
    String? status,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated');
        return [];
      }

      print('🔄 Fetching feedback history for user: ${user.id}');

      var query = _supabase
          .from('feedback_issues')
          .select('*')
          .eq('user_id', user.id);

      // Apply status filter if provided
      if (status != null) {
        query = query.eq('status', status);
      }

      // Apply ordering and limit at the end
      var finalQuery = query.order('submitted_at', ascending: false);

      if (limit != null) {
        finalQuery = finalQuery.limit(limit);
      }

      final response = await finalQuery;

      if (response.isEmpty) {
        print('📭 No feedback found for user');
        return [];
      }

      print('✅ Found ${response.length} feedback entries');

      // Debug: Log the first feedback entry to see the data structure
      if (response.isNotEmpty) {
        print('📊 Sample feedback data: ${response.first}');
      }

      // Convert response to Feedback model objects
      return response
          .map((feedbackData) => Feedback.fromMap(feedbackData))
          .toList();
    } on PostgrestException catch (e) {
      print('❌ Database error while fetching feedback history: ${e.message}');
      return [];
    } catch (e) {
      print('❌ Unexpected error while fetching feedback history: $e');
      return [];
    }
  }

  /// Get a single feedback item by ID (for detail view)
  /// Useful to fetch latest version with admin notes
  Future<Feedback?> getFeedbackById(String feedbackId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated');
        return null;
      }

      print('🔄 Fetching feedback by ID: $feedbackId');

      final response = await _supabase
          .from('feedback_issues')
          .select('*')
          .eq('id', feedbackId)
          .eq(
            'user_id',
            user.id,
          ) // Ensure user can only access their own feedback
          .maybeSingle();

      if (response == null) {
        print('📭 Feedback not found or access denied');
        return null;
      }

      print('✅ Found feedback with ID: $feedbackId');
      return Feedback.fromMap(response);
    } on PostgrestException catch (e) {
      print('❌ Database error while fetching feedback: ${e.message}');
      return null;
    } catch (e) {
      print('❌ Unexpected error while fetching feedback: $e');
      return null;
    }
  }

  /// Get feedback statistics for the current user
  /// Returns a map with count of feedback by status
  Future<Map<String, int>> getFeedbackStats() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {};
      }

      print('🔄 Fetching feedback statistics for user: ${user.id}');

      final response = await _supabase
          .from('feedback_issues')
          .select('status')
          .eq('user_id', user.id);

      if (response.isEmpty) {
        return {};
      }

      // Count feedback by status
      final stats = <String, int>{};
      for (final feedback in response) {
        final status = feedback['status'] as String;
        stats[status] = (stats[status] ?? 0) + 1;
      }

      print('✅ Feedback statistics: $stats');
      return stats;
    } catch (e) {
      print('❌ Error fetching feedback statistics: $e');
      return {};
    }
  }

  /// Get current user's role from the users table
  Future<String?> getCurrentUserRole() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('users')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

      return response?['role'] as String?;
    } catch (e) {
      print('❌ Error getting user role: $e');
      return null;
    }
  }

  /// Get current user's name from the users table
  Future<String?> getCurrentUserName() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('users')
          .select('name')
          .eq('id', user.id)
          .maybeSingle();

      return response?['name'] as String?;
    } catch (e) {
      print('❌ Error getting user name: $e');
      return null;
    }
  }

  /// Get current user information (name and role)
  Future<Map<String, String>?> getCurrentUserInfo() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      final response = await _supabase
          .from('users')
          .select('name, role')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return null;

      return {
        'name': response['name'] as String? ?? 'Unknown User',
        'role': response['role'] as String? ?? 'Unknown Role',
        'id': user.id,
      };
    } catch (e) {
      print('❌ Error getting user info: $e');
      return null;
    }
  }

  /// Check if user can submit feedback (rate limiting)
  /// Returns true if user can submit, false if they need to wait
  Future<bool> canSubmitFeedback({int cooldownMinutes = 5}) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final cutoffTime = DateTime.now()
          .subtract(Duration(minutes: cooldownMinutes))
          .toIso8601String();

      final recentFeedback = await _supabase
          .from('feedback_issues')
          .select('id')
          .eq('user_id', user.id)
          .gte('submitted_at', cutoffTime)
          .limit(1);

      return recentFeedback.isEmpty;
    } catch (e) {
      print('❌ Error checking feedback cooldown: $e');
      // Allow submission if we can't check (fail open)
      return true;
    }
  }

  /// Get feedback types available for selection (matches form dropdown)
  List<String> getFeedbackTypes() {
    return [
      'Complaint',
      'Bug',
      'Feature Request',
      'General Feedback',
      'User Experience',
      'Performance Issue',
      'Content Issue',
      'Other',
    ];
  }

  /// Get feedback categories available for selection (matches form dropdown)
  List<String> getFeedbackCategories() {
    return ['Course', 'Payment', 'Student', 'App UI', 'Other'];
  }

  /// Get feedback status options
  List<String> getFeedbackStatuses() {
    return ['submitted', 'in_review', 'in_progress', 'resolved', 'closed'];
  }

  /// Validate feedback input data
  String? _validateFeedbackInput(
    String type,
    String category,
    String message,
    String? status,
  ) {
    // Validate type - must match dropdown values
    if (!getFeedbackTypes().contains(type)) {
      print('❌ Invalid type "$type". Valid types: ${getFeedbackTypes()}');
      return 'Invalid feedback type. Please select a valid type.';
    }

    // Validate category - must match dropdown values
    if (!getFeedbackCategories().contains(category)) {
      print(
        '❌ Invalid category "$category". Valid categories: ${getFeedbackCategories()}',
      );
      return 'Invalid feedback category. Please select a valid category.';
    }

    // Validate message - database requires NOT NULL
    if (message.trim().isEmpty) {
      return 'Feedback message cannot be empty.';
    }

    // Optional: Check reasonable message length
    if (message.trim().length > 5000) {
      return 'Feedback message is too long (max 5000 characters).';
    }

    // Validate status if provided
    if (status != null && status.trim().isNotEmpty) {
      final validStatuses = [
        'submitted',
        'in_review',
        'in_progress',
        'resolved',
        'closed',
      ];
      if (!validStatuses.contains(status.trim().toLowerCase())) {
        return 'Invalid status. Please select a valid status.';
      }
    }

    return null; // All validations passed
  }

  /// Validate status value
  bool isValidStatus(String status) {
    return getFeedbackStatuses().contains(status);
  }

  /// Update feedback status (for admin use)
  Future<String?> updateFeedbackStatus({
    required String feedbackId,
    required String newStatus,
    String? adminNotes,
  }) async {
    try {
      // Validate status
      if (!isValidStatus(newStatus)) {
        return 'Invalid status. Please select a valid status.';
      }

      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 'User not authenticated. Please log in again.';
      }

      // Check if user is admin
      final userRole = await getCurrentUserRole();
      if (userRole != 'admin') {
        return 'Access denied. Only administrators can update feedback status.';
      }

      final updateData = <String, dynamic>{'status': newStatus};

      // Add admin notes if provided
      if (adminNotes != null && adminNotes.trim().isNotEmpty) {
        updateData['admin_notes'] = adminNotes.trim();
      }

      // Set resolved_at timestamp if status is resolved or closed
      if (newStatus == 'resolved' || newStatus == 'closed') {
        updateData['resolved_at'] = DateTime.now().toIso8601String();
      }

      await _supabase
          .from('feedback_issues')
          .update(updateData)
          .eq('id', feedbackId);

      print('✅ Feedback status updated successfully');
      print('   📝 Feedback ID: $feedbackId');
      print('   📊 New Status: $newStatus');

      return null; // Success
    } on PostgrestException catch (e) {
      print('❌ Database error while updating feedback: ${e.message}');
      return 'Database error: ${e.message}';
    } catch (e) {
      print('❌ Unexpected error while updating feedback: $e');
      return 'An unexpected error occurred. Please try again later.';
    }
  }

  /// Get all feedback for admin view
  Future<List<Feedback>> getAllFeedback({
    int? limit,
    String? status,
    String? type,
    String? category,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated');
        return [];
      }

      // Check if user is admin
      final userRole = await getCurrentUserRole();
      if (userRole != 'admin') {
        print('❌ Access denied. Only administrators can view all feedback.');
        return [];
      }

      print('🔄 Fetching all feedback for admin...');

      var query = _supabase.from('feedback_issues').select('*');

      // Apply filters
      if (status != null) {
        query = query.eq('status', status);
      }
      if (type != null) {
        query = query.eq('type', type);
      }
      if (category != null) {
        query = query.eq('category', category);
      }

      // Apply ordering and limit
      var finalQuery = query.order('submitted_at', ascending: false);

      if (limit != null) {
        finalQuery = finalQuery.limit(limit);
      }

      final response = await finalQuery;

      if (response.isEmpty) {
        print('📭 No feedback found');
        return [];
      }

      print('✅ Found ${response.length} feedback entries');

      // Convert response to Feedback model objects
      return response
          .map((feedbackData) => Feedback.fromMap(feedbackData))
          .toList();
    } on PostgrestException catch (e) {
      print('❌ Database error while fetching all feedback: ${e.message}');
      return [];
    } catch (e) {
      print('❌ Unexpected error while fetching all feedback: $e');
      return [];
    }
  }
}
