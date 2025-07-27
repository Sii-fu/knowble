import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';
import 'package:knowble_app/widgets/custom_icon_widget.dart';
import '../../widgets/notifications/notification_list_widget.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = false;

  // Track clicked/read notifications
  final Set<String> _clickedNotifications = <String>{};

  // Mock notification data grouped by date
  final Map<String, List<NotificationItem>> _notificationData = {
    'Today': [
      NotificationItem(
        id: '1',
        title: 'New Category Course.!',
        description:
            'New category course is now available. Check it out now and start learning today.',
        icon: 'school',
        iconColor: AppTheme.primaryTeal,
        timestamp: '2h ago',
        type: NotificationType.course,
      ),
      NotificationItem(
        id: '2',
        title: 'Today\'s Special Offers',
        description:
            'Don\'t miss out on today\'s special offers. Get up to 50% off on selected courses.',
        icon: 'local_offer',
        iconColor: AppTheme.warningAmber,
        timestamp: '4h ago',
        type: NotificationType.offer,
      ),
    ],
    'Yesterday': [
      NotificationItem(
        id: '3',
        title: 'Credit Card Connected.!',
        description:
            'Your credit card has been successfully connected to your account. You can now make payments.',
        icon: 'credit_card',
        iconColor: AppTheme.successGreen,
        timestamp: '1 day ago',
        type: NotificationType.payment,
      ),
      NotificationItem(
        id: '4',
        title: 'Account Setup Successful.!',
        description:
            'Your account has been set up successfully. Welcome to our learning platform!',
        icon: 'account_circle',
        iconColor: AppTheme.primaryTeal,
        timestamp: '1 day ago',
        type: NotificationType.account,
      ),
    ],
    'Nov 20 2022': [
      NotificationItem(
        id: '5',
        title: 'Course Assignment Due',
        description:
            'Reminder: Your assignment for Introduction to Flutter is due in 2 days. Submit before the deadline.',
        icon: 'assignment',
        iconColor: AppTheme.warningAmber,
        timestamp: 'Nov 20, 2022',
        type: NotificationType.course,
      ),
      NotificationItem(
        id: '6',
        title: 'Payment Confirmation',
        description:
            'Payment of \$29.99 for Premium Course Pack has been confirmed. Receipt sent to your email.',
        icon: 'payment',
        iconColor: AppTheme.successGreen,
        timestamp: 'Nov 20, 2022',
        type: NotificationType.payment,
      ),
    ],
  };

  // Handle notification tap to change color
  void _onNotificationTap(String notificationId) {
    setState(() {
      if (_clickedNotifications.contains(notificationId)) {
        _clickedNotifications.remove(notificationId);
      } else {
        _clickedNotifications.add(notificationId);
      }
    });
  }

  // Mark all notifications as read
  void _markAllAsRead() {
    setState(() {
      _clickedNotifications.clear();
      // Add all notification IDs to clicked set
      for (final notifications in _notificationData.values) {
        for (final notification in notifications) {
          _clickedNotifications.add(notification.id);
        }
      }
    });
  }

  // Clear all notifications
  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceWhite, // Add white background
          title: Text(
            'Clear All Notifications',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to clear all notifications? This action cannot be undone.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _notificationData.clear();
                  _clickedNotifications.clear();
                });
                Navigator.of(context).pop();
              },
              child: Text(
                'Clear All',
                style: TextStyle(color: AppTheme.errorRed),
              ),
            ),
          ],
        );
      },
    );
  }

  // Check if notification is clicked/read
  bool _isNotificationClicked(String notificationId) {
    return _clickedNotifications.contains(notificationId);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate refresh operation
      await Future.delayed(const Duration(seconds: 1));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and title
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 10.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.cardColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.lightTheme.shadowColor
                                    .withValues(alpha: 0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'arrow_back',
                              color: AppTheme.primaryTeal,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Notifications',
                            style: AppTheme.lightTheme.textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20.sp,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w), // Balance the back button
                    ],
                  ),
                  SizedBox(height: 1.h),
                  // Action buttons row
                  if (_notificationData.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: _markAllAsRead,
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'mark_email_read',
                                color: AppTheme.primaryTeal,
                                size: 4.w,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Read all',
                                style: TextStyle(
                                  color: AppTheme.primaryTeal,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 4.w),
                        GestureDetector(
                          onTap: _clearAllNotifications,
                          child: Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'delete_outline',
                                color: AppTheme.errorRed,
                                size: 4.w,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                'Clear all',
                                style: TextStyle(
                                  color: AppTheme.errorRed,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppTheme.primaryTeal,
                child: _notificationData.isEmpty
                    ? _buildEmptyState()
                    : NotificationListWidget(
                        notificationData: _notificationData,
                        isLoading: _isLoading,
                        onNotificationTap: _onNotificationTap,
                        isNotificationClicked: _isNotificationClicked,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'notifications_none',
            size: 64,
            color: AppTheme.textSecondary.withValues(alpha: 0.5),
          ),
          SizedBox(height: 2.h),
          Text(
            'No notifications yet',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontSize: 16.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'When you have notifications, they will appear here',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary.withValues(alpha: 0.7),
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Notification data model
class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String icon;
  final Color iconColor;
  final String timestamp;
  final NotificationType type;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.timestamp,
    required this.type,
    this.isRead = false,
  });
}

enum NotificationType { course, payment, account, offer, system }
