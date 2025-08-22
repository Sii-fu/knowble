import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to handle feedback-related notifications
/// Creates notifications when feedback is submitted or when admin adds notes
class FeedbackNotificationService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Create notification for admin when user submits feedback
  /// This notifies all admins about new feedback submission
  static Future<void> createNotificationForNewFeedback({
    required String feedbackId,
    required String feedbackType,
    required String feedbackCategory,
    required String submitterName,
    required String submitterRole,
    required String submitterId,
  }) async {
    try {
      print('🔔 Creating admin notification for new feedback...');

      // Get all admin users
      final adminUsers = await _supabase
          .from('users')
          .select('id')
          .eq('role', 'admin');

      if (adminUsers.isEmpty) {
        print('⚠️ No admin users found to notify');
        return;
      }

      // Create notification for each admin
      final notifications = <Map<String, dynamic>>[];
      for (final admin in adminUsers) {
        final adminId = admin['id'] as String;

        final notificationData = {
          'user_id': adminId,
          'title': 'New Feedback Submitted',
          'description':
              '$submitterName ($submitterRole) submitted a $feedbackType feedback in $feedbackCategory category',
          'priority': 'medium',
          'alert_time': DateTime.now().toIso8601String(),
          'navigate': '/admin/users', // Navigate to admin users page
          'created_at': DateTime.now().toIso8601String(),
          'is_read': false,
        };

        notifications.add(notificationData);
      }

      // Insert all notifications
      if (notifications.isNotEmpty) {
        await _supabase.from('notification').insert(notifications);

        print(
          '✅ Created ${notifications.length} admin notifications for feedback: $feedbackId',
        );
      }
    } catch (e) {
      print('❌ Error creating admin notification for feedback: $e');
    }
  }

  /// Create notification for user when admin adds notes to their feedback
  /// This notifies the feedback submitter about admin response
  static Future<void> createNotificationForAdminResponse({
    required String feedbackId,
    required String userId,
    required String adminNotes,
    required String feedbackStatus,
  }) async {
    try {
      print('🔔 Creating user notification for admin response...');

      // Get user details
      final userResponse = await _supabase
          .from('users')
          .select('name, role')
          .eq('id', userId)
          .maybeSingle();

      if (userResponse == null) {
        print('⚠️ User not found for notification');
        return;
      }

      final userName = userResponse['name'] as String? ?? 'User';

      // Determine notification title and description based on status
      String title;
      String description;

      switch (feedbackStatus.toLowerCase()) {
        case 'in_review':
          title = 'Feedback Under Review';
          description = 'Your feedback is now being reviewed by our team';
          break;
        case 'in_progress':
          title = 'Feedback In Progress';
          description = 'We are working on addressing your feedback';
          break;
        case 'resolved':
          title = 'Feedback Resolved';
          description =
              'Your feedback has been resolved. Check admin notes for details';
          break;
        case 'closed':
          title = 'Feedback Closed';
          description =
              'Your feedback has been closed. Check admin notes for details';
          break;
        default:
          title = 'Feedback Update';
          description = 'Your feedback has been updated by an administrator';
      }

      // Add admin notes preview if available
      if (adminNotes.trim().isNotEmpty) {
        final notePreview = adminNotes.length > 50
            ? '${adminNotes.substring(0, 50)}...'
            : adminNotes;
        description += '. Admin note: $notePreview';
      }

      final notificationData = {
        'user_id': userId,
        'title': title,
        'description': description,
        'priority': 'medium',
        'alert_time': DateTime.now().toIso8601String(),
        'navigate': '/feedback-history', // Navigate to feedback history page
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      };

      await _supabase.from('notification').insert(notificationData);

      print('✅ Created user notification for feedback response: $feedbackId');
      print('   👤 User: $userName');
      print('   📊 Status: $feedbackStatus');
    } catch (e) {
      print('❌ Error creating user notification for admin response: $e');
    }
  }

  /// Create notification for specific admin user
  /// Utility method for targeted admin notifications
  static Future<void> createNotificationForAdmin({
    required String adminId,
    required String title,
    required String description,
    String priority = 'medium',
    String? navigateTo,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final notificationData = {
        'user_id': adminId,
        'title': title,
        'description': description,
        'priority': priority,
        'alert_time': DateTime.now().toIso8601String(),
        'navigate': navigateTo ?? '/admin/users',
        'created_at': DateTime.now().toIso8601String(),
        'is_read': false,
      };

      await _supabase.from('notification').insert(notificationData);

      print('✅ Created admin notification: $title');
    } catch (e) {
      print('❌ Error creating admin notification: $e');
    }
  }

  /// Get all admin user IDs
  /// Helper method to get list of admin users for notifications
  static Future<List<String>> getAllAdminIds() async {
    try {
      final response = await _supabase
          .from('users')
          .select('id')
          .eq('role', 'admin');

      return response.map((user) => user['id'] as String).toList();
    } catch (e) {
      print('❌ Error getting admin IDs: $e');
      return [];
    }
  }

  /// Mark feedback notification as read
  /// Helper method to mark feedback-related notifications as read
  static Future<bool> markFeedbackNotificationAsRead(
    String notificationId,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated');
        return false;
      }

      await _supabase
          .from('notification')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', user.id);

      print('✅ Feedback notification marked as read: $notificationId');
      return true;
    } catch (e) {
      print('❌ Error marking feedback notification as read: $e');
      return false;
    }
  }
}
