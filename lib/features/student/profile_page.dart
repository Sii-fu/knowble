import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/theme.dart';

class StudentProfilePage extends StatelessWidget {
  const StudentProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'My Account',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          backgroundColor: AppTheme.surfaceWhite,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0.5,
          shadowColor: AppTheme.shadowLight,
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: AppTheme.errorRed),
              onPressed: () => _logout(context),
              tooltip: 'Log Out',
            ),
          ],
        ),
        backgroundColor: AppTheme.backgroundLight,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppTheme.accentLight,
                backgroundImage: const NetworkImage('https://i.pravatar.cc/300'),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryTeal,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Liam Smith',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'liam@example.com',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              _buildInfoCard("Personal Details", {
                "Full name": "Liam Smith",
                "Date of Birth": "January 1, 1987",
                "Gender": "Male",
                "Nationality": "American",
                "Address": "🇺🇸 California, United States",
                "Phone Number": "(213) 555-1234",
                "Email": "liam@example.com",
              }),

              const SizedBox(height: 16),

              _buildInfoCard("Account Details", {
                "Display Name": "s_liam_168920",
                "Account Created": "March 20, 2020",
                "Last Login": "August 22, 2024",
                "Membership Status": "Premium Member",
                "Account Verification": "✅ Verified",
                "Language Preference": "English",
              }),

              const SizedBox(height: 24),

              // Log out button at the bottom
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _logout(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorRed,
                    foregroundColor: AppTheme.surfaceWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Log Out',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.surfaceWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, Map<String, String> infoMap) {
    final theme = AppTheme.lightTheme;
    return Card(
      color: AppTheme.surfaceWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.borderSubtle,
          width: 1,
        ),
      ),
      elevation: 2,
      shadowColor: AppTheme.shadowLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryTeal,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...infoMap.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.key,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Text(
                        entry.value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
