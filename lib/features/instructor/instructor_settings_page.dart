import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class InstructorSettingsPage extends StatelessWidget {
  const InstructorSettingsPage({super.key});

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
                  onTap: () => Navigator.pushNamed(context, '/instructor-course-management'),
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.analytics,
                  title: 'Teaching Analytics',
                  subtitle: 'View student progress and course performance',
                  onTap: () => Navigator.pushNamed(context, '/instructor-analytics'),
                ),
              ],
              theme,
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              'Notifications',
              [
                _buildSettingsTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Notification Settings',
                  subtitle: 'Manage push notifications and alerts',
                  onTap: () => Navigator.pushNamed(context, '/instructor-notification-settings'),
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
                  title: 'Account Security',
                  subtitle: 'Password and security settings',
                  onTap: () => Navigator.pushNamed(context, '/instructor-account-security'),
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Settings',
                  subtitle: 'Control your profile visibility',
                  onTap: () => Navigator.pushNamed(context, '/instructor-privacy-settings'),
                ),
              ],
              theme,
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              'Social',
              [
                _buildSettingsTile(
                  context,
                  icon: Icons.group_add,
                  title: 'Invite Instructors',
                  subtitle: 'Invite colleagues to join Knowble',
                  onTap: () => Navigator.pushNamed(context, '/instructor-invite-friends'),
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
                  onTap: () => Navigator.pushNamed(context, '/instructor-terms-conditions'),
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'Learn about data protection',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Privacy Policy coming soon!')),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help & Support coming soon!')),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.feedback_outlined,
                  title: 'Send Feedback',
                  subtitle: 'Help us improve the instructor experience',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feedback form coming soon!')),
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
