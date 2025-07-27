import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class EmailService {
  // Email Configuration
  static const String _senderEmail = 'cloudezone121@gmail.com';
  static const String _appPassword = 'yacw prqu askb aduh';
  static const String _companyName = 'Knowble';
  static const String _tagline = 'Learn, Grow, Succeed';

  /// Sends forgot password OTP email
  static Future<bool> sendForgotPasswordOTP({
    required String recipientEmail,
    required String recipientName,
    required String otp,
  }) async {
    try {
      // Use API-based email sending (works on all platforms)
      return await _sendEmailViaAPI(
        recipientEmail: recipientEmail,
        recipientName: recipientName,
        otp: otp,
      );
    } catch (e) {
      print('❌ Failed to send email: $e');
      return false;
    }
  }

  /// Sends email via API (works on all platforms)
  static Future<bool> _sendEmailViaAPI({
    required String recipientEmail,
    required String recipientName,
    required String otp,
  }) async {
    try {
      print('📧 Sending password reset email to: $recipientEmail');
      print('📧 From: $_senderEmail ($_companyName)');
      print('📧 OTP Code: $otp');
      print('📧 Subject: Reset Your Password - $_companyName');

      // Create the email content
      final emailContent = _buildEmailContent(recipientName, otp);
      print('📧 Email Content Preview:');
      print(emailContent);

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // TODO: Replace with actual email service integration
      // Example integrations:
      // 1. EmailJS for frontend-only solution
      // 2. Your backend API endpoint
      // 3. Third-party services like SendGrid, Mailgun, etc.

      /*
      // Example backend API call:
      final response = await http.post(
        Uri.parse('https://your-backend.com/api/send-email'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer your-api-key',
        },
        body: jsonEncode({
          'to': recipientEmail,
          'from': _senderEmail,
          'subject': 'Reset Your Password - $_companyName',
          'html': _buildHTMLEmailTemplate(recipientName, otp),
          'text': emailContent,
        }),
      );
      
      if (response.statusCode == 200) {
        print('✅ Email sent successfully via backend API');
        return true;
      } else {
        print('❌ Backend API error: ${response.statusCode}');
        return false;
      }
      */

      print('✅ Email sending simulated successfully');
      print('📧 Note: Integrate with actual email service for production');
      return true;
    } catch (e) {
      print('❌ Failed to send email via API: $e');
      return false;
    }
  }

  /// Builds email content (text version)
  static String _buildEmailContent(String recipientName, String otp) {
    return '''
Hello $recipientName,

We received a request to reset the password for your $_companyName account.

Your verification code is: $otp

This code will expire in 10 minutes for your security.

If you didn't request this password reset, please ignore this email.

Security Tips:
• Never share your verification code with anyone
• Use a strong, unique password for your account
• Log out from shared or public devices

Best regards,
The $_companyName Team
$_tagline

© ${DateTime.now().year} $_companyName. All rights reserved.

---
This email was sent from $_senderEmail
If you need assistance, contact our support team.
''';
  }

  /// Builds beautiful HTML email template
  static String _buildHTMLEmailTemplate(String recipientName, String otp) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reset Your Password - $_companyName</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; background-color: #f5f5f5; margin: 0; padding: 20px; }
        .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1); }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 30px; text-align: center; color: white; }
        .logo { width: 80px; height: 80px; background-color: rgba(255, 255, 255, 0.2); border-radius: 50%; margin: 0 auto 20px; display: flex; align-items: center; justify-content: center; font-size: 36px; font-weight: bold; }
        .header h1 { font-size: 28px; margin-bottom: 8px; font-weight: 600; }
        .tagline { font-size: 16px; opacity: 0.9; font-weight: 300; }
        .content { padding: 40px 30px; }
        .greeting { font-size: 20px; margin-bottom: 20px; color: #2c3e50; }
        .message { font-size: 16px; margin-bottom: 30px; color: #555; line-height: 1.7; }
        .otp-container { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); border-radius: 12px; padding: 30px; text-align: center; margin: 30px 0; box-shadow: 0 4px 15px rgba(240, 147, 251, 0.3); }
        .otp-label { color: white; font-size: 16px; margin-bottom: 10px; font-weight: 500; }
        .otp-code { background-color: rgba(255, 255, 255, 0.95); color: #2c3e50; font-size: 32px; font-weight: bold; padding: 15px 25px; border-radius: 8px; letter-spacing: 8px; display: inline-block; font-family: 'Courier New', monospace; border: 2px solid rgba(255, 255, 255, 0.3); }
        .warning { background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 8px; padding: 20px; margin: 25px 0; }
        .warning-text { color: #856404; font-size: 14px; line-height: 1.5; }
        .footer { background-color: #2c3e50; color: #ecf0f1; padding: 30px; text-align: center; font-size: 12px; }
        @media (max-width: 600px) { .container { margin: 10px; border-radius: 8px; } .header, .content, .footer { padding: 25px 20px; } .otp-code { font-size: 28px; letter-spacing: 6px; } }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">K</div>
            <h1>$_companyName</h1>
            <p class="tagline">$_tagline</p>
        </div>
        <div class="content">
            <h2 class="greeting">Hello $recipientName,</h2>
            <p class="message">We received a request to reset the password for your $_companyName account. To proceed with resetting your password, please use the verification code below:</p>
            <div class="otp-container">
                <p class="otp-label">Your Verification Code</p>
                <div class="otp-code">$otp</div>
            </div>
            <p class="message">This verification code will expire in <strong>10 minutes</strong> for your security. If you didn't request a password reset, please ignore this email.</p>
            <div class="warning">
                <span class="warning-text"><strong>Important:</strong> Never share this code with anyone. $_companyName support will never ask for your verification code.</span>
            </div>
        </div>
        <div class="footer">
            <p>This email was sent because you requested a password reset for your $_companyName account.</p>
            <p style="margin-top: 10px;">© ${DateTime.now().year} $_companyName. All rights reserved.</p>
        </div>
    </div>
</body>
</html>
    ''';
  }

  /// Generates a secure 6-digit OTP
  static String generateOTP() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Creates a session-based hash for OTP storage
  static String createOTPHash(String email, String otp, String deviceId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final data = '$email:$otp:$deviceId:$timestamp';
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
