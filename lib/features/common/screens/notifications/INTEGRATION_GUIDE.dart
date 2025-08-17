// NOTIFICATION SYSTEM INTEGRATION GUIDE
// =====================================
//
// This document explains how the notification system has been integrated
// and how to use it in your Flutter app.

/*
OVERVIEW:
---------
The notification system consists of:

1. NotificationService (existing) - Handles local notifications and Supabase integration
2. NotificationDataService (new) - Fetches and manages notification data from database
3. NotificationsScreen (updated) - Dynamic UI that displays user notifications

FEATURES:
---------
✅ Fetch user-specific notifications from Supabase
✅ Real-time notification status updates (read/unread)
✅ Group notifications by date (Today, Yesterday, specific dates)
✅ Mark individual notifications as read
✅ Mark all notifications as read
✅ Delete all notifications
✅ Pull-to-refresh functionality
✅ Loading states and error handling
✅ Empty state when no notifications

DATABASE STRUCTURE:
-------------------
The 'notification' table should have these columns:
- id (uuid, primary key)
- user_id (uuid, foreign key to auth.users)
- title (text)
- description (text)
- priority (text: 'high', 'medium', 'low')
- alert_time (timestamp)
- navigate (text, optional - for navigation purposes)
- created_at (timestamp)
- is_read (boolean, default false)

USAGE:
------
1. Import the NotificationsScreen in your app:
   ```dart
   import 'package:Knowble/features/common/screens/notifications/notifications_screen.dart';
   ```

2. Navigate to the notifications screen:
   ```dart
   Navigator.push(
     context,
     MaterialPageRoute(
       builder: (context) => const NotificationsScreen(),
     ),
   );
   ```

3. The screen will automatically:
   - Fetch notifications for the logged-in user
   - Display them grouped by date
   - Handle read/unread states
   - Allow user interactions

TESTING:
--------
To test the notification system:

1. Make sure you have notifications in your Supabase 'notification' table
2. Ensure the user is properly authenticated
3. Navigate to the NotificationsScreen
4. Test the following actions:
   - Pull to refresh
   - Tap on notifications to mark as read
   - Use "Read all" button
   - Use "Clear all" button

CREATING TEST NOTIFICATIONS:
----------------------------
You can create test notifications using the NotificationService:

```dart
// Schedule a test notification
await NotificationService.scheduleReminderNotification(
  reminderId: 'test-reminder-123',
  title: 'Test Notification',
  description: 'This is a test notification',
  scheduledTime: DateTime.now().add(Duration(minutes: 1)),
  priority: 'high',
);
```

Or insert directly into the database:
```sql
INSERT INTO notification (user_id, title, description, priority, alert_time, created_at)
VALUES (
  'user-uuid-here',
  'Welcome to Knowble!',
  'Start your learning journey today',
  'medium',
  NOW(),
  NOW()
);
```

TROUBLESHOOTING:
---------------
If notifications don't appear:
1. Check if user is authenticated (Supabase.instance.client.auth.currentUser)
2. Verify database connection
3. Check console for error messages
4. Ensure the 'notification' table exists and has correct structure
5. Verify user has notifications in the database

CUSTOMIZATION:
--------------
You can customize:
- Notification icons based on priority/type
- Colors for different notification types
- Date formatting
- Error messages
- Loading indicators

The NotificationDataService provides all the backend functionality,
while the NotificationsScreen handles the UI presentation.
*/
