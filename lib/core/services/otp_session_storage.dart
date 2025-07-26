import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class OTPSessionStorage {
  static const String _otpPrefix = 'otp_session_';
  static const int _otpExpiryMinutes = 10;

  /// Stores OTP session data temporarily
  static Future<bool> storeOTPSession({
    required String email,
    required String otp,
    required String deviceId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final sessionData = {
        'email': email,
        'otp': _hashOTP(otp),
        'deviceId': deviceId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiryTime': DateTime.now()
            .add(Duration(minutes: _otpExpiryMinutes))
            .millisecondsSinceEpoch,
      };

      final sessionKey = _generateSessionKey(email, deviceId);
      final success = await prefs.setString(
        '$_otpPrefix$sessionKey',
        jsonEncode(sessionData),
      );

      if (success) {
        print('✅ OTP session stored successfully for $email');
        // Clean up expired sessions
        _cleanupExpiredSessions();
      }

      return success;
    } catch (e) {
      print('❌ Failed to store OTP session: $e');
      return false;
    }
  }

  /// Verifies OTP against stored session
  static Future<bool> verifyOTP({
    required String email,
    required String otp,
    required String deviceId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey = _generateSessionKey(email, deviceId);
      final sessionDataJson = prefs.getString('$_otpPrefix$sessionKey');

      if (sessionDataJson == null) {
        print('❌ No OTP session found for $email');
        return false;
      }

      final sessionData = jsonDecode(sessionDataJson) as Map<String, dynamic>;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final expiryTime = sessionData['expiryTime'] as int;

      // Check if OTP has expired
      if (currentTime > expiryTime) {
        print('❌ OTP has expired for $email');
        await _removeOTPSession(email, deviceId);
        return false;
      }

      // Verify OTP
      final storedOTPHash = sessionData['otp'] as String;
      final providedOTPHash = _hashOTP(otp);

      if (storedOTPHash == providedOTPHash &&
          sessionData['email'] == email &&
          sessionData['deviceId'] == deviceId) {
        print('✅ OTP verification successful for $email');
        // Remove the session after successful verification
        await _removeOTPSession(email, deviceId);
        return true;
      } else {
        print('❌ Invalid OTP for $email');
        return false;
      }
    } catch (e) {
      print('❌ Failed to verify OTP: $e');
      return false;
    }
  }

  /// Checks if an OTP session exists for the given email and device
  static Future<bool> hasActiveSession({
    required String email,
    required String deviceId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey = _generateSessionKey(email, deviceId);
      final sessionDataJson = prefs.getString('$_otpPrefix$sessionKey');

      if (sessionDataJson == null) return false;

      final sessionData = jsonDecode(sessionDataJson) as Map<String, dynamic>;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final expiryTime = sessionData['expiryTime'] as int;

      if (currentTime > expiryTime) {
        // Session expired, remove it
        await _removeOTPSession(email, deviceId);
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Failed to check active session: $e');
      return false;
    }
  }

  /// Gets remaining time for OTP session in minutes
  static Future<int> getRemainingTimeMinutes({
    required String email,
    required String deviceId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey = _generateSessionKey(email, deviceId);
      final sessionDataJson = prefs.getString('$_otpPrefix$sessionKey');

      if (sessionDataJson == null) return 0;

      final sessionData = jsonDecode(sessionDataJson) as Map<String, dynamic>;
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      final expiryTime = sessionData['expiryTime'] as int;

      if (currentTime > expiryTime) return 0;

      final remainingMs = expiryTime - currentTime;
      return (remainingMs / 60000).ceil(); // Convert to minutes
    } catch (e) {
      print('❌ Failed to get remaining time: $e');
      return 0;
    }
  }

  /// Removes OTP session
  static Future<bool> _removeOTPSession(String email, String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionKey = _generateSessionKey(email, deviceId);
      return await prefs.remove('$_otpPrefix$sessionKey');
    } catch (e) {
      print('❌ Failed to remove OTP session: $e');
      return false;
    }
  }

  /// Generates a unique session key for email and device combination
  static String _generateSessionKey(String email, String deviceId) {
    final data = '$email:$deviceId';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString().substring(0, 16); // Use first 16 characters
  }

  /// Hashes OTP for secure storage
  static String _hashOTP(String otp) {
    final bytes = utf8.encode(otp);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Cleans up expired OTP sessions
  static Future<void> _cleanupExpiredSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      for (final key in keys) {
        if (key.startsWith(_otpPrefix)) {
          final sessionDataJson = prefs.getString(key);
          if (sessionDataJson != null) {
            try {
              final sessionData =
                  jsonDecode(sessionDataJson) as Map<String, dynamic>;
              final expiryTime = sessionData['expiryTime'] as int;

              if (currentTime > expiryTime) {
                await prefs.remove(key);
                print('🧹 Cleaned up expired OTP session: $key');
              }
            } catch (e) {
              // If we can't parse the session data, remove it
              await prefs.remove(key);
              print('🧹 Removed corrupted OTP session: $key');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Failed to cleanup expired sessions: $e');
    }
  }

  /// Clears all OTP sessions (useful for testing or logout)
  static Future<void> clearAllSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_otpPrefix)) {
          await prefs.remove(key);
        }
      }

      print('🧹 All OTP sessions cleared');
    } catch (e) {
      print('❌ Failed to clear all sessions: $e');
    }
  }
}
