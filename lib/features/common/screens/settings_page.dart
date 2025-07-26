import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
              'Notifications',
              [
                _buildSettingsTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Notification Settings',
                  subtitle: 'Manage push notifications and alerts',
                  onTap: () => Navigator.pushNamed(context, '/notification-settings'),
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
                  title: 'Invite Friends',
                  subtitle: 'Share Knowble with your friends',
                  onTap: () => Navigator.pushNamed(context, '/invite-friends'),
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
                  onTap: () => Navigator.pushNamed(context, '/terms-conditions'),
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
                  subtitle: 'Get help with using Knowble',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Help & Support coming soon!')),
                    );
                  },
                ),
                _buildSettingsTile(
                  context,
                  icon: Icons.info_outline,
                  title: 'About Knowble',
                  subtitle: 'App version and information',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Knowble',
                      applicationVersion: '1.0.0',
                      applicationIcon: Icon(
                        Icons.school,
                        color: AppTheme.primaryTeal,
                        size: 32,
                      ),
                      children: [
                        Text(
                          'Knowble is your companion for learning and growth.',
                          style: TextStyle(color: AppTheme.textPrimary),
                        ),
                      ],
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
    return Card(
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
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
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppTheme.textSecondary,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
