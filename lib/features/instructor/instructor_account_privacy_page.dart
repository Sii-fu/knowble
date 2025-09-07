import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../core/services/Instructor/account_privacy_service.dart';

class InstructorAccountPrivacyPage extends StatefulWidget {
  const InstructorAccountPrivacyPage({super.key});

  @override
  State<InstructorAccountPrivacyPage> createState() => _InstructorAccountPrivacyPageState();
}

class _InstructorAccountPrivacyPageState extends State<InstructorAccountPrivacyPage> {
  final AccountPrivacyService _service = AccountPrivacyService();

  Future<void> _showChangePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    // Use a stateful builder inside the dialog to show loading state and inline validation
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool isLoading = false;
        String? errorText;
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            backgroundColor: AppTheme.surfaceWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Change Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: AppTheme.textSecondary),
                          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Choose a strong password. Your new password must be at least 8 characters.', style: TextStyle(color: AppTheme.textSecondary)),
                    const SizedBox(height: 16),
                    // Current
                    TextField(
                      controller: currentController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Current password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // New
                    TextField(
                      controller: newController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'New password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Confirm
                    TextField(
                      controller: confirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Confirm new password',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        isDense: true,
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(errorText!, style: TextStyle(color: Colors.red.shade400)),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final current = currentController.text.trim();
                                    final n = newController.text.trim();
                                    final c = confirmController.text.trim();
                                    if (current.isEmpty || n.isEmpty) {
                                      setState(() => errorText = 'Please fill all fields.');
                                      return;
                                    }
                                    if (n.length < 8) {
                                      setState(() => errorText = 'Password must be at least 8 characters.');
                                      return;
                                    }
                                    if (n != c) {
                                      setState(() => errorText = 'Passwords do not match.');
                                      return;
                                    }
                                    setState(() {
                                      isLoading = true;
                                      errorText = null;
                                    });
                                    final res = await _service.changePassword(currentPassword: current, newPassword: n);
                                    setState(() => isLoading = false);
                                    if (res['success'] == true) {
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Password updated')));
                                    } else {
                                      setState(() => errorText = res['message']?.toString() ?? 'Failed to change password');
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: isLoading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Change Password'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    // Dispose controllers
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
  }

  Future<void> _confirmAndDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text('This will delete your account data. This action is irreversible. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirmed != true) return;

    final res = await _service.deleteAccount();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'] ?? '')));
    if (res['success'] == true) {
      // Navigate to initial route or pop until login
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

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
              onTap: _showChangePasswordDialog,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete Account'),
              subtitle: const Text('Permanently remove your account'),
              onTap: _confirmAndDeleteAccount,
            ),
          ],
        ),
      ),
    );
  }
}
