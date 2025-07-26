import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class InstructorPrivacyPolicyPage extends StatelessWidget {
  const InstructorPrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Privacy Policy'),
          backgroundColor: AppTheme.surfaceWhite,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0.5,
        ),
        backgroundColor: AppTheme.backgroundLight,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Your privacy is important to us. This policy explains how we collect, use, and protect your information on Knowble.',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  '1. Data Collection',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  'We collect information you provide when you register, create courses, or interact with the platform. This includes your name, email, course content, and usage data.',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                SizedBox(height: 20),
                Text(
                  '2. Use of Information',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  'Your data is used to provide and improve our services, personalize your experience, and communicate important updates.',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                SizedBox(height: 20),
                Text(
                  '3. Data Sharing',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  'We do not share your personal information with third parties except as required by law or with your explicit consent.',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                SizedBox(height: 20),
                Text(
                  '4. Security',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  'We implement industry-standard security measures to protect your data from unauthorized access.',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                SizedBox(height: 20),
                Text(
                  '5. Your Rights',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  'You can access, update, or delete your information at any time by contacting support.',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                SizedBox(height: 24),
                Text(
                  'For more details, please review our full privacy policy on our website or contact privacy@knowble.com.',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
