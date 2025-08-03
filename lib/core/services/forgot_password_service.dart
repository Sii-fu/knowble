import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'email_service.dart';
import 'otp_session_storage.dart';

class ForgotPasswordService {
  static final _supabase = Supabase.instance.client;

  /// Initiates the forgot password process
  static Future<ForgotPasswordResult> initiateForgotPassword({
    required String email,
  }) async {
    try {
      // Check if user exists in Supabase auth.users table
      final userExists = await _checkUserExistsInAuth(email);
      if (!userExists) {
        return ForgotPasswordResult(
          success: false,
          message: "You don't have an account with this email.",
        );
      }

      // Get user's full name from public.users table for personalized email
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
    } catch (e) {
      print('❌ Error in verifyOTP: $e');
      return ForgotPasswordResult(
        success: false,
        message: 'An error occurred while verifying the code.',
      );
    }
  }

  /// Updates the user's password in Supabase auth.users table
  static Future<ForgotPasswordResult> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      // First, verify the user still exists in auth
      final userExists = await _checkUserExistsInAuth(email);
      if (!userExists) {
        return ForgotPasswordResult(
          success: false,
          message: 'User account not found.',
        );
      }

      // Use RPC function to reset password
      try {
        final response = await _supabase.rpc(
          'reset_user_password',
          params: {'user_email': email, 'new_password': newPassword},
        );

        final result = response as Map<String, dynamic>?;
        final success = result?['success'] as bool? ?? false;
        final message = result?['message'] as String? ?? 'Unknown error';

        if (success) {
          // Clear OTP sessions after successful password reset
          await OTPSessionStorage.clearAllSessions();

          return ForgotPasswordResult(
            success: true,
            message:
                'Password has been reset successfully! You can now login with your new password.',
          );
        } else {
          return ForgotPasswordResult(success: false, message: message);
        }
      } catch (rpcError) {
        print('❌ RPC password reset failed: $rpcError');

        // Fallback: Use standard Supabase password reset
        await _supabase.auth.resetPasswordForEmail(email, redirectTo: null);

        return ForgotPasswordResult(
          success: true,
          message:
              'Password reset instructions have been sent to your email. Please check your inbox and follow the instructions.',
        );
      }
    } catch (e) {
      print('❌ Error in resetPassword: $e');
      return ForgotPasswordResult(
        success: false,
        message:
            'An error occurred while resetting your password. Please try again later.',
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
    } catch (e) {
      print('❌ Error in resendOTP: $e');
      return ForgotPasswordResult(
        success: false,
        message: 'An error occurred while resending the code.',
      );
    }
  }

  /// Checks if user exists in Supabase auth.users table
  static Future<bool> _checkUserExistsInAuth(String email) async {
    try {
      // Use RPC function to check if user exists
      final response = await _supabase.rpc(
        'check_user_exists_by_email',
        params: {'user_email': email},
      );

      final userExists = response as bool? ?? false;

      if (userExists) {
        print('✅ User found in auth.users with email: $email');
        return true;
      } else {
        print('❌ User not found in auth.users with email: $email');
        return false;
      }
    } catch (e) {
      print('❌ Error checking user existence via RPC: $e');

      // Fallback: Try to use password reset to check if user exists
      try {
        await _supabase.auth.resetPasswordForEmail(email, redirectTo: null);
        // If no error is thrown, user likely exists
        print('✅ User found via fallback method: $email');
        return true;
      } catch (fallbackError) {
        final errorMessage = fallbackError.toString().toLowerCase();
        if (errorMessage.contains('user not found') ||
            errorMessage.contains('invalid email') ||
            errorMessage.contains('email not found')) {
          print('❌ User not found via fallback: $email');
          return false;
        }
        // For other errors, assume user exists (to be safe)
        print('⚠️ Fallback auth error (assuming user exists): $fallbackError');
        return true;
      }
    }
  }

  /// Gets user's name from database
  static Future<String> _getUserName(String email) async {
    try {
      // Use RPC function to get user name
      final response = await _supabase.rpc(
        'get_user_name_by_email',
        params: {'user_email': email},
      );

      final userName = response as String?;

      if (userName != null && userName.isNotEmpty) {
        return userName;
      }

      // Fallback to email username if RPC fails
      return email.split('@')[0];
    } catch (e) {
      print('❌ Error getting user name via RPC: $e');

      // Fallback: Try direct database query
      try {
        final response = await _supabase
            .from('users')
            .select('name, full_name')
            .eq('email', email)
            .maybeSingle();

        if (response != null) {
          final name = response['name'] ?? response['full_name'];
          if (name != null && name.isNotEmpty) {
            return name as String;
          }
        }
      } catch (fallbackError) {
        print('❌ Fallback user name query failed: $fallbackError');
      }

      // Final fallback to email username
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
