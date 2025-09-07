// admin_user_verification_service.dart
// Service for admin to manage user verification process

import 'package:supabase_flutter/supabase_flutter.dart';
import '../notification_data_service.dart';

class AdminUserVerificationService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Combined model for user with verification information
  static Map<String, dynamic> _combineUserData(Map<String, dynamic> userInfo) {
    final bool? isVerified = userInfo['is_verified'] as bool?;
    final String docs = (userInfo['user_documents'] ?? '') as String;

    // Derive a status since legacy columns do not exist:
    //  approved: is_verified == true
    //  pending: is_verified != true AND user_documents present
    //  not_submitted: no documents and not verified
    //  rejected: (not tracked – always absent) -> we won't surface
    String derivedStatus;
    if (isVerified == true) {
      derivedStatus = 'approved';
    } else if (docs.isNotEmpty) {
      derivedStatus = 'pending';
    } else {
      derivedStatus = 'not_submitted';
    }

    return {
      'id': userInfo['id'] ?? '',
      'name': userInfo['name'] ?? 'Unknown',
      'email': userInfo['email'] ?? '',
      'profileImage': userInfo['profile_pic'] ?? '',
      'role': userInfo['role'] ?? 'student',
      'isVerified': isVerified ?? false,
      'registrationDate': userInfo['created_at'] != null
          ? DateTime.parse(userInfo['created_at'])
          : DateTime.now(),
      'documentPath': docs,
      'documentType': '', // no column available
      'verificationStatus': derivedStatus,
      'verificationSubmittedAt': docs.isNotEmpty
          ? (userInfo['created_at'] != null
                ? DateTime.parse(userInfo['created_at'])
                : null)
          : null,
    };
  }

  /// Get all users pending verification (derived: has user_documents and not is_verified)
  static Future<List<Map<String, dynamic>>> getUsersPendingVerification({
    int? limit,
    int? offset,
  }) async {
    try {
      print(
        '[DEBUG] AdminUserVerificationService: Getting users pending verification',
      );

      var query = _client
          .from('users')
          .select(
            'id, name, email, profile_pic, role, is_verified, created_at, user_documents',
          )
          .neq('role', 'instructor')
          .neq('role', 'admin')
          // pending derived condition: has docs and not verified
          .not('user_documents', 'is', null)
          .neq('user_documents', '')
          .or('is_verified.is.false,is_verified.is.null')
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 50) - 1);
      }

      final usersResponse = await query;
      print(
        '[DEBUG] Found ${(usersResponse as List).length} users pending verification at ${DateTime.now()}',
      );

      // Combine user data
      final List<Map<String, dynamic>> usersWithVerificationInfo = [];

      for (final userInfo in usersResponse) {
        final combinedData = _combineUserData(userInfo);
        usersWithVerificationInfo.add(combinedData);
      }

      print(
        '[DEBUG] Combined user verification data for ${usersWithVerificationInfo.length} users',
      );
      return usersWithVerificationInfo;
    } catch (e) {
      print('[ERROR] getUsersPendingVerification failed: $e');
      throw Exception('Failed to get users pending verification: $e');
    }
  }

  /// Get all users with their derived verification status (for admin overview)
  static Future<List<Map<String, dynamic>>> getAllUsersWithVerificationStatus({
    int? limit,
    int? offset,
    String? statusFilter, // 'pending', 'approved', 'rejected', 'not_submitted'
  }) async {
    try {
      print(
        '[DEBUG] AdminUserVerificationService: Getting all users with verification status',
      );

      // Start with base query
      var queryBuilder = _client
          .from('users')
          .select(
            'id, name, email, profile_pic, role, is_verified, created_at, user_documents',
          )
          .neq('role', 'instructor')
          .neq('role', 'admin');

      // Apply derived status filters
      if (statusFilter != null) {
        switch (statusFilter) {
          case 'approved':
            queryBuilder = queryBuilder.eq('is_verified', true);
            break;
          case 'pending':
            queryBuilder = queryBuilder
                .or('is_verified.is.false,is_verified.is.null')
                .not('user_documents', 'is', null)
                .neq('user_documents', '');
            break;
          case 'not_submitted':
            queryBuilder = queryBuilder
                .or('is_verified.is.false,is_verified.is.null')
                .or('user_documents.is.null,user_documents.eq.');
            break;
          case 'rejected':
            // No rejected state stored; return empty set quickly
            return [];
        }
      }

      // Apply ordering, limiting, and offset in final query
      final query = queryBuilder.order('created_at', ascending: false);

      final limitedQuery = limit != null ? query.limit(limit) : query;

      final finalQuery = offset != null
          ? limitedQuery.range(offset, offset + (limit ?? 50) - 1)
          : limitedQuery;

      final usersResponse = await finalQuery;
      print('[DEBUG] Found ${(usersResponse as List).length} users');

      // Combine user data
      final List<Map<String, dynamic>> usersWithVerificationInfo = [];

      for (final userInfo in usersResponse) {
        final combinedData = _combineUserData(userInfo);
        usersWithVerificationInfo.add(combinedData);
      }

      return usersWithVerificationInfo;
    } catch (e) {
      print('[ERROR] getAllUsersWithVerificationStatus failed: $e');
      throw Exception('Failed to get users with verification status: $e');
    }
  }

  /// Approve user verification
  static Future<bool> approveUserVerification(String userId) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Check if current user is admin
      final adminCheck = await _client
          .from('users')
          .select('role')
          .eq('id', currentUser.id)
          .single();

      if (adminCheck['role'] != 'admin') {
        throw Exception('Only administrators can approve user verification');
      }

      print('[DEBUG] Approving user verification for: $userId');

      // Update user verification status
      await _client
          .from('users')
          .update({'is_verified': true})
          .eq('id', userId);

      // Send notification to user
      await NotificationDataService.createUserVerificationApprovedNotification(
        userId,
      );

      print('[DEBUG] User verification approved successfully');
      return true;
    } catch (e) {
      print('[ERROR] approveUserVerification failed: $e');
      throw Exception('Failed to approve user verification: $e');
    }
  }

  /// Reject user verification
  static Future<bool> rejectUserVerification(
    String userId,
    String reason,
  ) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Check if current user is admin
      final adminCheck = await _client
          .from('users')
          .select('role')
          .eq('id', currentUser.id)
          .single();

      if (adminCheck['role'] != 'admin') {
        throw Exception('Only administrators can reject user verification');
      }

      print('[DEBUG] Rejecting user verification for: $userId');

      // Update user verification status
      // With no dedicated rejection columns, we only ensure is_verified is false.
      await _client
          .from('users')
          .update({'is_verified': false})
          .eq('id', userId);

      // Send notification to user
      await NotificationDataService.createUserVerificationRejectedNotification(
        userId,
        reason,
      );

      print('[DEBUG] User verification rejected successfully');
      return true;
    } catch (e) {
      print('[ERROR] rejectUserVerification failed: $e');
      throw Exception('Failed to reject user verification: $e');
    }
  }

  /// Get document download URL for user verification
  static Future<String?> getUserDocumentUrl(String documentPath) async {
    try {
      if (documentPath.isEmpty) {
        return null;
      }

      print('[DEBUG] Getting document URL for: $documentPath');

      // Get signed URL for the document
      final response = _client.storage
          .from('user-info')
          .createSignedUrl(documentPath, 3600); // 1 hour expiry

      print('[DEBUG] Document URL generated successfully');
      return response;
    } catch (e) {
      print('[ERROR] getUserDocumentUrl failed: $e');
      return null;
    }
  }

  /// Get verification statistics for admin dashboard
  static Future<Map<String, int>> getVerificationStatistics() async {
    try {
      print('[DEBUG] Getting verification statistics');

      // Approved
      final approvedResponse = await _client
          .from('users')
          .select('id')
          .eq('is_verified', true)
          .neq('role', 'instructor')
          .neq('role', 'admin');

      // Pending: has documents but not verified
      final pendingResponse = await _client
          .from('users')
          .select('id, user_documents, is_verified')
          .neq('role', 'instructor')
          .neq('role', 'admin');

      // Not submitted: no documents and not verified
      final notSubmittedResponse = await _client
          .from('users')
          .select('id, user_documents, is_verified')
          .neq('role', 'instructor')
          .neq('role', 'admin');

      int approved = (approvedResponse as List).length;
      int pending = 0;
      int notSubmitted = 0;

      for (final row in pendingResponse as List) {
        final docs = (row['user_documents'] ?? '') as String;
        final isV = row['is_verified'] == true;
        if (!isV && docs.isNotEmpty) pending++;
      }

      for (final row in notSubmittedResponse as List) {
        final docs = (row['user_documents'] ?? '') as String;
        final isV = row['is_verified'] == true;
        if (!isV && docs.isEmpty) notSubmitted++;
      }

      return {
        'pending': pending,
        'approved': approved,
        'rejected': 0, // not tracked
        'not_submitted': notSubmitted,
      };
    } catch (e) {
      print('[ERROR] getVerificationStatistics failed: $e');
      return {'pending': 0, 'approved': 0, 'rejected': 0, 'not_submitted': 0};
    }
  }

  /// Bulk approve user verifications
  static Future<List<String>> bulkApproveUserVerifications(
    List<String> userIds,
  ) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Check if current user is admin
      final adminCheck = await _client
          .from('users')
          .select('role')
          .eq('id', currentUser.id)
          .single();

      if (adminCheck['role'] != 'admin') {
        throw Exception('Only administrators can approve user verifications');
      }

      List<String> successfulApprovals = [];
      List<String> failedApprovals = [];

      for (final userId in userIds) {
        try {
          await approveUserVerification(userId);
          successfulApprovals.add(userId);
        } catch (e) {
          print('[ERROR] Failed to approve user $userId: $e');
          failedApprovals.add(userId);
        }
      }

      print(
        '[DEBUG] Bulk approval complete: ${successfulApprovals.length} successful, ${failedApprovals.length} failed',
      );
      return successfulApprovals;
    } catch (e) {
      print('[ERROR] bulkApproveUserVerifications failed: $e');
      throw Exception('Failed to bulk approve user verifications: $e');
    }
  }
}
