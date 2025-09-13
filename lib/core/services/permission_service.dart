import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Service to handle app permissions, especially notification permissions
class PermissionService {
  static bool _hasNotificationPermission = false;
  static bool _permissionRequested = false;

  /// Check if notification permission is granted
  static bool get hasNotificationPermission => _hasNotificationPermission;

  /// Check if permission has been requested in this session
  static bool get permissionRequested => _permissionRequested;

  /// Request notification permission with proper UI context
  /// Always shows dialog to allow users to change their mind
  static Future<bool> requestNotificationPermission(BuildContext context) async {
    if (_permissionRequested) {
      return _hasNotificationPermission;
    }

    // Skip permission requests on web platform
    if (kIsWeb) {
      print('🌐 Running on web - skipping native permission requests');
      _hasNotificationPermission = true;
      _permissionRequested = true;
      return true;
    }

    try {
      print('🔔 Requesting notification permission...');
      
      // Check current status first
      final currentStatus = await Permission.notification.status;
      print('📱 Current notification permission status: $currentStatus');

      // Always show dialog regardless of current permission status
      final userChoice = await _showPermissionDialog(context, currentStatus.isGranted);
      
      if (userChoice == null) {
        // User cancelled the dialog
        _permissionRequested = true;
        return currentStatus.isGranted; // Keep current status
      } else if (userChoice == true) {
        // User wants to allow/keep permission
        if (currentStatus.isGranted) {
          // Permission already granted, just confirm
          _hasNotificationPermission = true;
          _permissionRequested = true;
          print('✅ Notification permission confirmed (already granted)');
          return true;
        } else {
          // Request the permission
          final status = await Permission.notification.request();
          print('📱 Permission request result: $status');

          _hasNotificationPermission = status.isGranted;
          _permissionRequested = true;

          if (status.isGranted) {
            print('✅ Notification permission granted');
            
            // For Android 13+, request additional permission
            try {
              if (await Permission.scheduleExactAlarm.isDenied) {
                await Permission.scheduleExactAlarm.request();
              }
            } catch (e) {
              print('⚠️ Could not request scheduleExactAlarm permission: $e');
              // Continue anyway as this permission is not critical
            }
            
            return true;
          } else if (status.isPermanentlyDenied) {
            print('❌ Notification permission permanently denied');
            await _showSettingsDialog(context);
            return false;
          } else {
            print('❌ Notification permission denied');
            return false;
          }
        }
      } else {
        // User wants to deny/revoke permission
        if (currentStatus.isGranted) {
          // Permission is currently granted but user wants to deny it
          print('🔄 User wants to revoke notification permission');
          await _revokeNotificationPermission();
        }
        
        _hasNotificationPermission = false;
        _permissionRequested = true;
        print('❌ Notification permission denied/revoked by user');
        return false;
      }
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
      _permissionRequested = true;
      return false;
    }
  }

  /// Show dialog explaining why notification permission is needed
  /// Always shows dialog to allow users to change their mind
  static Future<bool?> _showPermissionDialog(BuildContext context, bool currentlyGranted) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(currentlyGranted ? 'Notification Settings' : 'Notification Permission'),
          content: Text(
            currentlyGranted 
                ? 'You currently have notification permission enabled. Knowble can send you:\n\n'
                  '• Reminders for your tasks and assignments\n'
                  '• Important updates from your courses\n'
                  '• Learning progress notifications\n\n'
                  'Would you like to keep notifications enabled or disable them?'
                : 'Knowble would like to send you notifications for:\n\n'
                  '• Reminders for your tasks and assignments\n'
                  '• Important updates from your courses\n'
                  '• Learning progress notifications\n\n'
                  'This helps you stay on track with your studies. You can change this later in settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(currentlyGranted ? 'Disable' : 'Not Now'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(currentlyGranted ? 'Keep Enabled' : 'Allow'),
            ),
          ],
        );
      },
    );
  }

  /// Show dialog to open app settings when permission is permanently denied
  static Future<void> _showSettingsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: const Text(
            'Notification permission is required for the best experience. '
            'Please enable notifications in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Check notification permission status without requesting
  static Future<bool> checkNotificationPermission() async {
    if (kIsWeb) {
      return true;
    }

    try {
      final status = await Permission.notification.status;
      _hasNotificationPermission = status.isGranted;
      return status.isGranted;
    } catch (e) {
      print('❌ Error checking notification permission: $e');
      return false;
    }
  }

  /// Revoke notification permission by opening app settings
  static Future<void> _revokeNotificationPermission() async {
    try {
      print('🔄 Opening app settings to revoke notification permission...');
      await openAppSettings();
    } catch (e) {
      print('❌ Error opening app settings: $e');
    }
  }

  /// Reset permission state (useful for testing)
  static void resetPermissionState() {
    _hasNotificationPermission = false;
    _permissionRequested = false;
  }
}
