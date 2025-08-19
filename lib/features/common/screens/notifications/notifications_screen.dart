import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:Knowble/config/theme.dart';
import 'package:Knowble/widgets/custom_icon_widget.dart';
import '../../widgets/notifications/notification_list_widget.dart';
import '../../../../core/services/notification_data_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  List<NotificationData> _allNotifications = [];

  // Track clicked/read notifications
  final Set<String> _clickedNotifications = <String>{};

  // Dynamic notification data grouped by date
  Map<String, List<NotificationItem>> _notificationData = {};

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  /// Load notifications from the database
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final notifications =
          await NotificationDataService.fetchUserNotifications();
      _allNotifications = notifications;

      // Convert to UI format and group by date
      final groupedData = NotificationDataService.groupNotificationsByDate(
        notifications,
      );
      final convertedData = <String, List<NotificationItem>>{};

      for (final entry in groupedData.entries) {
        convertedData[entry.key] = entry.value
            .map((notif) => notif.toNotificationItem())
            .toList();
      }

      // Initialize clicked notifications based on read status
      for (final notif in notifications) {
        if (notif.isRead) {
          _clickedNotifications.add(notif.id);
        }
      }

      if (mounted) {
        setState(() {
          _notificationData = convertedData;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to load notifications. Please try again.');
      }
    }
  }

  /// Show error message to user
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(4.w),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show success message to user
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(4.w),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Handle notification tap to navigate first, then mark as read
  void _onNotificationTap(String notificationId) async {
    try {
      // Find the notification data to get the navigate field
      final notification = _allNotifications.firstWhere(
        (notif) => notif.id == notificationId,
        orElse: () => throw Exception('Notification not found'),
      );

      // PRIMARY ACTION: Navigate to reminder details if navigate field contains reminder ID
      if (notification.navigate != null && notification.navigate!.isNotEmpty) {
        // Navigate to reminder details
        final navigationSuccess = await _navigateToReminderDetails(
          notification.navigate!,
        );

        // SECONDARY ACTION: Mark as read only if navigation was successful
        if (navigationSuccess) {
          await _markNotificationAsRead(notificationId);
        }
      } else {
        // If no navigation target, just mark as read (fallback behavior)
        await _markNotificationAsRead(notificationId);
        _showErrorSnackBar('No details available for this notification');
      }
    } catch (e) {
      print('Error handling notification tap: $e');
      _showErrorSnackBar('Failed to open notification');
    }
  }

  /// Mark a single notification as read
  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      // Update UI immediately for responsive feel
      setState(() {
        _clickedNotifications.add(notificationId);
      });

      // Update in database
      final success = await NotificationDataService.markNotificationAsRead(
        notificationId,
      );

      if (!success) {
        // Revert UI change if database update failed
        setState(() {
          _clickedNotifications.remove(notificationId);
        });
        _showErrorSnackBar('Failed to mark notification as read');
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      // Revert UI change on error
      setState(() {
        _clickedNotifications.remove(notificationId);
      });
    }
  }

  /// Navigate to reminder details page
  Future<bool> _navigateToReminderDetails(String reminderId) async {
    try {
      print('📱 Attempting to navigate to reminder: $reminderId');

      // First, verify the reminder exists and belongs to the user
      final reminderData = await NotificationDataService.getReminderDetails(
        reminderId,
      );

      if (reminderData == null) {
        _showErrorSnackBar('Reminder not found or no longer exists');
        return false;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // For now, show reminder details in a dialog
      // TODO: Replace this with navigation to your actual reminder details screen
      Navigator.pop(context); // Close loading dialog

      await _showReminderDetailsDialog(reminderData);

      // TODO: Uncomment and modify this when you have your reminder details screen ready
      // final result = await Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => ReminderDetailsScreen(reminderId: reminderId),
      //   ),
      // );
      // return result != null; // Return true if navigation was successful

      return true; // Return true since dialog was shown successfully
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      print('❌ Error navigating to reminder details: $e');
      _showErrorSnackBar('Failed to open reminder details');
      return false;
    }
  }

  /// Show reminder details in a dialog (temporary implementation)
  Future<void> _showReminderDetailsDialog(
    Map<String, dynamic> reminderData,
  ) async {
    final DateTime reminderTime = DateTime.parse(reminderData['time']);
    final DateTime? endTime = reminderData['end_time'] != null
        ? DateTime.parse(reminderData['end_time'])
        : null;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              CustomIconWidget(
                iconName: 'event_note',
                color: AppTheme.primaryTeal,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Reminder Details',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Title',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                reminderData['title'] ?? 'No title',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),

              // Description
              if (reminderData['description'] != null &&
                  reminderData['description'].toString().isNotEmpty) ...[
                Text(
                  'Description',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  reminderData['description'],
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 2.h),
              ],

              // Time
              Text(
                'Time',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'access_time',
                    color: AppTheme.primaryTeal,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}' +
                        (endTime != null
                            ? ' - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}'
                            : ''),
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),

              // Date
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'calendar_today',
                    color: AppTheme.primaryTeal,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${reminderTime.day}/${reminderTime.month}/${reminderTime.year}',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Priority
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'flag',
                    color: _getPriorityColor(
                      reminderData['priority'] ?? 'Medium',
                    ),
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Priority: ${reminderData['priority'] ?? 'Medium'}',
                    style: TextStyle(
                      color: _getPriorityColor(
                        reminderData['priority'] ?? 'Medium',
                      ),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Navigate to edit reminder screen
                _showSuccessSnackBar('Edit functionality coming soon');
              },
              child: Text(
                'Edit',
                style: TextStyle(
                  color: AppTheme.primaryTeal,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Get color based on priority
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return AppTheme.errorRed;
      case 'medium':
        return AppTheme.warningAmber;
      case 'low':
        return AppTheme.successGreen;
      default:
        return AppTheme.textSecondary;
    }
  }

  // Mark all notifications as read
  void _markAllAsRead() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final success =
          await NotificationDataService.markAllNotificationsAsRead();

      if (success) {
        setState(() {
          _clickedNotifications.clear();
          // Add all notification IDs to clicked set
          for (final notifications in _notificationData.values) {
            for (final notification in notifications) {
              _clickedNotifications.add(notification.id);
            }
          }
          _isLoading = false;
        });
        _showSuccessSnackBar('All notifications marked as read');
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to mark all notifications as read');
      }
    } catch (e) {
      print('Error marking all as read: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to mark all notifications as read');
    }
  }

  // Clear all notifications
  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceWhite,
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
              onPressed: () async {
                Navigator.of(context).pop();
                await _performClearAll();
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

  /// Perform the actual clear all operation
  Future<void> _performClearAll() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final success = await NotificationDataService.deleteAllNotifications();

      if (success) {
        setState(() {
          _notificationData.clear();
          _clickedNotifications.clear();
          _allNotifications.clear();
          _isLoading = false;
        });
        _showSuccessSnackBar('All notifications cleared');
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to clear notifications');
      }
    } catch (e) {
      print('Error clearing all notifications: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to clear notifications');
    }
  }

  // Check if notification is clicked/read
  bool _isNotificationClicked(String notificationId) {
    return _clickedNotifications.contains(notificationId);
  }

  Future<void> _onRefresh() async {
    await _loadNotifications();
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
