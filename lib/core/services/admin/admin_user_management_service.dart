import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/user.dart' as AppUser;
import '../feedback_notification_service.dart';

/// AdminUserManagementService handles all user management operations for admin
/// Manages users data retrieval and feedback information for admin dashboard
class AdminUserManagementService {
  // Get Supabase client instance
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all users with their basic information
  /// Returns list of users or empty list if none found
  Future<List<Map<String, dynamic>>> getAllUsers({
    int? limit,
    String? role,
    String? searchQuery,
    int offset = 0,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated');
        return [];
      }

      // Check if user is admin
      final currentUserRole = await _getCurrentUserRole();
      if (currentUserRole != 'admin') {
        print('❌ Only administrators can view all users');
        return [];
      }

      print('🔄 Fetching all users for admin...');

      var query = _supabase
          .from('users')
          .select(
            'id, name, email, role, profile_pic, bio, is_verified, created_at',
          );

      // Apply role filter if provided
      if (role != null && role.toLowerCase() != 'all') {
        query = query.eq('role', role.toLowerCase());
      }

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'name.ilike.%$searchQuery%,email.ilike.%$searchQuery%',
        );
      }

      // Apply ordering and pagination
      var finalQuery = query.order('created_at', ascending: false);

      if (offset > 0) {
        finalQuery = finalQuery.range(offset, offset + (limit ?? 50) - 1);
      } else if (limit != null) {
        finalQuery = finalQuery.limit(limit);
      }

      final response = await finalQuery;

      if (response.isEmpty) {
        print('📭 No users found');
        return [];
      }

      print('✅ Found ${response.length} users');

      // Process users data and add computed fields
      final users = response.map((userData) {
        return {
          'id': userData['id'],
          'name': userData['name'] ?? 'Unknown User',
          'email': userData['email'] ?? '',
          'role': _formatRole(userData['role']),
          'profileImage': userData['profile_pic'],
          'bio': userData['bio'],
          'isVerified': userData['is_verified'] ?? false,
          'registrationDate': userData['created_at'] != null
              ? DateTime.parse(userData['created_at'])
              : DateTime.now(),
          'status': userData['is_verified'] == true ? 'Active' : 'Pending',
          'lastActivity': DateTime.now().subtract(
            Duration(
              minutes: (userData['id'].hashCode % 1440)
                  .abs(), // Mock last activity
            ),
          ),
        };
      }).toList();

      return users;
    } on PostgrestException catch (e) {
      print('❌ Database error while fetching users: ${e.message}');
      return [];
    } catch (e) {
      print('❌ Unexpected error while fetching users: $e');
      return [];
    }
  }

  /// Get user feedback for a specific user
  /// Returns list of feedback for the user
  Future<List<Map<String, dynamic>>> getUserFeedback(String userId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated');
        return [];
      }

      // Check if user is admin
      final currentUserRole = await _getCurrentUserRole();
      if (currentUserRole != 'admin') {
        print('❌ Only administrators can view user feedback');
        return [];
      }

      print('🔄 Fetching feedback for user: $userId');

      final response = await _supabase
          .from('feedback_issues')
          .select('*')
          .eq('user_id', userId)
          .order('submitted_at', ascending: false);

      if (response.isEmpty) {
        print(' No feedback found for user');
        return [];
      }

      print('✅ Found ${response.length} feedback entries for user');

      // Convert to frontend format
      final feedbacks = response.map((feedbackData) {
        return {
          'id': feedbackData['id'],
          'type': feedbackData['type'],
          'category': feedbackData['category'],
          'message': feedbackData['message'],
          'status': feedbackData['status'],
          'submitted_at': DateTime.parse(feedbackData['submitted_at']),
          'resolved_at': feedbackData['resolved_at'] != null
              ? DateTime.parse(feedbackData['resolved_at'])
              : null,
          'admin_notes': feedbackData['admin_notes'],
        };
      }).toList();

      return feedbacks;
    } on PostgrestException catch (e) {
      print('❌ Database error while fetching user feedback: ${e.message}');
      return [];
    } catch (e) {
      print('❌ Unexpected error while fetching user feedback: $e');
      return [];
    }
  }

  /// Get users with their feedback counts
  /// Returns list of users with feedback statistics
  Future<List<Map<String, dynamic>>> getUsersWithFeedbackStats({
    int? limit,
    String? role,
    String? searchQuery,
    int offset = 0,
  }) async {
    try {
      // First get all users
      final users = await getAllUsers(
        limit: limit,
        role: role,
        searchQuery: searchQuery,
        offset: offset,
      );

      if (users.isEmpty) {
        return [];
      }

      // Get feedback counts for all users
      final userIds = users.map((user) => user['id'] as String).toList();

      final feedbackCounts = await _getFeedbackCountsForUsers(userIds);

      // Merge users with their feedback data
      final usersWithFeedback = users.map((user) {
        final userId = user['id'] as String;
        final userFeedback = feedbackCounts[userId] ?? [];

        return {
          ...user,
          'feedbacks': userFeedback,
          'feedbackCount': userFeedback.length,
          'pendingFeedbackCount': userFeedback
              .where(
                (f) => f['status'] == 'submitted' || f['status'] == 'in_review',
              )
              .length,
        };
      }).toList();

      return usersWithFeedback;
    } catch (e) {
      print('❌ Error getting users with feedback stats: $e');
      return [];
    }
  }

  /// Get users who have submitted complaints in feedback_issues table
  /// ONLY returns users that have feedback/complaints - for admin management
  Future<List<Map<String, dynamic>>> getUsersWithComplaints({
    int? limit,
    String? role,
    String? searchQuery,
    int offset = 0,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated');
        return [];
      }

      // Check if user is admin
      final currentUserRole = await _getCurrentUserRole();
      if (currentUserRole != 'admin') {
        print('❌ Only administrators can view users with complaints');
        return [];
      }

      print('🔄 Fetching users with complaints for admin...');

      // First, get all user IDs who have submitted feedback
      var feedbackQuery = _supabase.from('feedback_issues').select('user_id');

      final feedbackResponse = await feedbackQuery;

      if (feedbackResponse.isEmpty) {
        print('📭 No users with feedback found');
        return [];
      }

      // Get unique user IDs who have submitted feedback
      final userIdsWithFeedback = feedbackResponse
          .map((feedback) => feedback['user_id'] as String)
          .toSet() // Remove duplicates
          .toList();

      if (userIdsWithFeedback.isEmpty) {
        return [];
      }

      // Now get user details for these IDs
      var usersQuery = _supabase
          .from('users')
          .select(
            'id, name, email, role, profile_pic, bio, is_verified, created_at',
          )
          .inFilter('id', userIdsWithFeedback);

      // Apply role filter if provided
      if (role != null && role.toLowerCase() != 'all') {
        usersQuery = usersQuery.eq('role', role.toLowerCase());
      }

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        usersQuery = usersQuery.or(
          'name.ilike.%$searchQuery%,email.ilike.%$searchQuery%',
        );
      }

      // Apply ordering and get response
      final usersResponse = await usersQuery.order(
        'created_at',
        ascending: false,
      );

      if (usersResponse.isEmpty) {
        print('📭 No users found matching criteria');
        return [];
      }

      // Apply pagination manually since we need to paginate after filtering
      final startIndex = offset;
      final endIndex = limit != null
          ? startIndex + limit
          : usersResponse.length;
      final paginatedUsers = usersResponse.sublist(
        startIndex,
        endIndex > usersResponse.length ? usersResponse.length : endIndex,
      );

      print('✅ Found ${paginatedUsers.length} users with complaints');

      // Get feedback for these users
      final userIds = paginatedUsers
          .map((user) => user['id'] as String)
          .toList();
      final feedbackCounts = await _getFeedbackCountsForUsers(userIds);

      // Process users data and add computed fields with feedback
      final usersWithComplaints = paginatedUsers.map((userData) {
        final userId = userData['id'] as String;
        final userFeedback = feedbackCounts[userId] ?? [];

        return {
          'id': userData['id'],
          'name': userData['name'] ?? 'Unknown User',
          'email': userData['email'] ?? '',
          'role': _formatRole(userData['role']),
          'profileImage': userData['profile_pic'],
          'bio': userData['bio'],
          'isVerified': userData['is_verified'] ?? false,
          'registrationDate': userData['created_at'] != null
              ? DateTime.parse(userData['created_at'])
              : DateTime.now(),
          'status': userData['is_verified'] == true ? 'Active' : 'Pending',
          'lastActivity': DateTime.now().subtract(
            Duration(
              minutes: (userData['id'].hashCode % 1440)
                  .abs(), // Mock last activity
            ),
          ),
          'feedbacks': userFeedback,
          'feedbackCount': userFeedback.length,
          'pendingFeedbackCount': userFeedback
              .where(
                (f) => f['status'] == 'submitted' || f['status'] == 'in_review',
              )
              .length,
        };
      }).toList();

      return usersWithComplaints;
    } on PostgrestException catch (e) {
      print(
        '❌ Database error while fetching users with complaints: ${e.message}',
      );
      return [];
    } catch (e) {
      print('❌ Unexpected error while fetching users with complaints: $e');
      return [];
    }
  }

  /// Get feedback counts and basic info for multiple users
  Future<Map<String, List<Map<String, dynamic>>>> _getFeedbackCountsForUsers(
    List<String> userIds,
  ) async {
    try {
      if (userIds.isEmpty) return {};

      final response = await _supabase
          .from('feedback_issues')
          .select(
            'user_id, id, type, category, message, status, submitted_at, resolved_at, admin_notes',
          )
          .inFilter('user_id', userIds)
          .order('submitted_at', ascending: false);

      // Group feedback by user_id
      final feedbackByUser = <String, List<Map<String, dynamic>>>{};

      for (final feedback in response) {
        final userId = feedback['user_id'] as String;
        if (!feedbackByUser.containsKey(userId)) {
          feedbackByUser[userId] = [];
        }

        feedbackByUser[userId]!.add({
          'id': feedback['id'],
          'type': feedback['type'],
          'category': feedback['category'],
          'message': feedback['message'],
          'status': feedback['status'],
          'submitted_at': DateTime.parse(feedback['submitted_at']),
          'resolved_at': feedback['resolved_at'] != null
              ? DateTime.parse(feedback['resolved_at'])
              : null,
          'admin_notes': feedback['admin_notes'],
        });
      }

      return feedbackByUser;
    } catch (e) {
      print('❌ Error getting feedback counts for users: $e');
      return {};
    }
  }

  /// Update feedback status and admin notes
  Future<String?> updateFeedbackStatus({
    required String feedbackId,
    required String newStatus,
    String? adminNotes,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 'User not authenticated. Please log in again.';
      }

      // Check if user is admin
      final userRole = await _getCurrentUserRole();
      if (userRole != 'admin') {
        return 'Only administrators can update feedback status.';
      }

      // Validate status
      final validStatuses = [
        'submitted',
        'in_review',
        'in_progress',
        'resolved',
        'closed',
      ];
      if (!validStatuses.contains(newStatus)) {
        return 'Invalid status value. Valid statuses are: ${validStatuses.join(', ')}';
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

      // Get feedback details before updating to get user_id
      final feedbackResponse = await _supabase
          .from('feedback_issues')
          .select('user_id, type, category')
          .eq('id', feedbackId)
          .maybeSingle();

      if (feedbackResponse == null) {
        return 'Feedback not found.';
      }

      final feedbackUserId = feedbackResponse['user_id'] as String;

      await _supabase
          .from('feedback_issues')
          .update(updateData)
          .eq('id', feedbackId);

      print('✅ Feedback status updated successfully');
      print('   📝 Feedback ID: $feedbackId');
      print('   📊 New Status: $newStatus');

      // Create notification for user if admin added notes or changed status
      if (adminNotes != null && adminNotes.trim().isNotEmpty) {
        try {
          await FeedbackNotificationService.createNotificationForAdminResponse(
            feedbackId: feedbackId,
            userId: feedbackUserId,
            adminNotes: adminNotes.trim(),
            feedbackStatus: newStatus,
          );
          print('✅ User notification created for admin response');
        } catch (e) {
          print('⚠️ Failed to create user notification: $e');
          // Don't fail the feedback update if notification fails
        }
      }

      return null; // Success
    } on PostgrestException catch (e) {
      print('❌ Database error while updating feedback: ${e.message}');
      return 'Database error: ${e.message}';
    } catch (e) {
      print('❌ Unexpected error while updating feedback: $e');
      return 'An unexpected error occurred. Please try again later.';
    }
  }

  /// Get user statistics for admin dashboard
  Future<Map<String, dynamic>> getUserStatistics() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return {};
      }

      // Check if user is admin
      final userRole = await _getCurrentUserRole();
      if (userRole != 'admin') {
        return {};
      }

      print('🔄 Fetching user statistics for admin dashboard...');

      // Get total users count by role
      final usersResponse = await _supabase.from('users').select('role');

      // Get total feedback count and status breakdown
      final feedbackResponse = await _supabase
          .from('feedback_issues')
          .select('status');

      // Process user statistics
      final userStats = <String, int>{};
      for (final user in usersResponse) {
        final role = user['role'] as String? ?? 'unknown';
        userStats[role] = (userStats[role] ?? 0) + 1;
      }

      // Process feedback statistics
      final feedbackStats = <String, int>{};
      for (final feedback in feedbackResponse) {
        final status = feedback['status'] as String? ?? 'unknown';
        feedbackStats[status] = (feedbackStats[status] ?? 0) + 1;
      }

      final stats = {
        'totalUsers': usersResponse.length,
        'usersByRole': userStats,
        'totalFeedback': feedbackResponse.length,
        'feedbackByStatus': feedbackStats,
        'activeUsers': userStats.values.fold(0, (sum, count) => sum + count),
        'pendingFeedback':
            (feedbackStats['submitted'] ?? 0) +
            (feedbackStats['in_review'] ?? 0),
      };

      print('✅ User statistics retrieved: $stats');
      return stats;
    } catch (e) {
      print('❌ Error getting user statistics: $e');
      return {};
    }
  }

  /// Update user verification status (for instructor approval)
  Future<String?> updateUserVerificationStatus({
    required String userId,
    required bool isVerified,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return 'User not authenticated. Please log in again.';
      }

      // Check if user is admin
      final userRole = await _getCurrentUserRole();
      if (userRole != 'admin') {
        return 'Only administrators can update user verification status.';
      }

      await _supabase
          .from('users')
          .update({'is_verified': isVerified})
          .eq('id', userId);

      print('✅ User verification status updated successfully');
      print('   👤 User ID: $userId');
      print('   ✅ Verified: $isVerified');

      return null; // Success
    } on PostgrestException catch (e) {
      print('❌ Database error while updating user verification: ${e.message}');
      return 'Database error: ${e.message}';
    } catch (e) {
      print('❌ Unexpected error while updating user verification: $e');
      return 'An unexpected error occurred. Please try again later.';
    }
  }

  /// Get current user's role from the users table
  Future<String?> _getCurrentUserRole() async {
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

  /// Format role string for display
  String _formatRole(String? role) {
    if (role == null) return 'Unknown';

    switch (role.toLowerCase()) {
      case 'student':
        return 'Student';
      case 'instructor':
        return 'Instructor';
      case 'admin':
        return 'Admin';
      default:
        return role.substring(0, 1).toUpperCase() +
            role.substring(1).toLowerCase();
    }
  }

  /// Get user details by ID with feedback
  Future<Map<String, dynamic>?> getUserDetailsWithFeedback(
    String userId,
  ) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated');
        return null;
      }

      // Check if user is admin
      final currentUserRole = await _getCurrentUserRole();
      if (currentUserRole != 'admin') {
        print('❌ Only administrators can view user details');
        return null;
      }

      print('🔄 Fetching user details for: $userId');

      // Get user details
      final userResponse = await _supabase
          .from('users')
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (userResponse == null) {
        print('📭 User not found');
        return null;
      }

      // Get user feedback
      final feedbacks = await getUserFeedback(userId);

      final userDetails = {
        'id': userResponse['id'],
        'name': userResponse['name'] ?? 'Unknown User',
        'email': userResponse['email'] ?? '',
        'role': _formatRole(userResponse['role']),
        'profileImage': userResponse['profile_pic'],
        'bio': userResponse['bio'],
        'isVerified': userResponse['is_verified'] ?? false,
        'registrationDate': userResponse['created_at'] != null
            ? DateTime.parse(userResponse['created_at'])
            : DateTime.now(),
        'status': userResponse['is_verified'] == true ? 'Active' : 'Pending',
        'lastActivity': DateTime.now().subtract(
          Duration(minutes: (userResponse['id'].hashCode % 1440).abs()),
        ),
        'feedbacks': feedbacks,
        'feedbackCount': feedbacks.length,
        'pendingFeedbackCount': feedbacks
            .where(
              (f) => f['status'] == 'submitted' || f['status'] == 'in_review',
            )
            .length,
      };

      print('✅ User details retrieved successfully');
      return userDetails;
    } on PostgrestException catch (e) {
      print('❌ Database error while fetching user details: ${e.message}');
      return null;
    } catch (e) {
      print('❌ Unexpected error while fetching user details: $e');
      return null;
    }
  }

  /// Search users by name or email
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllUsers();
      }

      return await getAllUsers(searchQuery: query.trim());
    } catch (e) {
      print('❌ Error searching users: $e');
      return [];
    }
  }

  /// Get all users as User model objects
  /// Returns list of User objects or empty list if none found
  Future<List<AppUser.User>> getAllUsersAsModels({
    int? limit,
    String? role,
    String? searchQuery,
    int offset = 0,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated');
        return [];
      }

      // Check if user is admin
      final currentUserRole = await _getCurrentUserRole();
      if (currentUserRole != 'admin') {
        print('❌ Only administrators can view all users');
        return [];
      }

      print('🔄 Fetching all users as models for admin...');

      var query = _supabase.from('users').select('*');

      // Apply role filter if provided
      if (role != null && role.toLowerCase() != 'all') {
        query = query.eq('role', role.toLowerCase());
      }

      // Apply search filter if provided
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'name.ilike.%$searchQuery%,email.ilike.%$searchQuery%',
        );
      }

      // Apply ordering and pagination
      var finalQuery = query.order('created_at', ascending: false);

      if (offset > 0) {
        finalQuery = finalQuery.range(offset, offset + (limit ?? 50) - 1);
      } else if (limit != null) {
        finalQuery = finalQuery.limit(limit);
      }

      final response = await finalQuery;

      if (response.isEmpty) {
        print('📭 No users found');
        return [];
      }

      print('✅ Found ${response.length} users');

      // Convert to User model objects
      return response
          .map((userData) => AppUser.User.fromMap(userData))
          .toList();
    } on PostgrestException catch (e) {
      print('❌ Database error while fetching users: ${e.message}');
      return [];
    } catch (e) {
      print('❌ Unexpected error while fetching users: $e');
      return [];
    }
  }

  Map<String, List<String>> getFeedbackFilters() {
    return {
      'types': [
        'Complaint',
        'Bug',
        'Feature Request',
        'General Feedback',
        'User Experience',
        'Performance Issue',
        'Content Issue',
        'Other',
      ],
      'categories': [
        'Course',
        'Payment',
        'Instructor',
        'App UI',
        'Video Playback',
        'Course Content',
        'Course Management',
        'UI/UX',
        'Other',
      ],
      'statuses': [
        'submitted',
        'in_review',
        'in_progress',
        'resolved',
        'closed',
      ],
    };
  }
}
