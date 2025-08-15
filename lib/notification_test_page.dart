import 'package:flutter/material.dart';
import 'core/services/notification_service.dart';

/// Quick notification test widget
class NotificationTestPage extends StatelessWidget {
  const NotificationTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Test immediate notification
                await NotificationService.showImmediateNotification(
                  title: 'TEST NOW',
                  description: 'Immediate notification test',
                  priority: 'high',
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Immediate notification sent!')),
                );
              },
              child: const Text('🚨 Test Immediate Notification'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                // Test 30 second delayed notification
                final scheduledTime = DateTime.now().add(
                  const Duration(seconds: 30),
                );

                await NotificationService.scheduleReminderNotification(
                  reminderId: 'test-id-123',
                  title: 'TEST 30 SEC',
                  description: 'This should appear in 30 seconds',
                  scheduledTime: scheduledTime,
                  priority: 'high',
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Notification scheduled for ${scheduledTime.toString()}',
                    ),
                  ),
                );
              },
              child: const Text('⏰ Test 30-Second Delayed'),
            ),
          ],
        ),
      ),
    );
  }
}
