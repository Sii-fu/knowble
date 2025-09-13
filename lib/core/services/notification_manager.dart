import 'package:supabase_flutter/supabase_flutter.dart';
import 'notification_service.dart';
import 'local_notification_service.dart';
import 'auto_notification_service.dart';
import 'background_notification_service.dart';
import 'notification_badge_service.dart';

/// Central manager for all notification services
/// Coordinates between different notification systems
class NotificationManager {
  static bool _isInitialized = false;

  /// Initialize all notification services
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🚀 Initializing Notification Manager...');

      // Initialize core notification service
      await NotificationService.initialize();

      // Initialize local notification service
      await LocalNotificationService.initialize();

      // Initialize auto notification service for real-time notifications
      await AutoNotificationService.initialize();

      // Initialize background notification service for app-closed scenarios
      await BackgroundNotificationService.initialize();

      // Initialize notification badge service
      await NotificationBadgeService().initialize();

      _isInitialized = true;
      print('✅ Notification Manager initialized successfully');
    } catch (e) {
      print('❌ Error initializing Notification Manager: $e');
    }
  }

  /// Schedule a reminder notification
  static Future<int?> scheduleReminderNotification({
    required String reminderId,
    required String title,
    required String description,
    required DateTime scheduledTime,
    required String priority,
  }) async {
    try {
      print('📅 Scheduling reminder notification: $title');
      
      // Use the main notification service to schedule
      final notificationId = await NotificationService.scheduleReminderNotification(
        reminderId: reminderId,
        title: title,
        description: description,
        scheduledTime: scheduledTime,
        priority: priority,
      );

      if (notificationId != null) {
        print('✅ Reminder notification scheduled successfully: $notificationId');
      } else {
        print('❌ Failed to schedule reminder notification');
      }

      return notificationId;
    } catch (e) {
      print('❌ Error scheduling reminder notification: $e');
      return null;
    }
  }

  /// Show immediate notification (for testing or urgent alerts)
  static Future<void> showImmediateNotification({
    required String title,
    required String description,
    String priority = 'medium',
  }) async {
    try {
      print('🔔 Showing immediate notification: $title');
      
      await NotificationService.showImmediateNotification(
        title: title,
        description: description,
        priority: priority,
      );

      print('✅ Immediate notification shown successfully');
    } catch (e) {
      print('❌ Error showing immediate notification: $e');
    }
  }

  /// Cancel a specific notification
  static Future<void> cancelNotification(int notificationId) async {
    try {
      await NotificationService.cancelNotification(notificationId);
      print('✅ Notification cancelled: $notificationId');
    } catch (e) {
      print('❌ Error cancelling notification: $notificationId: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    try {
      await NotificationService.cancelAllNotifications();
      print('✅ All notifications cancelled');
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }

  /// Reinitialize services (useful when app comes back from background)
  static Future<void> reinitialize() async {
    try {
      print('🔄 Reinitializing notification services...');
      
      // Reinitialize auto notification service to check for missed notifications
      await AutoNotificationService.reinitialize();
      
      print('✅ Notification services reinitialized');
    } catch (e) {
      print('❌ Error reinitializing notification services: $e');
    }
  }

  /// Clean up all notification services (useful for logout)
  static Future<void> cleanup() async {
    try {
      print('🧹 Cleaning up notification services...');
      
      // Clear auto notification tracking
      AutoNotificationService.clearTracking();
      
      // Cancel background tasks
      await BackgroundNotificationService.cancelAllTasks();
      
      // Clean up badge service
      NotificationBadgeService().cleanup();
      
      print('✅ Notification services cleaned up');
    } catch (e) {
      print('❌ Error cleaning up notification services: $e');
    }
  }

  /// Push instant notifications for all unread notifications (useful on login)
  static Future<void> pushInstantNotificationsForUnread() async {
    try {
      print('🔔 [LOGIN] Pushing instant notifications for unread notifications...');
      
      // Get all unread notifications from database
      final unreadNotifications = await _getAllUnreadNotifications();
      
      if (unreadNotifications.isNotEmpty) {
        print('📱 Found ${unreadNotifications.length} unread notifications, pushing to device...');
        
        // Push each unread notification to device
        for (final notification in unreadNotifications) {
          await _pushNotificationToDevice(notification);
        }
        
        print('✅ Instant notifications pushed for ${unreadNotifications.length} unread notifications');
      } else {
        print('✅ No unread notifications to push');
      }
    } catch (e) {
      print('❌ Error pushing instant notifications for unread: $e');
    }
  }

  /// Get all unread notifications for current user
  static Future<List<Map<String, dynamic>>> _getAllUnreadNotifications() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) {
        print('❌ No authenticated user');
        return [];
      }

      final response = await supabase
          .from('notification')
          .select('*')
          .eq('user_id', user.id)
          .eq('is_read', false)
          .order('created_at', ascending: false);

      return response;
    } catch (e) {
      print('❌ Error fetching unread notifications: $e');
      return [];
    }
  }

  /// Push a single notification to device
  static Future<void> _pushNotificationToDevice(Map<String, dynamic> notification) async {
    try {
      final title = notification['title'] ?? 'New Notification';
      final description = notification['description'] ?? 'You have a new notification';
      final id = notification['id']?.toString() ?? '';
      
      print('📱 Pushing notification to device: $title');
      
      await LocalNotificationService.showNotification(
        title: title,
        body: description,
        payload: 'notification_$id',
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      );
      
      print('✅ Notification pushed to device: $title');
    } catch (e) {
      print('❌ Error pushing notification to device: $e');
    }
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    return await NotificationService.areNotificationsEnabled();
  }

  /// Test notification functionality
  static Future<void> testNotification() async {
    try {
      print('🧪 Testing notification functionality...');
      
      await NotificationService.testNotification();
      
      print('✅ Notification test completed');
    } catch (e) {
      print('❌ Error testing notifications: $e');
    }
  }

  /// Test instant notifications for unread items (for debugging)
  static Future<void> testInstantNotificationsForUnread() async {
    try {
      print('🧪 Testing instant notifications for unread items...');
      
      await pushInstantNotificationsForUnread();
      
      print('✅ Instant notifications test completed');
    } catch (e) {
      print('❌ Error testing instant notifications: $e');
    }
  }

  /// Get initialization status
  static bool get isInitialized => _isInitialized;
}
