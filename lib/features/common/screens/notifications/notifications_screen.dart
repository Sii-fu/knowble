import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Knowble/config/theme.dart';
import 'package:Knowble/widgets/custom_icon_widget.dart';
import '../../widgets/notifications/notification_list_widget.dart';
import '../../../../core/services/notification_data_service.dart';
import '../../../../core/services/local_notification_service.dart';
import '../../../../data/models/reminder.dart';
import '../../../../core/services/Instructor/notification_instructor.dart';
import '../../../../core/services/notification_badge_service.dart';
import '../../../../core/services/notification_manager.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationBadgeService _badgeService = NotificationBadgeService();
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
      print('🔔 Handling notification tap for ID: $notificationId');
      
      // First, get the notification details to check its type
      final notificationData = await _getNotificationDetails(notificationId);
      
      if (notificationData == null) {
        _showErrorSnackBar('Notification not found');
        return;
      }

      final notificationType = notificationData['type'] as String? ?? 'general';
      final navigateValue = notificationData['navigate'] as String?;
      
      print('📱 Notification type: $notificationType, navigate: $navigateValue');

      // First, try to resolve as a course review (regardless of type)
      // This handles notifications where navigate contains a course_id
      final svc = NotificationInstructorService();
      final courseReviewDetails = await svc.resolveNotificationToClosestReview(notificationId);
      
      if (courseReviewDetails != null && courseReviewDetails['review'] != null) {
        // This is a course review notification
        print('📱 Found course review, showing review dialog');
        await _handleCourseReviewNotification(notificationId);
        return;
      }
      
      // If not a course review, check the navigate value format first
      if (navigateValue != null && navigateValue.isNotEmpty) {
        if (navigateValue.startsWith('/')) {
          // Navigate value is a path, navigate to that page (regardless of type)
          print('📱 Found path navigation, navigating to: $navigateValue');
          await _handlePathNavigation(notificationId, navigateValue);
          return;
        } else if (_isValidUuid(navigateValue)) {
          // Navigate value is a UUID, treat as task
          print('📱 Found UUID navigation, navigating to task: $navigateValue');
          await _handleTaskNotification(notificationId, navigateValue);
          return;
        }
      }
      
      // If navigate value doesn't match known formats, handle based on notification type
      switch (notificationType.toLowerCase()) {
        case 'course_reviews':
          // This should have been caught above, but just in case
          await _handleCourseReviewNotification(notificationId);
          break;
        case 'general':
        case 'task':
        case 'reminder':
          if (navigateValue != null && navigateValue.isNotEmpty) {
            await _handleTaskNotification(notificationId, navigateValue);
          } else {
            _showErrorSnackBar('No navigation value found for task notification');
          }
          break;
        case 'feedback':
          await _handleFeedbackNotification(notificationId, navigateValue);
          break;
        default:
          _showErrorSnackBar('Unknown notification type: $notificationType');
      }
    } catch (e) {
      print('❌ Error handling notification tap: $e');
      _showErrorSnackBar('Failed to open notification');
    }
  }

  /// Get notification details by ID
  Future<Map<String, dynamic>?> _getNotificationDetails(String notificationId) async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        print('❌ User not authenticated');
        return null;
      }

      final response = await supabase
          .from('notification')
          .select('*')
          .eq('id', notificationId)
          .eq('user_id', user.id)
          .maybeSingle();

      return response;
    } catch (e) {
      print('❌ Error fetching notification details: $e');
      return null;
    }
  }

  /// Handle course review notifications
  Future<void> _handleCourseReviewNotification(String notificationId) async {
    try {
      final svc = NotificationInstructorService();
      final details = await svc.resolveNotificationToClosestReview(notificationId);

      if (details != null && details['review'] != null) {
        final course = details['course'] as Map<String, dynamic>?;
        final student = details['student'] as Map<String, dynamic>?;
        final review = details['review'] as Map<String, dynamic>?;

        await showDialog<void>(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: AppTheme.primaryTeal,
            insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 420, maxHeight: 320),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              (course?['title'] as String? ?? 'C').substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course?['title'] ?? 'Course Review',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'From ${student?['full_name'] ?? student?['email'] ?? 'Student'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Rating row
                    if (review != null) ...[
                      Row(
                        children: [
                          for (int i = 0; i < 5; i++)
                            Icon(
                              i < ((review['rating'] as int?) ?? 0) ? Icons.star : Icons.star_border,
                              size: 16,
                              color: Colors.amber,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            '${review['rating'] ?? '-'} / 5',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    // Review text (scrollable)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          review?['review_text'] ?? 'No review text available.',
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

        // mark as read after showing
        await _markNotificationAsRead(notificationId);
      } else {
        _showErrorSnackBar('Course review not found for this notification');
      }
    } catch (e) {
      print('❌ Error handling course review notification: $e');
      _showErrorSnackBar('Failed to open course review');
    }
  }

  /// Handle task/reminder notifications
  Future<void> _handleTaskNotification(String notificationId, String? taskId) async {
    try {
      if (taskId == null || taskId.isEmpty) {
        _showErrorSnackBar('No task ID found in notification');
        return;
      }

      print('📱 Navigating to task: $taskId');
      
      // Navigate to task details
      final success = await _navigateToReminderDetails(taskId);
      
      if (success) {
        // Mark notification as read after successful navigation
        await _markNotificationAsRead(notificationId);
      }
    } catch (e) {
      print('❌ Error handling task notification: $e');
      _showErrorSnackBar('Failed to open task details');
    }
  }

  /// Handle feedback notifications
  Future<void> _handleFeedbackNotification(String notificationId, String? navigateValue) async {
    try {
      if (navigateValue == null || navigateValue.isEmpty) {
        _showErrorSnackBar('No navigation path found in notification');
        return;
      }

      print('📱 Handling feedback notification with navigate: $navigateValue');
      
      // Use the path navigation method for feedback notifications
      await _handlePathNavigation(notificationId, navigateValue);
    } catch (e) {
      print('❌ Error handling feedback notification: $e');
      _showErrorSnackBar('Failed to open feedback');
    }
  }

  /// Handle path-based navigation (e.g., /admin/users, /feedback-history)
  Future<void> _handlePathNavigation(String notificationId, String path) async {
    try {
      print('📱 Navigating to path: $path');
      
      // Navigate to the specified path
      Navigator.pushNamed(context, path);
      
      // Mark notification as read after successful navigation
      await _markNotificationAsRead(notificationId);
    } catch (e) {
      print('❌ Error handling path navigation: $e');
      _showErrorSnackBar('Failed to navigate to $path');
    }
  }

  /// Check if a string is a valid UUID
  bool _isValidUuid(String value) {
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    return uuidRegex.hasMatch(value);
  }

  // Very small heuristic to check for UUID-like strings: 36 chars with hyphens
  // Note: kept for backward-compatibility but currently unused by the simplified handler
  // ignore: unused_element
  bool _looksLikeUuid(String s) {
    return RegExp(r'^[0-9a-fA-F-]{36,36}\$').hasMatch(s);
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

      if (success) {
        // Update badge service to reflect the change
        _badgeService.markAsRead(notificationId);
      } else {
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

  /// Navigate to admin users page
  // ignore: unused_element
  Future<bool> _navigateToAdminUsers() async {
    try {
      print('📱 Attempting to navigate to admin users page');

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to admin users page
      final result = await Navigator.pushNamed(context, '/admin/users');

      // Return true if navigation was successful
      return result != null || true;
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      print('❌ Error navigating to admin users: $e');
      _showErrorSnackBar('Failed to open admin users page');
      return false;
    }
  }

  /// Navigate to a specific route
  // ignore: unused_element
  Future<bool> _navigateToRoute(String route) async {
    try {
      print('📱 Attempting to navigate to route: $route');

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to the specified route
      final result = await Navigator.pushNamed(context, route);

      // Return true if navigation was successful
      return result != null || true;
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      print('❌ Error navigating to route $route: $e');
      _showErrorSnackBar('Failed to open page');
      return false;
    }
  }

  /// Navigate to reminder details page
  // ignore: unused_element
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

      // Convert reminderData to Reminder object for navigation
      final reminder = _convertToReminderObject(reminderData);

      // Close loading dialog
      Navigator.pop(context);

      // Navigate to the task detail view screen
      final result = await Navigator.pushNamed(
        context,
        '/task-detail-view',
        arguments: reminder,
      );

      // Return true if navigation was successful (user returned from the screen)
      return result != null || true; // Return true since navigation happened
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

  /// Convert reminder data from Map to Reminder object
  Reminder _convertToReminderObject(Map<String, dynamic> reminderData) {
    return Reminder(
      id: reminderData['id'].toString(),
      title: reminderData['title'] ?? 'Untitled Reminder',
      description: reminderData['description'],
      time: DateTime.parse(reminderData['time']),
      endTime: reminderData['end_time'] != null
          ? DateTime.parse(reminderData['end_time'])
          : null,
      priority: reminderData['priority'] ?? 'Medium',
      courseId: reminderData['course_id'],
      userId: reminderData['user_id'],
      createdBy: reminderData['created_by'],
    );
  } // Mark all notifications as read

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
        
        // Update badge service to reflect all notifications are read
        _badgeService.markAllAsRead();
        
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

  /// Send a REAL device notification
  Future<void> _sendTestNotification() async {
    try {
      _showSuccessSnackBar('Sending device notification...');

      // Ask for permission first
      await LocalNotificationService.initialize();

      // Send REAL device notification
      await LocalNotificationService.showNotification(
        title: 'Knowble Test Notification',
        body:
            'This notification appeared in your device notification tray! Pull down from top to see it. 📱',
        payload: 'test_notification',
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      );

      _showSuccessSnackBar(
        'Device notification sent! Pull down from top to see it 🎉',
      );
    } catch (e) {
      print('Error sending device notification: $e');
      _showErrorSnackBar('Error sending device notification: ${e.toString()}');
    }
  }

  /// Test instant notifications for unread items
  Future<void> _testInstantNotificationsForUnread() async {
    try {
      _showSuccessSnackBar('Testing instant notifications for unread items...');

      await NotificationManager.testInstantNotificationsForUnread();

      _showSuccessSnackBar('✅ Instant notifications test completed!');
    } catch (e) {
      print('Error testing instant notifications: $e');
      _showErrorSnackBar('Failed to test instant notifications: $e');
    }
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
                      // Test notification button
                      GestureDetector(
                        onTap: _sendTestNotification,
                        child: Container(
                          width: 10.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryTeal.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.notification_add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Test instant notifications button
                      GestureDetector(
                        onTap: _testInstantNotificationsForUnread,
                        child: Container(
                          width: 10.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.notifications_active,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
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
