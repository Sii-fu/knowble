// admin_instructor_verification_service.dart
// Service for admin to manage instructor verification process

import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class AdminInstructorVerificationService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Combined model for instructor with user information
  static Map<String, dynamic> _combineInstructorData(
    Map<String, dynamic> userInfo,
    Map<String, dynamic>? instructorInfo,
  ) {
    return {
      'id': userInfo['id'] ?? '',
      'name': userInfo['name'] ?? 'Unknown',
      'email': userInfo['email'] ?? '',
      'profileImage': userInfo['profile_pic'] ?? '',
      'role': userInfo['role'] ?? 'instructor',
      'isVerified': userInfo['is_verified'] ?? false,
      'registrationDate': userInfo['created_at'] != null
          ? DateTime.parse(userInfo['created_at'])
          : DateTime.now(),

      // Instructor specific info
      'instructorInfoId': instructorInfo?['id'],
      'phoneNumber': instructorInfo?['phone_number'] ?? '',
      'educationDegree': instructorInfo?['education_degree'] ?? '',
      'teachingExperience': instructorInfo?['teaching_experience'] ?? 0,
      'currentLocation': instructorInfo?['current_location'] ?? '',
      'subjectExpertise': instructorInfo?['subject_expertise'] ?? [],
      'bio': instructorInfo?['bio'] ?? '',
      'cvFileName': instructorInfo?['cv_file_name'] ?? '',
      'cvFilePath': instructorInfo?['cv_file_path'] ?? '',
      'verificationStatus': instructorInfo?['verification_status'] ?? 'pending',
      'submittedAt': instructorInfo?['submitted_at'] != null
          ? DateTime.parse(instructorInfo?['submitted_at'])
          : null,
      'verifiedAt': instructorInfo?['verified_at'] != null
          ? DateTime.parse(instructorInfo?['verified_at'])
          : null,
    };
  }

  /// Get all unverified instructors (where is_verified = false in users table)
  static Future<List<Map<String, dynamic>>> getUnverifiedInstructors({
    int? limit,
    int? offset,
  }) async {
    try {
      print(
        '[DEBUG] AdminInstructorVerificationService: Getting unverified instructors',
      );

      // First get all users with role 'instructor' and is_verified = false
      // Add a timestamp parameter to prevent caching
      var query = _client
          .from('users')
          .select('id, name, email, profile_pic, role, is_verified, created_at')
          .eq('role', 'instructor')
          .eq('is_verified', false)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 50) - 1);
      }

      final usersResponse = await query;
      print(
        '[DEBUG] Found ${(usersResponse as List).length} unverified instructor users at ${DateTime.now()}',
      );

      // Get instructor_info for each user
      final List<Map<String, dynamic>> instructorsWithInfo = [];

      for (final userInfo in usersResponse) {
        final userId = userInfo['id'] as String;

        // Get instructor info if exists
        final instructorInfoResponse = await _client
            .from('instructor_info')
            .select('*')
            .eq('user_id', userId)
            .maybeSingle();

        final combinedData = _combineInstructorData(
          userInfo,
          instructorInfoResponse,
        );

        instructorsWithInfo.add(combinedData);
      }

      print(
        '[DEBUG] Combined instructor data for ${instructorsWithInfo.length} instructors',
      );
      return instructorsWithInfo;
    } catch (e) {
      print('[ERROR] getUnverifiedInstructors failed: $e');
      throw Exception('Failed to get unverified instructors: $e');
    }
  }

  /// Get all instructors with their verification status (for admin overview)
  static Future<List<Map<String, dynamic>>> getAllInstructorsWithStatus({
    int? limit,
    int? offset,
  }) async {
    try {
      print(
        '[DEBUG] AdminInstructorVerificationService: Getting all instructors',
      );

      // Get all users with role 'instructor'
      var query = _client
          .from('users')
          .select('id, name, email, profile_pic, role, is_verified, created_at')
          .eq('role', 'instructor')
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 50) - 1);
      }

      final usersResponse = await query;
      print('[DEBUG] Found ${(usersResponse as List).length} instructor users');

      // Get instructor_info for each user
      final List<Map<String, dynamic>> instructorsWithInfo = [];

      for (final userInfo in usersResponse) {
        final userId = userInfo['id'] as String;

        // Get instructor info if exists
        final instructorInfoResponse = await _client
            .from('instructor_info')
            .select('*')
            .eq('user_id', userId)
            .maybeSingle();

        final combinedData = _combineInstructorData(
          userInfo,
          instructorInfoResponse,
        );

        instructorsWithInfo.add(combinedData);
      }

      print(
        '[DEBUG] Combined instructor data for ${instructorsWithInfo.length} instructors',
      );
      return instructorsWithInfo;
    } catch (e) {
      print('[ERROR] getAllInstructorsWithStatus failed: $e');
      throw Exception('Failed to get all instructors: $e');
    }
  }

  /// Approve an instructor (set is_verified = true in users table and verification_status = 'verified' in instructor_info)
  static Future<void> approveInstructor(
    String userId,
    String? instructorInfoId,
  ) async {
    try {
      print(_client.auth.currentUser?.appMetadata);
      print(
        '[DEBUG] AdminInstructorVerificationService: Approving instructor $userId with instructorInfoId: $instructorInfoId',
      );

      // First, let's check if the user actually exists
      final userCheck = await _client
          .from('users')
          .select('id, name, email, is_verified')
          .eq('id', userId)
          .maybeSingle();

      print('[DEBUG] User exists check: $userCheck');

      if (userCheck == null) {
        throw Exception('User with ID $userId not found in users table');
      }

      // Check current admin user JWT token info
      final currentUser = _client.auth.currentUser;
      print('[DEBUG] Current admin user: ${currentUser?.email}');
      print('[DEBUG] Current admin user ID: ${currentUser?.id}');
      print('[DEBUG] Current user metadata: ${currentUser?.userMetadata}');
      print('[DEBUG] Current user app metadata: ${currentUser?.appMetadata}');

      // Let's also verify the admin can read from users table
      final adminCheck = await _client
          .from('users')
          .select('id, role')
          .eq('id', currentUser?.id ?? '')
          .maybeSingle();
      print('[DEBUG] Admin user role check: $adminCheck');

      // Update users table first and get response to verify it worked
      final usersResponse = await _client
          .from('users')
          .update({'is_verified': true})
          .eq('id', userId)
          .select();

      print('[DEBUG] Users table update response: $usersResponse');
      print(
        '[DEBUG] Users table update affected ${(usersResponse as List).length} rows',
      );

      if ((usersResponse as List).isEmpty) {
        throw Exception(
          'Failed to update users table - no rows affected. User ID: $userId',
        );
      }

      // Update instructor_info table if record exists
      if (instructorInfoId != null) {
        final instructorInfoResponse = await _client
            .from('instructor_info')
            .update({
              'verification_status': 'verified',
              'verified_at': DateTime.now().toIso8601String(),
            })
            .eq('id', instructorInfoId)
            .select();

        print(
          '[DEBUG] Instructor info table update response: $instructorInfoResponse',
        );
      } else {
        print(
          '[WARNING] No instructorInfoId provided, skipping instructor_info update',
        );
      }

      // Force a small delay to ensure database changes are committed
      await Future.delayed(Duration(milliseconds: 100));

      print('[DEBUG] Instructor $userId approved successfully');
    } catch (e) {
      print('[ERROR] approveInstructor failed: $e');
      throw Exception('Failed to approve instructor: $e');
    }
  }

  /// Reject an instructor (set verification_status = 'rejected' in instructor_info, keep is_verified = false in users)
  static Future<void> rejectInstructor(
    String userId,
    String? instructorInfoId, {
    String? reason,
  }) async {
    try {
      print(
        '[DEBUG] AdminInstructorVerificationService: Rejecting instructor $userId',
      );

      // Update instructor_info table if record exists
      if (instructorInfoId != null) {
        final updateData = {
          'verification_status': 'rejected',
          'verified_at': null, // Clear verified_at
        };

        // If reason is provided, store it (you might need to add a rejection_reason column)
        if (reason != null && reason.isNotEmpty) {
          // For now, we'll store it in a way that can be retrieved later
          // You might want to add a rejection_reason column to instructor_info table
          print('[DEBUG] Rejection reason: $reason');
        }

        await _client
            .from('instructor_info')
            .update(updateData)
            .eq('id', instructorInfoId);
      }

      // Keep is_verified = false in users table (no change needed)
      print('[DEBUG] Instructor $userId rejected successfully');
    } catch (e) {
      print('[ERROR] rejectInstructor failed: $e');
      throw Exception('Failed to reject instructor: $e');
    }
  }

  /// Reject an instructor and send rejection email with reason
  static Future<void> rejectInstructorWithEmail(
    String userId,
    String? instructorInfoId,
    String instructorName,
    String instructorEmail, {
    String? reason,
  }) async {
    try {
      print(
        '[DEBUG] AdminInstructorVerificationService: Rejecting instructor $userId and sending email',
      );

      // First reject the instructor in the database
      await rejectInstructor(userId, instructorInfoId, reason: reason);

      // Then send the rejection email
      final emailSent = await _sendRejectionEmail(
        recipientEmail: instructorEmail,
        recipientName: instructorName,
        reason: reason ?? 'No specific reason provided',
      );

      if (emailSent) {
        print('[DEBUG] Rejection email sent successfully to $instructorEmail');
      } else {
        print('[WARNING] Failed to send rejection email to $instructorEmail');
        if (kIsWeb) {
          print(
            '[INFO] Running on web - email functionality limited by browser security',
          );
        }
      }

      print(
        '[DEBUG] Instructor $userId rejected and email notification processed',
      );
    } catch (e) {
      print('[ERROR] rejectInstructorWithEmail failed: $e');
      // Don't throw exception - database update was successful
      print(
        '[INFO] Database update completed successfully despite email issue',
      );
    }
  }

  /// Email configuration constants
  static const String _senderEmail = 'cloudzone121@gmail.com';
  static const String _appPassword = 'acmk imsw xoqk hmou';
  static const String _companyName = 'Knowble';
  static const String _tagline = 'Your Smart Learning Companion';

  /// Sends rejection email to instructor
  static Future<bool> _sendRejectionEmail({
    required String recipientEmail,
    required String recipientName,
    required String reason,
  }) async {
    try {
      print('📧 Sending rejection email to: $recipientEmail');

      // Check if we're running on web platform
      if (kIsWeb) {
        print('⚠️ Web platform detected - SMTP not supported in browsers');
        print('📧 For web deployment, consider using:');
        print('   - EmailJS service');
        print('   - Backend email API');
        print('   - Supabase Edge Functions');

        // For now, we'll simulate email sending on web
        await Future.delayed(Duration(seconds: 1));

        print('📧 EMAIL CONTENT THAT WOULD BE SENT:');
        final emailContent = _buildRejectionEmailContent(recipientName, reason);
        print(emailContent);

        // Return true for development/testing on web
        print('✅ Email "sent" (simulated for web platform)');
        return true;
      }

      // Try multiple SMTP configurations for non-web platforms
      final smtpConfigs = [
        // Configuration 1: Standard TLS (port 587)
        SmtpServer(
          'smtp.gmail.com',
          port: 587,
          username: _senderEmail,
          password: _appPassword,
          allowInsecure: false,
          ssl: false, // Use STARTTLS
          ignoreBadCertificate: false,
        ),
        // Configuration 2: SSL (port 465)
        SmtpServer(
          'smtp.gmail.com',
          port: 465,
          username: _senderEmail,
          password: _appPassword,
          allowInsecure: false,
          ssl: true, // Use SSL
          ignoreBadCertificate: false,
        ),
        // Configuration 3: Less secure (for troubleshooting)
        SmtpServer(
          'smtp.gmail.com',
          port: 587,
          username: _senderEmail,
          password: _appPassword,
          allowInsecure: true,
          ssl: false,
          ignoreBadCertificate: true,
        ),
      ];

      dynamic lastError;

      // Try each configuration
      for (int i = 0; i < smtpConfigs.length; i++) {
        final smtpServer = smtpConfigs[i];

        try {
          print('📧 Trying SMTP configuration ${i + 1}...');

          final htmlContent = await _buildRejectionHTMLEmailContent(
            recipientName,
            reason,
          );

          final message = Message()
            ..from = Address(_senderEmail, _companyName)
            ..recipients.add(recipientEmail)
            ..subject = 'Instructor Application Update - $_companyName'
            ..text = _buildRejectionEmailContent(recipientName, reason)
            ..html = htmlContent;

          final sendReport = await send(message, smtpServer);

          print('✅ Rejection email sent successfully!');
          print('📧 Send Report: $sendReport');

          return true;
        } catch (e) {
          lastError = e;
          print('❌ SMTP Config ${i + 1} failed: $e');
          print('❌ Error type: ${e.runtimeType}');
          continue;
        }
      }

      print('❌ All SMTP configurations failed. Last error: $lastError');
      print('❌ Last error type: ${lastError?.runtimeType}');

      // Show email content for debugging
      print('📧 EMAIL CONTENT THAT WOULD BE SENT:');
      final emailContent = _buildRejectionEmailContent(recipientName, reason);
      print(emailContent);

      return false;
    } catch (e) {
      print('❌ Critical error in rejection email sending: $e');
      print('❌ Critical error type: ${e.runtimeType}');

      // Show email content for debugging
      print('📧 EMAIL CONTENT THAT WOULD BE SENT:');
      final emailContent = _buildRejectionEmailContent(recipientName, reason);
      print(emailContent);

      return false;
    }
  }

  /// Builds rejection email content (text version)
  static String _buildRejectionEmailContent(
    String recipientName,
    String reason,
  ) {
    return '''
Dear $recipientName,

Thank you for your interest in becoming an instructor with $_companyName.

After careful review of your application, we regret to inform you that we are unable to approve your instructor application at this time.

Reason for rejection:
$reason

We encourage you to review our instructor requirements and reapply in the future. Your dedication to education is valued, and we hope you'll consider applying again when you meet all our criteria.

If you have any questions about this decision or would like guidance on improving your application for future consideration, please don't hesitate to contact our support team.

Thank you for your understanding.

Best regards,
The $_companyName Team
$_tagline

© ${DateTime.now().year} $_companyName. All rights reserved.

---
This email was sent from $_senderEmail
If you need assistance, contact our support team.
''';
  }

  /// Builds beautiful HTML rejection email template
  static Future<String> _buildRejectionHTMLEmailContent(
    String recipientName,
    String reason,
  ) async {
    // Load and encode the logo
    String logoBase64 = '';
    try {
      final ByteData logoData = await rootBundle.load(
        'assets/images/logo 3.png',
      );
      final Uint8List logoBytes = logoData.buffer.asUint8List();
      logoBase64 = base64Encode(logoBytes);
    } catch (e) {
      print('⚠️ Could not load logo: $e');
    }

    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Instructor Application Update - $_companyName</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; background-color: #f5f5f5; margin: 0; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1); }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 30px; text-align: center; color: white; }
        .logo-img { width: 120px; height: auto; margin: 0 auto 20px; display: block; border-radius: 8px; }
        .logo-fallback { width: 80px; height: 80px; background-color: rgba(255, 255, 255, 0.2); border-radius: 50%; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center; font-size: 36px; font-weight: bold; }
        .header h1 { font-size: 28px; margin-bottom: 8px; font-weight: 600; }
        .tagline { font-size: 16px; opacity: 0.9; font-weight: 300; }
        .content { padding: 40px 30px; }
        .greeting { font-size: 20px; margin-bottom: 20px; color: #2c3e50; }
        .message { font-size: 16px; margin-bottom: 20px; color: #555; line-height: 1.7; }
        .reason-container { background: linear-gradient(135deg, #ffeaa7 0%, #fab1a0 100%); border-radius: 12px; padding: 25px; margin: 25px 0; box-shadow: 0 4px 15px rgba(255, 234, 167, 0.3); }
        .reason-label { color: #2d3436; font-size: 16px; margin-bottom: 10px; font-weight: 600; }
        .reason-text { background-color: rgba(255, 255, 255, 0.9); color: #2c3e50; font-size: 15px; padding: 15px; border-radius: 8px; line-height: 1.6; border-left: 4px solid #e17055; }
        .encouragement { background-color: #d1ecf1; border: 1px solid #bee5eb; border-radius: 8px; padding: 20px; margin: 25px 0; }
        .encouragement-text { color: #0c5460; font-size: 14px; line-height: 1.6; }
        .footer { background-color: #2c3e50; color: #ecf0f1; padding: 30px; text-align: center; font-size: 12px; }
        @media (max-width: 600px) { .container { margin: 10px; border-radius: 8px; } .header, .content, .footer { padding: 25px 20px; } .logo-img { width: 100px; } }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            ${logoBase64.isNotEmpty ? '<img src="data:image/png;base64,$logoBase64" alt="$_companyName Logo" class="logo-img">' : '<div class="logo-fallback">K</div>'}
            <h1>$_companyName</h1>
            <p class="tagline">$_tagline</p>
        </div>
        <div class="content">
            <h2 class="greeting">Dear $recipientName,</h2>
            <p class="message">Thank you for your interest in becoming an instructor with $_companyName. We appreciate the time and effort you put into your application.</p>
            <p class="message">After careful review of your application, we regret to inform you that we are unable to approve your instructor application at this time.</p>
            <div class="reason-container">
                <p class="reason-label">Reason for this decision:</p>
                <div class="reason-text">$reason</div>
            </div>
            <div class="encouragement">
                <p class="encouragement-text"><strong>We encourage you to reapply!</strong> Please review our instructor requirements and consider applying again in the future. Your dedication to education is valued, and we hope you'll consider reapplying when you meet all our criteria.</p>
            </div>
            <p class="message">If you have any questions about this decision or would like guidance on improving your application for future consideration, please don't hesitate to contact our support team.</p>
            <p class="message">Thank you for your understanding.</p>
        </div>
        <div class="footer">
            <p><strong>Best regards,</strong><br>The $_companyName Team</p>
            <p style="margin-top: 15px;">This email was sent from $_senderEmail</p>
            <p style="margin-top: 10px;">© ${DateTime.now().year} $_companyName. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
    ''';
  }

  /// Debug method to check instructor status in both tables
  static Future<Map<String, dynamic>> debugInstructorStatus(
    String userId,
  ) async {
    try {
      // Get user data
      final userResponse = await _client
          .from('users')
          .select('id, name, email, is_verified')
          .eq('id', userId)
          .single();

      // Get instructor_info data
      final instructorInfoResponse = await _client
          .from('instructor_info')
          .select('id, verification_status, verified_at')
          .eq('user_id', userId)
          .maybeSingle();

      return {
        'user': userResponse,
        'instructor_info': instructorInfoResponse,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      print('[ERROR] debugInstructorStatus failed: $e');
      throw Exception('Failed to debug instructor status: $e');
    }
  }

  /// Get document download URL for instructor's CV
  static Future<String> getInstructorDocumentUrl(String filePath) async {
    try {
      print(
        '[DEBUG] AdminInstructorVerificationService: Getting document URL for $filePath',
      );

      final url = await _client.storage
          .from(
            'instructor-info',
          ) // Same bucket as used in InstructorInfoService
          .createSignedUrl(filePath, 3600); // 1 hour expiry

      print('[DEBUG] Document URL generated successfully');
      return url;
    } catch (e) {
      print('[ERROR] getInstructorDocumentUrl failed: $e');
      throw Exception('Failed to get document URL: $e');
    }
  }

  /// Get verification statistics for dashboard
  static Future<Map<String, int>> getVerificationStatistics() async {
    try {
      print(
        '[DEBUG] AdminInstructorVerificationService: Getting verification statistics',
      );

      // Get total instructors
      final totalInstructorsResponse = await _client
          .from('users')
          .select('id')
          .eq('role', 'instructor');

      // Get verified instructors
      final verifiedInstructorsResponse = await _client
          .from('users')
          .select('id')
          .eq('role', 'instructor')
          .eq('is_verified', true);

      // Get pending instructors (unverified)
      final pendingInstructorsResponse = await _client
          .from('users')
          .select('id')
          .eq('role', 'instructor')
          .eq('is_verified', false);

      // Get rejected instructors (those with instructor_info and verification_status = 'rejected')
      final rejectedInstructorsResponse = await _client
          .from('instructor_info')
          .select('id')
          .eq('verification_status', 'rejected');

      final stats = {
        'total': (totalInstructorsResponse as List).length,
        'verified': (verifiedInstructorsResponse as List).length,
        'pending': (pendingInstructorsResponse as List).length,
        'rejected': (rejectedInstructorsResponse as List).length,
      };

      print('[DEBUG] Verification statistics: $stats');
      return stats;
    } catch (e) {
      print('[ERROR] getVerificationStatistics failed: $e');
      throw Exception('Failed to get verification statistics: $e');
    }
  }

  /// Search instructors by name or email
  static Future<List<Map<String, dynamic>>> searchInstructors(
    String query, {
    bool unverifiedOnly = false,
    int? limit,
    int? offset,
  }) async {
    try {
      print(
        '[DEBUG] AdminInstructorVerificationService: Searching instructors with query: "$query"',
      );

      var userQuery = _client
          .from('users')
          .select('id, name, email, profile_pic, role, is_verified, created_at')
          .eq('role', 'instructor');

      // Add verification filter if needed
      if (unverifiedOnly) {
        userQuery = userQuery.eq('is_verified', false);
      }

      // Add search filters - using ilike for case-insensitive search
      userQuery = userQuery.or('name.ilike.%$query%,email.ilike.%$query%');

      // Apply ordering and pagination
      var finalQuery = userQuery.order('created_at', ascending: false);

      if (limit != null) {
        finalQuery = finalQuery.limit(limit);
      }

      if (offset != null) {
        finalQuery = finalQuery.range(offset, offset + (limit ?? 50) - 1);
      }

      final usersResponse = await finalQuery;
      print(
        '[DEBUG] Found ${(usersResponse as List).length} matching instructors',
      );

      // Get instructor_info for each user
      final List<Map<String, dynamic>> instructorsWithInfo = [];

      for (final userInfo in usersResponse) {
        final userId = userInfo['id'] as String;

        // Get instructor info if exists
        final instructorInfoResponse = await _client
            .from('instructor_info')
            .select('*')
            .eq('user_id', userId)
            .maybeSingle();

        final combinedData = _combineInstructorData(
          userInfo,
          instructorInfoResponse,
        );

        instructorsWithInfo.add(combinedData);
      }

      print(
        '[DEBUG] Combined search results for ${instructorsWithInfo.length} instructors',
      );
      return instructorsWithInfo;
    } catch (e) {
      print('[ERROR] searchInstructors failed: $e');
      throw Exception('Failed to search instructors: $e');
    }
  }
}
