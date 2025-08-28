# Firebase Cloud Messaging (FCM) Setup Guide

## Overview
This guide explains how to use the FCM push notification system in your Knowble app. The system consists of two main components:

1. **Server-side FCM Service** (`fcm_service.dart`) - For sending notifications
2. **Client-side FCM Service** (`fcm_client_service.dart`) - For receiving notifications

## Prerequisites

### 1. Firebase Project Setup
- Firebase project should be set up with your app
- `google-services.json` should be in `android/app/` directory
- Google Services Gradle plugin should be configured (already done)

### 2. Service Account Key
You need to paste your Firebase service account JSON into `fcm_service.dart`:

```dart
static const Map<String, dynamic> serviceAccountJson = {
  // Paste your service account JSON content here
  "type": "service_account",
  "project_id": "knowble-ba6e5",
  "private_key_id": "...",
  "private_key": "...",
  "client_email": "...",
  "client_id": "...",
  "auth_uri": "...",
  "token_uri": "...",
  // ... rest of your JSON
};
```

### 3. Database Setup
Run the SQL script in `fcm_tokens_table.sql` in your Supabase database to create the required table.

## How It Works

### Client-Side (Receiving Notifications)
1. **Initialization**: FCM client service initializes when app starts
2. **Token Generation**: Gets FCM token for the device
3. **Token Storage**: Saves token to Supabase database
4. **Message Handling**: Handles incoming notifications in different app states

### Server-Side (Sending Notifications)
1. **Authentication**: Creates JWT token using service account
2. **Access Token**: Exchanges JWT for OAuth2 access token
3. **Send Notification**: Uses FCM v1 API to send notifications

## Usage Examples

### Sending a Simple Notification
```dart
import 'package:your_app/core/services/fcm_service.dart';

// Send to specific device
final success = await FCMService.sendPushNotification(
  fcmToken: 'target_device_fcm_token',
  title: 'Hello!',
  body: 'This is a test notification',
  data: {'key': 'value'}, // Optional data
);
```

### Sending to Multiple Devices
```dart
final tokens = ['token1', 'token2', 'token3'];
final results = await FCMService.sendBatchPushNotifications(
  fcmTokens: tokens,
  title: 'Broadcast Message',
  body: 'Message for all devices',
);
```

### Sending to Topic
```dart
final success = await FCMService.sendTopicNotification(
  topic: 'all_users',
  title: 'Important Announcement',
  body: 'This message goes to all subscribed users',
);
```

### Getting User's FCM Tokens
```dart
import 'package:your_app/core/services/fcm_client_service.dart';

// Get current device token
final token = FCMClientService.getCurrentToken();

// Get all tokens for a user from database
final userTokens = await FCMClientService.getUserFCMTokens(userId);
```

## Testing

### 1. Use the Test Page
Navigate to the notification test page in your app:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const NotificationTestPage(),
  ),
);
```

### 2. Manual Testing Steps
1. **Setup**: Make sure service account JSON is added to `fcm_service.dart`
2. **Get Token**: Open test page and copy the FCM token
3. **Send Notification**: Fill in title, body, and token, then tap "Send Test Notification"
4. **Verify**: Check if notification appears on the device

### 3. Testing Different App States
- **Foreground**: App is open and active
- **Background**: App is minimized but running
- **Terminated**: App is completely closed

## Integration in Your App

### 1. Add to App Routes
Add the test page to your app's routing system:

```dart
// In your app.dart or routing configuration
'/notification-test': (context) => const NotificationTestPage(),
```

### 2. Send Notifications from Your Backend
If you have a backend service, you can use the same JWT approach:

```dart
// Example: Send notification when new course is added
await FCMService.sendPushNotification(
  fcmToken: studentFCMToken,
  title: 'New Course Available!',
  body: 'Check out the new "${courseName}" course',
  data: {
    'type': 'new_course',
    'course_id': courseId,
    'screen': '/course-detail',
  },
);
```

### 3. Handle Notification Taps
In `fcm_client_service.dart`, update the `_handleNotificationTap` method:

```dart
static void _handleNotificationTap(RemoteMessage message) {
  final data = message.data;
  
  if (data['type'] == 'new_course') {
    // Navigate to course detail page
    // NavigationService.navigateTo('/course-detail', arguments: data['course_id']);
  } else if (data['type'] == 'chat_message') {
    // Navigate to chat page
    // NavigationService.navigateTo('/chat', arguments: data['chat_id']);
  }
}
```

## Common Use Cases

### 1. Course Notifications
- New course published
- Assignment due reminders
- Live session starting

### 2. Chat Notifications
- New message received
- Instructor response

### 3. System Notifications
- App updates
- Maintenance announcements
- Feature releases

## Troubleshooting

### Common Issues
1. **No FCM Token**: Check if permissions are granted
2. **Notifications Not Received**: Verify token is valid and not expired
3. **Server Error**: Check service account JSON is correct
4. **Database Error**: Ensure FCM tokens table exists

### Debug Tips
- Check console logs for FCM-related messages
- Verify Firebase project configuration
- Test with Firebase Console first
- Use the test page to isolate issues

## Security Notes
- Keep service account JSON secure
- Don't commit service account to version control
- Use environment variables in production
- Implement proper user authentication before sending notifications

## Next Steps
1. Add your service account JSON to `fcm_service.dart`
2. Run the SQL script to create the database table
3. Test using the notification test page
4. Integrate notifications into your app features
