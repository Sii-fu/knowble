import 'package:flutter/material.dart';
import '../../config/theme.dart';

class InstructorTermsConditionsPage extends StatelessWidget {
  const InstructorTermsConditionsPage({super.key});

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
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.borderSubtle,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructor Terms & Conditions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last updated: January 2024',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                _buildSection(
                  context,
                  '1. Instructor Agreement',
                  'By joining Knowble as an instructor, you agree to create and maintain high-quality educational content. You are responsible for the accuracy and relevance of your course materials.',
                ),

                _buildSection(
                  context,
                  '2. Content Ownership',
                  'You retain ownership of your original course content while granting Knowble the right to distribute your courses on our platform. Knowble reserves the right to remove content that violates our community guidelines.',
                ),

                _buildSection(
                  context,
                  '3. Revenue Sharing',
                  'Instructors receive a percentage of course sales as outlined in the instructor revenue agreement. Payments are processed monthly and subject to minimum thresholds and applicable taxes.',
                ),

                _buildSection(
                  context,
                  '4. Quality Standards',
                  'All courses must meet our quality standards including clear audio, engaging content, and proper course structure. Courses may be reviewed before publication.',
                ),

                _buildSection(
                  context,
                  '5. Student Interaction',
                  'Instructors are expected to respond to student questions in a timely manner and maintain professional communication at all times.',
                ),

                _buildSection(
                  context,
                  '6. Prohibited Content',
                  'Content that is harmful, discriminatory, illegal, or violates intellectual property rights is strictly prohibited. This includes hate speech, violence, and copyright infringement.',
                ),

                _buildSection(
                  context,
                  '7. Account Termination',
                  'Knowble reserves the right to terminate instructor accounts for violations of these terms, quality issues, or other reasonable causes with appropriate notice.',
                ),

                _buildSection(
                  context,
                  '8. Intellectual Property',
                  'Instructors must ensure they have the right to use all materials in their courses, including images, music, and third-party content.',
                ),

                _buildSection(
                  context,
                  '9. Platform Changes',
                  'Knowble may update features, policies, or terms with advance notice to instructors. Continued use of the platform constitutes acceptance of changes.',
                ),

                _buildSection(
                  context,
                  '10. Contact Information',
                  'For questions about these terms or instructor-related issues, please contact our instructor support team at instructor@knowble.com.',
                ),

                const SizedBox(height: 24),
                
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryTeal,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'These terms are binding and govern your relationship with Knowble as an instructor. Please read carefully and contact us with any questions.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary,
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
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final theme = AppTheme.lightTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
