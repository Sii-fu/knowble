import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'reminder_service.dart';

/// NotificationService handles local device notifications and Supabase notifications table
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final SupabaseClient _supabase = Supabase.instance.client;
  static bool _isInitialized = false;

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone database
      tz.initializeTimeZones();

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestSoundPermission: true,
            requestBadgePermission: true,
            requestAlertPermission: true,
          );

      // Combined initialization settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      // Initialize the plugin
      await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channels for Android
      await _createNotificationChannels();

      // Request permissions
      await _requestPermissions();

      _isInitialized = true;
      print(' NotificationService initialized successfully');
    } catch (e) {
      print(' Error initializing NotificationService: $e');
    }
  }

  /// Create notification channels for Android
  static Future<void> _createNotificationChannels() async {
    // High priority channel for urgent reminders
    const AndroidNotificationChannel highPriorityChannel =
        AndroidNotificationChannel(
          'high_priority_reminders',
          'High Priority Reminders',
          description: 'Notifications for high priority tasks and reminders',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        );

    // Medium priority channel for regular reminders
    const AndroidNotificationChannel mediumPriorityChannel =
        AndroidNotificationChannel(
          'medium_priority_reminders',
          'Medium Priority Reminders',
          description: 'Notifications for medium priority tasks and reminders',
          importance: Importance.defaultImportance,
          playSound: true,
          enableVibration: true,
        );

    // Low priority channel for low priority reminders
    const AndroidNotificationChannel lowPriorityChannel =
        AndroidNotificationChannel(
          'low_priority_reminders',
          'Low Priority Reminders',
          description: 'Notifications for low priority tasks and reminders',
          importance: Importance.low,
          playSound: false,
          enableVibration: false,
        );

    // Create the channels
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(highPriorityChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(mediumPriorityChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(lowPriorityChannel);
  }

  /// Request notification permissions
  static Future<bool> _requestPermissions() async {
    // Skip permission requests on web platform
    if (kIsWeb) {
      print('🌐 Running on web - skipping native permission requests');
      return true;
    }

    // Request notification permission
    final notificationStatus = await Permission.notification.request();

    // For Android 13+, request additional permission
    try {
      if (await Permission.scheduleExactAlarm.isDenied) {
        await Permission.scheduleExactAlarm.request();
      }
    } catch (e) {
      print(' Could not request scheduleExactAlarm permission: $e');
      // Continue anyway as this permission is not critical
    }

    return notificationStatus.isGranted;
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    print(' Notification tapped with payload: $payload');

    // TODO: Navigate to specific reminder/task based on payload
    // You can parse the payload to get reminder ID and navigate accordingly
  }

  /// Get notification channel based on priority
  static String _getChannelId(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'high_priority_reminders';
      case 'medium':
        return 'medium_priority_reminders';
      case 'low':
        return 'low_priority_reminders';
      default:
        return 'medium_priority_reminders';
    }
  }

  /// Get notification importance based on priority
  static Importance _getImportance(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Importance.high;
      case 'medium':
        return Importance.defaultImportance;
      case 'low':
        return Importance.low;
      default:
        return Importance.defaultImportance;
    }
  }

  /// Schedule a notification for a reminder
  static Future<int?> scheduleReminderNotification({
    required String reminderId,
    required String title,
    required String description,
    required DateTime scheduledTime,
    required String priority,
  }) async {
    try {
      print('🚀 scheduleReminderNotification called');
      print('    Title: $title');
      print('   ⏰ Scheduled time: ${scheduledTime.toString()}');

      if (!_isInitialized) {
        print('🔧 Initializing notification service...');
        await initialize();
      }

      // Check permissions first
      final hasPermission = await areNotificationsEnabled();
      print(' Notification permission granted: $hasPermission');

      if (!hasPermission) {
        print(' No notification permission! Requesting...');
        await _requestPermissions();
      }

      // Generate unique notification ID
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Get channel ID based on priority
      final channelId = _getChannelId(priority);

      // Create notification details
      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(priority),
        channelDescription: _getChannelDescription(priority),
        importance: _getImportance(priority),
        priority: _getAndroidPriority(priority),
        showWhen: true,
        when: scheduledTime.millisecondsSinceEpoch,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Convert scheduled time to timezone-aware DateTime
      // Add debugging to understand timezone issues
      print(' Original scheduledTime: ${scheduledTime.toString()}');
      print(' Is UTC: ${scheduledTime.isUtc}');
      print(' Current local time: ${DateTime.now().toString()}');
      print(' Current UTC time: ${DateTime.now().toUtc().toString()}');

      // If the scheduledTime is UTC, convert it to local time first
      DateTime localScheduledTime = scheduledTime.isUtc
          ? scheduledTime.toLocal()
          : scheduledTime;

      print(' Converted to local: ${localScheduledTime.toString()}');

      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
        localScheduledTime,
        tz.local,
      );

      print(' TZ DateTime: ${tzScheduledTime.toString()}');
      print(
        ' Current TZ DateTime: ${tz.TZDateTime.now(tz.local).toString()}',
      );

      // Only schedule if the time is in the future
      if (tzScheduledTime.isAfter(tz.TZDateTime.now(tz.local))) {
        // Schedule the notification
        await _notifications.zonedSchedule(
          notificationId,
          title,
          description.isNotEmpty ? description : 'Reminder for your task',
          tzScheduledTime,
          platformDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: reminderId, // Pass reminder ID for navigation
        );

        // Store notification in Supabase notifications table
        await _storeNotificationInDatabase(
          notificationId: notificationId,
          reminderId: reminderId,
          title: title,
          description: description,
          alertTime: localScheduledTime, // Use local time for storage
          priority: priority,
        );

        print(' Notification scheduled for: ${localScheduledTime.toString()}');
        print('    Notification ID: $notificationId');
        print('    Title: $title');
        print('    Priority: $priority');

        return notificationId;
      } else {
        print(
          ' Cannot schedule notification for past time: ${localScheduledTime.toString()}',
        );
        return null;
      }
    } catch (e) {
      print(' Error scheduling notification: $e');
      return null;
    }
  }

  /// Store notification details in Supabase notifications table
  static Future<void> _storeNotificationInDatabase({
    required int notificationId,
    required String reminderId,
    required String title,
    required String description,
    required DateTime alertTime,
    required String priority,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print(' User not authenticated, cannot store notification');
        return;
      }

      // Convert alert time to Bangladesh Standard Time for database storage
      final bstAlertTime = ReminderService.convertToBangladeshTime(alertTime);

      final notificationData = {
        'user_id': user.id,
        'title': title,
        'description': description.isNotEmpty
            ? description
            : 'Reminder for your task',
        'priority': priority,
        'alert_time': bstAlertTime
            .toIso8601String(), // Store in Bangladesh time
        'navigate': reminderId, // Reminder ID for navigation to task details
        'created_at': DateTime.now()
            .toUtc()
            .toIso8601String(), // Current UTC time
      };

      print(' Attempting to insert notification data: $notificationData');

      final response = await _supabase
          .from('notification')
          .insert(notificationData)
          .select();

      print(' Notification stored in database successfully');
      print(' Inserted notification: $response');
    } catch (e) {
      print(' Error storing notification in database: $e');
    }
  }

  /// Cancel a scheduled notification
  static Future<void> cancelNotification(int notificationId) async {
    try {
      await _notifications.cancel(notificationId);

      // Remove from database (optional, you might want to keep for history)
      // await _supabase.from('notifications').delete().eq('id', notificationId);

      print(' Notification cancelled: $notificationId');
    } catch (e) {
      print(' Error cancelling notification: $e');
    }
  }

  /// Cancel all notifications for a user
  static Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      print(' All notifications cancelled');
    } catch (e) {
      print(' Error cancelling all notifications: $e');
    }
  }

  /// Helper methods for channel configuration
  static String _getChannelName(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'High Priority Reminders';
      case 'medium':
        return 'Medium Priority Reminders';
      case 'low':
        return 'Low Priority Reminders';
      default:
        return 'Medium Priority Reminders';
    }
  }

  static String _getChannelDescription(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'Notifications for high priority tasks and reminders';
      case 'medium':
        return 'Notifications for medium priority tasks and reminders';
      case 'low':
        return 'Notifications for low priority tasks and reminders';
      default:
        return 'Notifications for medium priority tasks and reminders';
    }
  }

  static Priority _getAndroidPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Priority.high;
      case 'medium':
        return Priority.defaultPriority;
      case 'low':
        return Priority.low;
      default:
        return Priority.defaultPriority;
    }
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    // Always return true for web platform
    if (kIsWeb) {
      return true;
    }

    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      print(' Could not check notification permission: $e');
      return true; // Assume enabled to avoid blocking functionality
    }
  }

  /// Show immediate notification (for testing)
  static Future<void> showImmediateNotification({
    required String title,
    required String description,
    String priority = 'medium',
  }) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final channelId = _getChannelId(priority);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(priority),
        channelDescription: _getChannelDescription(priority),
        importance: _getImportance(priority),
        priority: _getAndroidPriority(priority),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(
        notificationId,
        title,
        description,
        platformDetails,
      );

      print(' Immediate notification shown: $title');
    } catch (e) {
      print(' Error showing immediate notification: $e');
    }
  }

  /// Test notification scheduling (for development)
  static Future<void> testNotification() async {
    final testTime = DateTime.now().add(const Duration(seconds: 10));

    await scheduleReminderNotification(
      reminderId: 'test-reminder-id',
      title: 'Test Reminder',
      description:
          'This is a test notification scheduled for 10 seconds from now',
      scheduledTime: testTime,
      priority: 'high',
    );

    print(' Test notification scheduled for: ${testTime.toString()}');
  }

  /// Test database insertion directly
  static Future<void> testDatabaseInsertion() async {
    try {
      print(' Testing direct database insertion...');

      await _storeNotificationInDatabase(
        notificationId: 999999,
        reminderId: 'test-reminder-123',
        title: 'Database Test',
        description: 'Testing direct database insertion',
        alertTime: DateTime.now().add(const Duration(minutes: 5)),
        priority: 'medium',
      );

      print(' Direct database test completed');
    } catch (e) {
      print(' Direct database test failed: $e');
    }
  }
}
