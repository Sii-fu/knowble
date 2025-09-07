import 'package:supabase_flutter/supabase_flutter.dart';
import 'local_notification_service.dart';

/// Service to automatically send device notifications for new unread notifications
class AutoNotificationService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static bool _isListening = false;
  static Set<String> _processedNotificationIds = <String>{};

  /// Initialize automatic notifications for new unread notifications
  static Future<void> initialize() async {
    if (_isListening) return;

    try {
      print('🔔 Setting up automatic device notifications...');

      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ User not authenticated for auto notifications');
        return;
      }

      // Check if notification permissions are granted
      final hasPermissions = await LocalNotificationService.checkPermissions();
      if (!hasPermissions) {
        print('🔔 Requesting notification permissions...');
        final granted = await LocalNotificationService.requestPermissions();
        if (!granted) {
          print('❌ Notification permissions denied by user');
          return;
        }
      }

      // Load existing notification IDs to avoid duplicates
      await _loadExistingNotificationIds();

      // Listen for new notifications in real-time
      _supabase.from('notification').stream(primaryKey: ['id']).listen((data) {
        // Filter for current user's unread notifications
        final userNotifications = data
            .where(
              (notification) =>
                  notification['user_id'] == user.id &&
                  notification['is_read'] == false,
            )
            .toList();

        if (userNotifications.isNotEmpty) {
          _handleNewNotifications(userNotifications);
        }
      });

      _isListening = true;
      print('✅ Auto notification service initialized');
    } catch (e) {
      print('❌ Error initializing auto notification service: $e');
    }
  }

  /// Load existing notification IDs to prevent duplicate notifications
  static Future<void> _loadExistingNotificationIds() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final response = await _supabase
          .from('notification')
          .select('id')
          .eq('user_id', user.id)
          .eq('is_read', false);

      _processedNotificationIds = response
          .map<String>((notification) => notification['id'].toString())
          .toSet();

      print(
        '📝 Loaded ${_processedNotificationIds.length} existing notification IDs',
      );
    } catch (e) {
      print('❌ Error loading existing notification IDs: $e');
    }
  }

  /// Handle new notifications by sending device notifications
  static Future<void> _handleNewNotifications(
    List<Map<String, dynamic>> notifications,
  ) async {
    for (final notification in notifications) {
      final notificationId = notification['id'].toString();

      // Only process notifications that we haven't seen before
      if (!_processedNotificationIds.contains(notificationId)) {
        print('🔔 Processing new notification: $notificationId');
        await _sendDeviceNotificationForData(notification);
        _processedNotificationIds.add(notificationId);
      }
    }
  }

  /// Send device notification for a notification data
  static Future<void> _sendDeviceNotificationForData(
    Map<String, dynamic> notificationData,
  ) async {
    try {
      final title = notificationData['title'] ?? 'New Notification';
      final description =
          notificationData['description'] ?? 'You have a new notification';
      final id = notificationData['id']?.toString() ?? '';
      final createdAt = notificationData['created_at'];

      // Additional check: Only send notifications for recent items (within last 5 minutes)
      // This prevents old notifications from being sent when app restarts
      if (createdAt != null) {
        final notificationTime = DateTime.parse(createdAt);
        final timeDiff = DateTime.now().difference(notificationTime);

        if (timeDiff.inMinutes > 5) {
          print(
            '⏰ Skipping old notification (${timeDiff.inMinutes} minutes old): $title',
          );
          return;
        }
      }

      print('📱 Sending device notification: $title');

      await LocalNotificationService.showNotification(
        title: title,
        body: description,
        payload: 'notification_$id',
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      );

      print('✅ Device notification sent for: $title');
    } catch (e) {
      print('❌ Error sending device notification: $e');
    }
  }

  /// Manually send device notification for new unread notification
  static Future<void> sendDeviceNotificationForNewNotification({
    required String title,
    required String description,
    String? notificationId,
  }) async {
    try {
      print('📱 Sending manual device notification: $title');

      await LocalNotificationService.showNotification(
        title: title,
        body: description,
        payload:
            'notification_${notificationId ?? DateTime.now().millisecondsSinceEpoch}',
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      );

      print('✅ Manual device notification sent: $title');
    } catch (e) {
      print('❌ Error sending manual device notification: $e');
    }
  }

  /// Stop listening for auto notifications
  static void dispose() {
    _isListening = false;
    _processedNotificationIds.clear();
    print('🔔 Auto notification service disposed');
  }

  /// Mark a notification as read/processed to remove it from tracking
  static void markNotificationAsRead(String notificationId) {
    _processedNotificationIds.remove(notificationId);
    print(
      '✅ Notification $notificationId marked as read and removed from tracking',
    );
  }

  /// Clear all processed notification tracking (useful for logout/login)
  static void clearTracking() {
    _processedNotificationIds.clear();
    _isListening = false;
    print('🧹 Cleared notification tracking');
  }

  /// Reinitialize the service (useful when app comes back from background)
  static Future<void> reinitialize() async {
    if (!_isListening) {
      clearTracking();
      await initialize();
    }
  }

  /// Check if the service is currently listening
  static bool get isListening => _isListening;
}
