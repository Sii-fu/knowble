import 'package:flutter/material.dart';
import 'package:Knowble/features/common/screens/notifications/notifications_screen.dart';
import 'package:Knowble/core/services/notification_data_service.dart';

/// Example widget showing how to integrate notifications into your app
class NotificationIntegrationExample extends StatefulWidget {
  const NotificationIntegrationExample({super.key});

  @override
  State<NotificationIntegrationExample> createState() =>
      _NotificationIntegrationExampleState();
}

class _NotificationIntegrationExampleState
    extends State<NotificationIntegrationExample> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  /// Load the count of unread notifications
  Future<void> _loadUnreadCount() async {
    try {
      final count = await NotificationDataService.getUnreadNotificationsCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      print('Error loading unread count: $e');
    }
  }

  /// Navigate to notifications screen
  void _openNotifications() async {
    // Navigate to notifications
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsScreen()),
    );

    // Refresh unread count when returning
    _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
        actions: [
          // Notification icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: _openNotifications,
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Your App Content Here', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openNotifications,
              child: Text('View Notifications ($_unreadCount unread)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createTestNotification,
              child: const Text('Create Test Notification'),
            ),
          ],
        ),
      ),
    );
  }

  /// Create a test notification for demonstration
  Future<void> _createTestNotification() async {
    try {
      // Import the notification service
      // Note: You'll need to import the NotificationService
      // await NotificationService.scheduleReminderNotification(
      //   reminderId: 'test-${DateTime.now().millisecondsSinceEpoch}',
      //   title: 'Test Notification',
      //   description: 'This is a test notification created from the app',
      //   scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
      //   priority: 'medium',
      // );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Test notification scheduled for 5 seconds from now'),
        ),
      );

      // Refresh count after a short delay
      Future.delayed(const Duration(seconds: 6), () {
        _loadUnreadCount();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating test notification: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

/*
INTEGRATION STEPS:
==================

1. Add this to your main navigation or home screen:

```dart
// In your app's main navigation
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      actions: [
        // Add notification button
        NotificationButton(), // Custom widget that uses the integration example above
      ],
    ),
    // ... rest of your app
  );
}
```

2. For drawer integration:

```dart
Drawer(
  child: ListView(
    children: [
      // Other drawer items...
      ListTile(
        leading: Icon(Icons.notifications),
        title: Text('Notifications'),
        trailing: _unreadCount > 0 
          ? Badge(child: Text('$_unreadCount'))
          : null,
        onTap: () {
          Navigator.pop(context); // Close drawer
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            ),
          );
        },
      ),
    ],
  ),
)
```

3. For bottom navigation integration:

```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(
      icon: Stack(
        children: [
          Icon(Icons.notifications),
          if (_unreadCount > 0)
            Positioned(
              right: 0,
              child: Badge(child: Text('$_unreadCount')),
            ),
        ],
      ),
      label: 'Notifications',
    ),
    // Other navigation items...
  ],
  onTap: (index) {
    if (index == notificationTabIndex) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NotificationsScreen(),
        ),
      );
    }
  },
)
```
*/
