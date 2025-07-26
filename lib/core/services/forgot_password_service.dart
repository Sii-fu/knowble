import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'email_service.dart'; // COMMENTED OUT FOR TESTING
import 'otp_session_storage.dart';

/// TESTING MODE ENABLED ⚠️
/// All email functionality has been commented out and replaced with hardcoded values:
/// - Any email input will be accepted in email_selection_screen
/// - OTP is hardcoded to '123456' for verification (6 digits)
/// - Password reset simulates success without actual database changes
/// - All dynamic database checks and email sending are bypassed
///
/// To restore production functionality:
/// 1. Uncomment the import 'email_service.dart'
/// 2. Uncomment the code blocks in each method
/// 3. Remove hardcoded values and testing print statements
/// 4. Remove testing notes from UI screens

class ForgotPasswordService {
  static final _supabase = Supabase.instance.client;

  /// Initiates the forgot password process
  static Future<ForgotPasswordResult> initiateForgotPassword({
    required String email,
  }) async {
    try {
      // COMMENTED OUT FOR TESTING - USING HARDCODED VALUES
      /*
      // Check if user exists in database
      final userExists = await _checkUserExists(email);
      if (!userExists) {
        return ForgotPasswordResult(
          success: false,
          message: 'No account found with this email address.',
        );
      }

      // Get user's full name for personalized email
      final userName = await _getUserName(email);

      // Get device ID for session management
      final deviceId = await _getDeviceId();

      // Check if there's already an active session
      final hasActiveSession = await OTPSessionStorage.hasActiveSession(
        email: email,
        deviceId: deviceId,
      );

      if (hasActiveSession) {
        final remainingTime = await OTPSessionStorage.getRemainingTimeMinutes(
          email: email,
          deviceId: deviceId,
        );
        return ForgotPasswordResult(
          success: false,
          message:
              'An OTP has already been sent. Please wait $remainingTime minutes before requesting a new one.',
        );
      }

      // Generate OTP
      final otp = EmailService.generateOTP();

      // Store OTP session
      final sessionStored = await OTPSessionStorage.storeOTPSession(
        email: email,
        otp: otp,
        deviceId: deviceId,
      );

      if (!sessionStored) {
        return ForgotPasswordResult(
          success: false,
          message: 'Failed to create verification session. Please try again.',
        );
      }

      // Send email
      final emailSent = await EmailService.sendForgotPasswordOTP(
        recipientEmail: email,
        recipientName: userName,
        otp: otp,
      );

      if (emailSent) {
        return ForgotPasswordResult(
          success: true,
          message: 'Verification code sent to your email address.',
        );
      } else {
        // Clean up session if email failed
        await OTPSessionStorage.clearAllSessions();
        return ForgotPasswordResult(
          success: false,
          message: 'Failed to send verification email. Please try again.',
        );
      }
      */

      // HARDCODED FOR TESTING - ACCEPT ANY EMAIL
      print('Accepting email: $email with hardcoded OTP: 123456');

      // Store hardcoded OTP session for testing
      final deviceId = await _getDeviceId();
      final sessionStored = await OTPSessionStorage.storeOTPSession(
        email: email,
        otp: '123456', // Hardcoded 6-digit OTP for testing
        deviceId: deviceId,
      );

      if (!sessionStored) {
        print(
          '⚠️ Failed to store hardcoded session, proceeding anyway for testing',
        );
      }

      return ForgotPasswordResult(
        success: true,
        message:
            'Verification code sent to your email address. (Testing: Use 123456)',
      );
    } catch (e) {
      print('❌ Error in initiateForgotPassword: $e');
      return ForgotPasswordResult(
        success: false,
        message: 'An unexpected error occurred. Please try again later.',
      );
    }
  }

  /// Verifies the OTP entered by the user
  static Future<ForgotPasswordResult> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      // COMMENTED OUT FOR TESTING - USING HARDCODED OTP
      /*
      final deviceId = await _getDeviceId();

      final isValid = await OTPSessionStorage.verifyOTP(
        email: email,
        otp: otp,
        deviceId: deviceId,
      );

      if (isValid) {
        return ForgotPasswordResult(
          success: true,
          message: 'OTP verified successfully.',
        );
      } else {
        return ForgotPasswordResult(
          success: false,
          message: 'Invalid or expired verification code.',
        );
      }
      */

      // HARDCODED FOR TESTING - ACCEPT ONLY '123456'
      print('Verifying OTP: $otp for email: $email');

