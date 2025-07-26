import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class InstructorHelpSupportPage extends StatelessWidget {
  const InstructorHelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Help & Support'),
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
                  'Help & Support',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Need assistance? We are here to help you with any questions or issues you may have as an instructor on Knowble.',
                  style: TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.6),
                ),
                SizedBox(height: 24),
                Text(
                  'Contact Support',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  'Email: support@knowble.com',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                SizedBox(height: 8),
                Text(
                  'Phone: +1-800-KNOWBLE',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                SizedBox(height: 24),
                Text(
                  'FAQs',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 8),
                Text(
                  '• How do I reset my password?\n  - Go to Account & Privacy > Change Password.\n\n• How do I contact support?\n  - Email us at support@knowble.com or use the Help & Support page.\n\n• Where can I find instructor resources?\n  - Visit our Help Center on the Knowble website.',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
                SizedBox(height: 24),
                Text(
                  'Still need help? Reach out to us anytime!',
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
