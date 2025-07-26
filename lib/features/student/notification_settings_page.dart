import 'package:flutter/material.dart';
import '../../config/theme.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() => _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  // Initial toggle states
  bool _specialOffers = true;
  bool _soundEnabled = false;
  bool _vibrateEnabled = true;
  bool _generalNotifications = true;
  bool _courseUpdates = true;
  bool _messageNotifications = false;
  bool _reminders = true;
  bool _systemAlerts = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Notification',
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
              'Push Notifications',
              [
                _buildNotificationTile(
                  'General Notifications',
                  'Get notified about app updates and announcements',
                  _generalNotifications,
                  (value) => setState(() => _generalNotifications = value),
                ),
                _buildNotificationTile(
                  'Course Updates',
                  'Notifications about new courses and lessons',
                  _courseUpdates,
                  (value) => setState(() => _courseUpdates = value),
                ),
                _buildNotificationTile(
                  'Message Notifications',
                  'Get notified when you receive messages',
                  _messageNotifications,
                  (value) => setState(() => _messageNotifications = value),
                ),
                _buildNotificationTile(
                  'Reminders',
                  'Study reminders and deadline notifications',
                  _reminders,
                  (value) => setState(() => _reminders = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              'Sound & Vibration',
              [
                _buildNotificationTile(
                  'Sound',
                  'Play notification sounds',
                  _soundEnabled,
                  (value) => setState(() => _soundEnabled = value),
                ),
                _buildNotificationTile(
                  'Vibrate',
                  'Vibrate on notifications',
                  _vibrateEnabled,
                  (value) => setState(() => _vibrateEnabled = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              'Marketing',
              [
                _buildNotificationTile(
                  'Special Offers',
                  'Get notified about special promotions and offers',
                  _specialOffers,
                  (value) => setState(() => _specialOffers = value),
                ),
                _buildNotificationTile(
                  'System Alerts',
                  'Important system maintenance notifications',
                  _systemAlerts,
                  (value) => setState(() => _systemAlerts = value),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryTeal,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Notification Settings',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppTheme.primaryTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You can customize your notification preferences here. Changes will be saved automatically and take effect immediately.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    final theme = AppTheme.lightTheme;
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

  Widget _buildNotificationTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final theme = AppTheme.lightTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryTeal,
            activeTrackColor: AppTheme.primaryTeal.withOpacity(0.3),
            inactiveThumbColor: AppTheme.textSecondary,
            inactiveTrackColor: AppTheme.borderSubtle,
          ),
        ],
      ),
    );
  }
}