      if (otp == '123456') {
        print('OTP verification successful');
        return ForgotPasswordResult(
          success: true,
          message: 'OTP verified successfully.',
        );
      } else {
        print('Invalid OTP, expected 123456, got: $otp');
        return ForgotPasswordResult(
          success: false,
          message: 'Invalid verification code. Use 123456 for testing.',
        );
      }
    } catch (e) {
      print('❌ Error in verifyOTP: $e');
      return ForgotPasswordResult(
        success: false,
        message: 'An error occurred while verifying the code.',
      );
    }
  }

  /// Resets the user's password (simplified version)
  static Future<ForgotPasswordResult> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      // COMMENTED OUT FOR TESTING - SKIP ACTUAL PASSWORD RESET
      /*
      // For security, we'll use Supabase's built-in password reset
      // This sends a password reset link to the user's email
      await _supabase.auth.resetPasswordForEmail(email);

      return ForgotPasswordResult(
        success: true,
        message: 'Password reset instructions sent to your email.',
      );
      */

      // HARDCODED FOR TESTING - SIMULATE SUCCESS
      print(']Simulating password reset for email: $email');
      print(
        'New password would be: ${newPassword.replaceAll(RegExp(r'.'), '*')}',
      );

      return ForgotPasswordResult(
        success: true,
        message: 'Password has been reset successfully! (Testing mode)',
      );
    } catch (e) {
      print('❌ Error in resetPassword: $e');
      return ForgotPasswordResult(
        success: false,
        message: 'An error occurred while processing your request.',
      );
    }
  }

  /// Updates password when user has valid session
  static Future<ForgotPasswordResult> updatePassword({
    required String newPassword,
  }) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user != null) {
        return ForgotPasswordResult(
          success: true,
          message: 'Password updated successfully.',
        );
      } else {
        return ForgotPasswordResult(
          success: false,
          message: 'Failed to update password. Please try again.',
        );
      }
    } catch (e) {
      print('❌ Error in updatePassword: $e');
      return ForgotPasswordResult(
        success: false,
        message: 'An error occurred while updating your password.',
      );
    }
  }

  /// Gets remaining time for current OTP session
  static Future<int> getRemainingTime(String email) async {
    try {
      final deviceId = await _getDeviceId();
      return await OTPSessionStorage.getRemainingTimeMinutes(
        email: email,
        deviceId: deviceId,
      );
    } catch (e) {
      print('❌ Error getting remaining time: $e');
      return 0;
    }
  }

  /// Resends OTP if current session has expired
  static Future<ForgotPasswordResult> resendOTP({required String email}) async {
    try {
      // COMMENTED OUT FOR TESTING - USING HARDCODED FLOW
      /*
      final deviceId = await _getDeviceId();

      // Check if there's an active session
      final hasActiveSession = await OTPSessionStorage.hasActiveSession(
        email: email,
        deviceId: deviceId,
      );

      if (hasActiveSession) {
        final remainingTime = await OTPSessionStorage.getRemainingTimeMinutes(
          email: email,
          deviceId: deviceId,
        );
        return ForgotPasswordResult(
          success: false,
          message:
              'Please wait $remainingTime minutes before requesting a new code.',
        );
      }

      // If no active session, initiate new forgot password process
      return await initiateForgotPassword(email: email);
      */

      // HARDCODED FOR TESTING - ALWAYS ALLOW RESEND
      print('🧪 TESTING MODE: Resending OTP for email: $email');

      return ForgotPasswordResult(
        success: true,
        message:
            'New verification code sent to your email address. (Testing: Use 123456)',
      );
    } catch (e) {
      print('❌ Error in resendOTP: $e');
      return ForgotPasswordResult(
        success: false,
        message: 'An error occurred while resending the code.',
      );
    }
  }

  /// Checks if user exists in the database
  static Future<bool> _checkUserExists(String email) async {
    try {
      // Try different possible column combinations to find the user
      final queries = ['id', 'id, email', '*'];

      for (final query in queries) {
        try {
          final response = await _supabase
              .from('users')
              .select(query)
              .eq('email', email)
              .maybeSingle();

          if (response != null) {
            print('✅ User found with email: $email');
            return true;
          }
        } catch (e) {
          print('⚠️ Query failed with "$query": $e');
          continue;
        }
      }

      print('❌ User not found with email: $email');
      return false;
    } catch (e) {
      print('❌ Error checking user existence: $e');
      return false;
    }
  }

  /// Gets user's name from database
  static Future<String> _getUserName(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select('name')
          .eq('email', email)
          .maybeSingle();

      if (response != null && response['name'] != null) {
        return response['name'] as String;
      }

      // Fallback to email username if no name found
      return email.split('@')[0];
    } catch (e) {
      print('❌ Error getting user name: $e');
      return email.split('@')[0];
    }
  }

  /// Gets device ID for session management
  static Future<String> _getDeviceId() async {
    try {
      // Check if we're running on web
      if (kIsWeb) {
        // For web, generate a session-based device ID
        final random = Random();
        return 'web_${random.nextInt(999999).toString().padLeft(6, '0')}';
      }

      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios';
      } else {
        // Fallback for other platforms
        final random = Random();
        return 'device_${random.nextInt(999999).toString().padLeft(6, '0')}';
      }
    } catch (e) {
      print('❌ Error getting device ID: $e');
      // Generate a fallback device ID
      final random = Random();
      return 'fallback_${random.nextInt(999999).toString().padLeft(6, '0')}';
    }
  }
}

/// Result class for forgot password operations
class ForgotPasswordResult {
  final bool success;
  final String message;

  ForgotPasswordResult({required this.success, required this.message});

  @override
  String toString() {
    return 'ForgotPasswordResult(success: $success, message: $message)';
  }
}
