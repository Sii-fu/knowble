import 'package:flutter/material.dart';
import 'package:Knowble/core/services/reminder_notification_sync_service.dart';

/// Example page showing how to sync existing reminders to notifications
/// This is useful for migrating existing data
class ReminderSyncUtilityPage extends StatefulWidget {
  const ReminderSyncUtilityPage({super.key});

  @override
  State<ReminderSyncUtilityPage> createState() =>
      _ReminderSyncUtilityPageState();
}

class _ReminderSyncUtilityPageState extends State<ReminderSyncUtilityPage> {
  bool _isLoading = false;
  String _statusMessage = '';

  /// Sync all existing reminders to create notification entries
  Future<void> _syncReminders() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Starting sync...';
    });

    try {
      await ReminderNotificationSyncService.syncAllRemindersToNotifications();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage =
              'Sync completed successfully! All reminders now have notification entries.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sync completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = 'Sync failed: $e';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder Sync Utility'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reminder-Notification Sync',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'This utility will sync all your existing reminders to create corresponding notification entries. This ensures that all reminders appear in your notifications page.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What this does:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Scans all your existing reminders'),
                    Text('• Creates notification entries for each reminder'),
                    Text('• Links notifications to reminder details'),
                    Text('• Allows navigation from notifications to reminders'),
                    Text('• Skips reminders that already have notifications'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _syncReminders,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.sync),
                label: Text(_isLoading ? 'Syncing...' : 'Sync Reminders'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (_statusMessage.isNotEmpty) ...[
              const Text(
                'Status:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  _statusMessage,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],

            const SizedBox(height: 20),

            const Card(
              color: Colors.amber,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Note:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text('• This is a one-time setup utility'),
                    Text(
                      '• Future reminders will automatically create notifications',
                    ),
                    Text(
                      '• Safe to run multiple times (won\'t create duplicates)',
                    ),
                    Text('• Only syncs reminders you own'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/*
USAGE:
======

To use this utility page in your app:

1. Add it to your navigation routes:
```dart
// In your app's routes
'/reminder-sync': (context) => const ReminderSyncUtilityPage(),
```

2. Or navigate to it directly:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ReminderSyncUtilityPage(),
  ),
);
```

3. Or add it as a debug/admin option in your settings:
```dart
// In your settings or debug menu
ListTile(
  title: const Text('Sync Reminders'),
  subtitle: const Text('Sync existing reminders to notifications'),
  leading: const Icon(Icons.sync),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReminderSyncUtilityPage(),
      ),
    );
  },
),
```
*/
