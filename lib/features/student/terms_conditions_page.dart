import 'package:flutter/material.dart';
import '../../config/theme.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Terms & Conditions',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: AppTheme.surfaceWhite,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0.5,
          shadowColor: AppTheme.shadowLight,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: AppTheme.backgroundLight,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            color: AppTheme.surfaceWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: AppTheme.borderSubtle,
                width: 1,
              ),
            ),
            elevation: 2,
            shadowColor: AppTheme.shadowLight,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.accentLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryTeal.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description,
                          color: AppTheme.primaryTeal,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Knowble Terms & Conditions',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: AppTheme.primaryTeal,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Last updated: ${_getFormattedDate()}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Introduction
                  _buildSection(
                    'Introduction',
                    'Welcome to Knowble! These terms and conditions outline the rules and regulations for the use of Knowble\'s educational platform and mobile application. By accessing this application, we assume you accept these terms and conditions. Do not continue to use Knowble if you do not agree to take all of the terms and conditions stated on this page.',
                    theme,
                  ),

                  // Condition & Attending
                  _buildSection(
                    'Condition & Attending',
                    'By using our platform, you agree to:\n\n'
                    '• Provide accurate and complete information when creating your account\n'
                    '• Maintain the confidentiality of your login credentials\n'
                    '• Use the platform solely for educational purposes\n'
                    '• Respect intellectual property rights of course content\n'
                    '• Not share, distribute, or resell course materials without permission\n'
                    '• Attend live sessions punctually and participate respectfully\n'
                    '• Complete coursework within specified timeframes\n'
                    '• Communicate professionally with instructors and fellow students',
                    theme,
                  ),

                  // Terms & Use
                  _buildSection(
                    'Terms & Use',
                    'The following terms apply to your use of Knowble:\n\n'
                    '**Account Registration:** You must be at least 13 years old to create an account. If you are under 18, you must have parental consent.\n\n'
                    '**Course Access:** Upon enrollment, you will have access to course materials for the duration specified in the course description. Some courses may offer lifetime access.\n\n'
                    '**Payment Terms:** All payments are processed securely through our payment partners. Refunds are available within 30 days of purchase if you are not satisfied with the course content.\n\n'
                    '**User Conduct:** You agree not to use the platform for any unlawful purposes or to transmit any harmful, offensive, or inappropriate content.\n\n'
                    '**Content Ownership:** All course materials, including videos, texts, and assignments, are the intellectual property of Knowble and its instructors.',
                    theme,
                  ),

                  // Privacy Policy
                  _buildSection(
                    'Privacy Policy',
                    'Your privacy is important to us. We collect and use your personal information to:\n\n'
                    '• Provide and improve our educational services\n'
                    '• Process payments and manage your account\n'
                    '• Send you course updates and important notifications\n'
                    '• Analyze usage patterns to enhance user experience\n\n'
                    'We do not sell or share your personal information with third parties without your consent, except as required by law.',
                    theme,
                  ),

                  // Limitation of Liability
                  _buildSection(
                    'Limitation of Liability',
                    'Knowble and its instructors shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the platform. Our total liability shall not exceed the amount you paid for the specific course in question.',
                    theme,
                  ),

                  // Modifications
                  _buildSection(
                    'Modifications',
                    'We reserve the right to modify these terms and conditions at any time. Changes will be effective immediately upon posting on the platform. Your continued use of Knowble after any changes constitutes acceptance of the new terms.',
                    theme,
                  ),

                  // Contact Information
                  _buildSection(
                    'Contact Information',
                    'If you have any questions about these Terms and Conditions, please contact us at:\n\n'
                    'Email: support@knowble.app\n'
                    'Phone: +1 (555) 123-4567\n'
                    'Address: 123 Education Street, Learning City, LC 12345',
                    theme,
                  ),

                  const SizedBox(height: 24),

                  // Acceptance notice
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryTeal.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: AppTheme.primaryTeal,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'By using Knowble, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppTheme.primaryTeal,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
            height: 1.6,
          ),
          textAlign: TextAlign.justify,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}
