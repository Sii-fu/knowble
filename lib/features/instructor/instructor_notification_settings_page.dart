import 'package:flutter/material.dart';
import '../../config/theme.dart';

class InstructorNotificationSettingsPage extends StatefulWidget {
  const InstructorNotificationSettingsPage({super.key});

  @override
  State<InstructorNotificationSettingsPage> createState() => _InstructorNotificationSettingsPageState();
}

class _InstructorNotificationSettingsPageState extends State<InstructorNotificationSettingsPage> {
  // Initial toggle states for instructor-specific notifications
  bool _newStudentEnrollments = true;
  bool _studentProgress = true;
  bool _courseCompletions = true;
  bool _studentQuestions = true;
  bool _courseReviews = true;
  bool _paymentNotifications = true;
  bool _systemUpdates = false;
  bool _soundEnabled = false;
  bool _vibrateEnabled = true;
  bool _generalNotifications = true;
  bool _messageNotifications = true;
  bool _reminders = true;

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
              'Student Activity',
              [
                _buildNotificationTile(
                  'New Student Enrollments',
                  'Get notified when students enroll in your courses',
                  _newStudentEnrollments,
                  (value) => setState(() => _newStudentEnrollments = value),
                ),
                _buildNotificationTile(
                  'Student Progress',
                  'Updates on student lesson completions and milestones',
                  _studentProgress,
                  (value) => setState(() => _studentProgress = value),
                ),
                _buildNotificationTile(
                  'Course Completions',
                  'When students complete your courses',
                  _courseCompletions,
                  (value) => setState(() => _courseCompletions = value),
                ),
                _buildNotificationTile(
                  'Student Questions',
                  'When students ask questions or need help',
                  _studentQuestions,
                  (value) => setState(() => _studentQuestions = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              'Course Management',
              [
                _buildNotificationTile(
                  'Course Reviews',
                  'New reviews and ratings for your courses',
                  _courseReviews,
                  (value) => setState(() => _courseReviews = value),
                ),
                _buildNotificationTile(
                  'Payment Notifications',
                  'Earnings and payment-related updates',
                  _paymentNotifications,
                  (value) => setState(() => _paymentNotifications = value),
                ),
                _buildNotificationTile(
                  'System Updates',
                  'Platform updates and new instructor features',
                  _systemUpdates,
                  (value) => setState(() => _systemUpdates = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              'Sound & Vibration',
              [
                _buildNotificationTile(
                  'Sound',
                  'Play sound for notifications',
                  _soundEnabled,
                  (value) => setState(() => _soundEnabled = value),
                ),
                _buildNotificationTile(
                  'Vibrate',
                  'Vibrate for notifications',
                  _vibrateEnabled,
                  (value) => setState(() => _vibrateEnabled = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              'General',
              [
                _buildNotificationTile(
                  'General Notifications',
                  'App updates and important announcements',
                  _generalNotifications,
                  (value) => setState(() => _generalNotifications = value),
                ),
                _buildNotificationTile(
                  'Message Notifications',
                  'Direct messages from students and staff',
                  _messageNotifications,
                  (value) => setState(() => _messageNotifications = value),
                ),
                _buildNotificationTile(
                  'Reminders',
                  'Teaching schedule and deadline reminders',
                  _reminders,
                  (value) => setState(() => _reminders = value),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    final theme = AppTheme.lightTheme;
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

  Widget _buildNotificationTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final theme = AppTheme.lightTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
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
            inactiveThumbColor: AppTheme.borderSubtle,
            inactiveTrackColor: AppTheme.borderSubtle.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
