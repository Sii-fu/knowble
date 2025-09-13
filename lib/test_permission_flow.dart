import 'package:flutter/material.dart';
import 'package:Knowble/core/services/permission_service.dart';

/// Test widget to verify notification permission flow
/// This can be used for testing the permission request functionality
class TestPermissionFlow extends StatefulWidget {
  const TestPermissionFlow({super.key});

  @override
  State<TestPermissionFlow> createState() => _TestPermissionFlowState();
}

class _TestPermissionFlowState extends State<TestPermissionFlow> {
  String _permissionStatus = 'Unknown';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    final hasPermission = await PermissionService.checkNotificationPermission();
    setState(() {
      _permissionStatus = hasPermission ? 'Granted' : 'Denied';
    });
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final hasPermission = await PermissionService.requestNotificationPermission(context);
      setState(() {
        _permissionStatus = hasPermission ? 'Granted' : 'Denied';
      });
    } catch (e) {
      setState(() {
        _permissionStatus = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Permission Flow'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notification Permission Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: $_permissionStatus',
                      style: TextStyle(
                        fontSize: 16,
                        color: _permissionStatus == 'Granted' 
                            ? Colors.green 
                            : _permissionStatus == 'Denied' 
                                ? Colors.red 
                                : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _requestPermission,
              child: _isLoading 
                  ? const CircularProgressIndicator()
                  : const Text('Request Notification Permission'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _checkPermissionStatus,
              child: const Text('Check Permission Status'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                PermissionService.resetPermissionState();
                _checkPermissionStatus();
              },
              child: const Text('Reset Permission State (for testing)'),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New Behavior:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('• Dialog ALWAYS appears, even if permission is already granted'),
                    Text('• If permission is granted: "Keep Enabled" or "Disable"'),
                    Text('• If permission is denied: "Allow" or "Not Now"'),
                    Text('• Clicking "Disable" opens app settings to revoke permission'),
                    Text('• Clicking "Keep Enabled" does nothing (permission stays)'),
                    Text('• This allows users to change their mind anytime'),
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
