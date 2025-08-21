import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import 'course_screen.dart';
import 'instructor_account_privacy_page.dart';
import 'instructor_terms_conditions_page.dart';
import 'instructor_privacy_policy_page.dart';
import 'instructor_help_support_page.dart';
import 'feedback pages/instructor_feedback_form_screen.dart';
import 'instructor_teaching_analytics_page.dart';

class InstructorSettingsPage extends StatefulWidget {
  const InstructorSettingsPage({super.key});

  @override
  State<InstructorSettingsPage> createState() => _InstructorSettingsPageState();
}

class _InstructorSettingsPageState extends State<InstructorSettingsPage> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Settings',
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
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionCard(
              'Teaching & Courses',
              [
                _buildSettingsTile(
                  context,
                  icon: Icons.school,
                  title: 'Course Management',
                  subtitle: 'Manage your courses and content',
                   onTap: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => const CourseScreen(),
                       ),
                     );
                   },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.analytics,
                  title: 'Teaching Analytics',
                  subtitle: 'View student progress and course performance',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InstructorTeachingAnalyticsPage(),
                      ),
                    );
                  },
                ),
              ],
              theme,
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              'Notifications',
              [
                // Replace the navigation tile with a toggle switch
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.accentLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: AppTheme.primaryTeal,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Notifications',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    'Manage push notifications and alerts',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (val) {
                      setState(() {
                        _notificationsEnabled = val;
                      });
                      // TODO: persist this setting to user preferences
                    },
                    activeColor: AppTheme.primaryTeal,
                  ),
                  onTap: () {
                    setState(() => _notificationsEnabled = !_notificationsEnabled);
                    // TODO: optionally open a detailed notifications settings page
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                ),
              ],
              theme,
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              'Account & Privacy',
              [
                _buildSettingsTile(
                  context,
                  icon: Icons.security,
                  title: 'Account & Privacy',
                  subtitle: 'Manage your account and privacy settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InstructorAccountPrivacyPage(),
                      ),
                    );
                  },
                ),
              ],
              theme,
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              'Legal',
              [
                _buildSettingsTile(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Terms & Conditions',
                  subtitle: 'View our terms of service',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InstructorTermsConditionsPage(),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Learn about data protection',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InstructorPrivacyPolicyPage(),
                      ),
                    );
                  },
                ),
              ],
              theme,
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              'Support',
              [
                _buildSettingsTile(
                  context,
                  icon: Icons.help_outline,
                  title: 'Help & Support',
                  subtitle: 'Get help with teaching on Knowble',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InstructorHelpSupportPage(),
                      ),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  subtitle: 'Help us improve the instructor experience',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InstructorFeedbackFormScreen(),
                      ),
                    );
                  },
                ),
              ],
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children, ThemeData theme) {
    return Container(
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = AppTheme.lightTheme;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.accentLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppTheme.primaryTeal,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.textSecondary,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppTheme.textSecondary,
        size: 16,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
