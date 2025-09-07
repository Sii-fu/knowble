import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../notification_data_service.dart';

class UserVerificationService {
  static final SupabaseClient _client = Supabase.instance.client;
  static const String _bucketName = 'user-info';

  /// Upload user verification document to Supabase storage
  static Future<String> uploadVerificationDocument({
    required String userId,
    required String documentType,
    required String fileName,
    File? file,
    Uint8List? bytes,
  }) async {
    try {
      print('[DEBUG] Uploading verification document for user: $userId');

      // Generate unique file path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileExtension = fileName.split('.').last;
      final uniqueFileName = '${timestamp}_$documentType.$fileExtension';
      final filePath = 'users/$userId/$uniqueFileName';

      // Upload file based on platform
      // Provide a contentType hint (Supabase may validate against bucket policy)
      final contentType = _inferMimeType(fileExtension);

      if (kIsWeb && bytes != null) {
        await _client.storage
            .from(_bucketName)
            .uploadBinary(
              filePath,
              bytes,
              fileOptions: FileOptions(upsert: true, contentType: contentType),
            );
      } else if (!kIsWeb && file != null) {
        await _client.storage
            .from(_bucketName)
            .upload(
              filePath,
              file,
              fileOptions: FileOptions(upsert: true, contentType: contentType),
            );
      } else {
        throw Exception('No valid file provided');
      }

      print('[DEBUG] Document uploaded successfully to: $filePath');
      return filePath;
    } catch (e) {
      print('[ERROR] Failed to upload verification document: $e');
      throw Exception('Failed to upload verification document: $e');
    }
  }

  /// Submit user verification request
  static Future<bool> submitVerificationRequest({
    required String userId,
    required String documentType,
    required String documentPath,
  }) async {
    try {
      print('[DEBUG] Submitting verification request for user: $userId');

      // Get user details for notification
      final userResponse = await _client
          .from('users')
          .select('name')
          .eq('id', userId)
          .single();

      final userName = userResponse['name'] ?? 'Unknown User';

      // Update users table with document information
      // Only columns that actually exist: user_documents, is_verified
      await _client
          .from('users')
          .update({
            'user_documents': documentPath,
            // is_verified stays false until admin approves
          })
          .eq('id', userId);

      // Get admin users to notify
      final adminResponse = await _client
          .from('users')
          .select('id')
          .eq('role', 'admin')
          .limit(1);

      if (adminResponse.isNotEmpty) {
        final adminId = adminResponse[0]['id'];
        await NotificationDataService.createUserVerificationPendingNotification(
          adminId,
          userName,
        );
      }

      print('[DEBUG] Verification request submitted successfully');
      return true;
    } catch (e) {
      print('[ERROR] Failed to submit verification request: $e');
      return false;
    }
  }

  /// Get user verification status
  static Future<Map<String, dynamic>?> getUserVerificationStatus(
    String userId,
  ) async {
    try {
      final response = await _client
          .from('users')
          .select('user_documents, is_verified')
          .eq('id', userId)
          .single();
      // Derive a status similar to admin logic
      final docs = (response['user_documents'] ?? '') as String;
      final isVerified = response['is_verified'] == true;
      String status;
      if (isVerified) {
        status = 'approved';
      } else if (docs.isNotEmpty) {
        status = 'pending';
      } else {
        status = 'not_submitted';
      }
      return {
        'user_documents': docs,
        'is_verified': isVerified,
        'derived_status': status,
      };
    } catch (e) {
      print('[ERROR] Failed to get verification status: $e');
      return null;
    }
  }

  // Simple MIME inference for limited set (extend if needed)
  static String _inferMimeType(String ext) {
    switch (ext.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  /// Check if user is verified
  static Future<bool> isUserVerified(String userId) async {
    try {
      final response = await _client
          .from('users')
          .select('is_verified')
          .eq('id', userId)
          .single();

      return response['is_verified'] ?? false;
    } catch (e) {
      print('[ERROR] Failed to check verification status: $e');
      return false;
    }
  }
}
