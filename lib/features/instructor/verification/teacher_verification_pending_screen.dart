import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/theme.dart';
import './widgets/contact_support_widget.dart';
import './widgets/document_status_widget.dart';
import './widgets/review_process_widget.dart';
import './widgets/verification_status_widget.dart';

class TeacherVerificationPendingScreen extends StatefulWidget {
  const TeacherVerificationPendingScreen({super.key});

  @override
  State<TeacherVerificationPendingScreen> createState() =>
      _TeacherVerificationPendingScreenState();
}

class _TeacherVerificationPendingScreenState
    extends State<TeacherVerificationPendingScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _refreshController;
  bool _notificationsEnabled = true;
  bool _isRefreshing = false;

  // Mock data for verification status
  final Map<String, dynamic> verificationData = {
    "status": "under_review",
    "submissionDate": "2025-07-11 14:30:00",
    "estimatedCompletion": "2025-07-15 17:00:00",
    "documentsSubmitted": [
      {
        "name": "Teaching_Certificate.pdf",
        "uploadTime": "2025-07-11 14:28:00",
        "status": "verified",
      },
      {
        "name": "CV_John_Smith.pdf",
        "uploadTime": "2025-07-11 14:30:00",
        "status": "under_review",
      },
    ],
    "reviewSteps": [
      {"step": "Document Upload", "completed": true},
      {"step": "Initial Review", "completed": true},
      {"step": "Credential Verification", "completed": false},
      {"step": "Final Approval", "completed": false},
    ],
    "supportEmail": "verification@eduprofile.com",
    "supportPhone": "+1-555-0123",
  };

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _refreshStatus() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    HapticFeedback.lightImpact();
    _refreshController.forward();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    _refreshController.reverse();
    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Status updated successfully'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _requestNotificationPermission() async {
    // Simulate permission request
    HapticFeedback.selectionClick();
    setState(() {
      _notificationsEnabled = !_notificationsEnabled;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _notificationsEnabled
              ? 'Notifications enabled for status updates'
              : 'Notifications disabled',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Verification Status',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 24),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Verification Status Section
              VerificationStatusWidget(
                status: verificationData["status"] as String,
                submissionDate: verificationData["submissionDate"] as String,
                estimatedCompletion:
                    verificationData["estimatedCompletion"] as String,
                progressController: _progressController,
              ),

              const SizedBox(height: 24),

              // Review Process Steps
              ReviewProcessWidget(
                reviewSteps: (verificationData["reviewSteps"] as List)
                    .map((step) => step as Map<String, dynamic>)
                    .toList(),
              ),

              const SizedBox(height: 24),

              // Document Status
              DocumentStatusWidget(
                documents: (verificationData["documentsSubmitted"] as List)
                    .map((doc) => doc as Map<String, dynamic>)
                    .toList(),
              ),

              const SizedBox(height: 24),

              // Contact Support
              ContactSupportWidget(
                supportEmail: verificationData["supportEmail"] as String,
                supportPhone: verificationData["supportPhone"] as String,
                onEmailTap: () =>
                    _launchUrl('mailto:${verificationData["supportEmail"]}'),
                onPhoneTap: () =>
                    _launchUrl('tel:${verificationData["supportPhone"]}'),
              ),

              const SizedBox(height: 24),

              // Notification Settings
              _buildNotificationSettings(),

              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications, color: AppTheme.primaryTeal, size: 24),
              const SizedBox(width: 12),
              Text(
                'Notification Settings',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Updates',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get notified when your verification status changes',
                      style: AppTheme.lightTheme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Switch(
                value: _notificationsEnabled,
                onChanged: (_) => _requestNotificationPermission(),
                activeColor: AppTheme.primaryTeal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Check Status Button
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primaryTeal, AppTheme.accentPurple],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _isRefreshing ? null : _refreshStatus,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isRefreshing) ...[
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.surfaceWhite,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ] else ...[
                      Icon(
                        Icons.refresh,
                        color: AppTheme.surfaceWhite,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      _isRefreshing ? 'Checking...' : 'Check Status',
                      style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                        color: AppTheme.surfaceWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Update Profile Button
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/teacher-profile-completion');
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppTheme.primaryTeal, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.edit, color: AppTheme.primaryTeal, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Update Profile',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
