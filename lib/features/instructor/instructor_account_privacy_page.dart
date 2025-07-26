import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class InstructorAccountPrivacyPage extends StatelessWidget {
  const InstructorAccountPrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Account & Privacy'),
          backgroundColor: AppTheme.surfaceWhite,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0.5,
        ),
        backgroundColor: AppTheme.backgroundLight,
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ListTile(
              leading: const Icon(Icons.lock_outline, color: AppTheme.primaryTeal),
              title: const Text('Change Password'),
              subtitle: const Text('Update your account password'),
              onTap: () {},
            ),
            const Divider(),
            SwitchListTile(
              value: true,
              onChanged: (val) {},
              title: const Text('Two-Factor Authentication'),
              subtitle: const Text('Add extra security to your account'),
              activeColor: AppTheme.primaryTeal,
            ),
            const Divider(),
            SwitchListTile(
              value: false,
              onChanged: (val) {},
              title: const Text('Show Profile Publicly'),
              subtitle: const Text('Allow others to view your profile'),
              activeColor: AppTheme.primaryTeal,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Account'),
              subtitle: const Text('Permanently remove your account'),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
