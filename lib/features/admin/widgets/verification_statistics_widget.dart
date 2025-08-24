// verification_statistics_widget.dart
// Widget to display instructor verification statistics for admin dashboard

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../config/theme.dart';
import '../../../core/services/admin/admin_instructor_verification_service.dart';
import '../../../widgets/custom_icon_widget.dart';

class VerificationStatisticsWidget extends StatefulWidget {
  const VerificationStatisticsWidget({super.key});

  @override
  State<VerificationStatisticsWidget> createState() =>
      _VerificationStatisticsWidgetState();
}

class _VerificationStatisticsWidgetState
    extends State<VerificationStatisticsWidget> {
  Map<String, int>? _statistics;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final stats =
          await AdminInstructorVerificationService.getVerificationStatistics();
      setState(() {
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load statistics';
      });
      print('[ERROR] Failed to load verification statistics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Instructor Verification',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryTeal,
                  ),
                )
              else
                IconButton(
                  onPressed: _loadStatistics,
                  icon: CustomIconWidget(
                    iconName: 'refresh',
                    color: AppTheme.primaryTeal,
                    size: 20,
                  ),
                ),
            ],
          ),

          SizedBox(height: 2.h),

          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: AppTheme.errorRed, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _errorMessage,
                    style: TextStyle(color: AppTheme.errorRed),
                  ),
                ],
              ),
            )
          else if (_statistics != null) ...[
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Pending',
                    _statistics!['pending']?.toString() ?? '0',
                    Icons.pending_actions,
                    AppTheme.errorRed,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildStatCard(
                    'Verified',
                    _statistics!['verified']?.toString() ?? '0',
                    Icons.verified,
                    AppTheme.successGreen,
                  ),
                ),
              ],
            ),

            SizedBox(height: 2.h),

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total',
                    _statistics!['total']?.toString() ?? '0',
                    Icons.people,
                    AppTheme.primaryTeal,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildStatCard(
                    'Rejected',
                    _statistics!['rejected']?.toString() ?? '0',
                    Icons.cancel,
                    AppTheme.textSecondary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 3.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/admin/instructors');
                },
                icon: CustomIconWidget(
                  iconName: 'school',
                  color: AppTheme.surfaceWhite,
                  size: 20,
                ),
                label: const Text(
                  'Manage Instructors',
                  style: TextStyle(color: AppTheme.surfaceWhite),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
