import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/theme.dart';
import '../../../../widgets/custom_icon_widget.dart';

class InstructorFeedbackDetailDialog extends StatelessWidget {
  final Map<String, dynamic> feedback;

  const InstructorFeedbackDetailDialog({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(maxHeight: 80.h, maxWidth: 90.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(6.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoSection(context),
                    SizedBox(height: 3.h),
                    _buildMessageSection(context),
                    if (feedback['admin_notes'] != null &&
                        (feedback['admin_notes'] as String).isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      _buildResponseSection(context),
                    ],
                    SizedBox(height: 3.h),
                    _buildTimestampSection(context),
                  ],
                ),
              ),
            ),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.instructorPrimary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Feedback Details',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppTheme.instructorPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'close',
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final theme = Theme.of(context);
    final type = feedback['type'] as String? ?? 'General Feedback';
    final category = feedback['category'] as String? ?? 'Other';
    final status = feedback['status'] as String? ?? 'submitted';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildInfoChip(
              context,
              label: type,
              color: _getTypeColor(type, theme),
              icon: 'feedback',
            ),
            SizedBox(width: 3.w),
            _buildInfoChip(
              context,
              label: category,
              color: AppTheme.instructorSecondary,
              icon: _getCategoryIcon(category),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        _buildStatusChip(context, status),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required String label,
    required Color color,
    required String icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(iconName: icon, size: 16, color: color),
          SizedBox(width: 2.w),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(status, theme);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2.w),
          Text(
            'Status: $status',
            style: theme.textTheme.labelMedium?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageSection(BuildContext context) {
    final theme = Theme.of(context);
    final message = feedback['message'] as String? ?? 'No message provided';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Feedback',
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.instructorAccent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.instructorPrimary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponseSection(BuildContext context) {
    final theme = Theme.of(context);
    final adminNotes = feedback['admin_notes'] as String? ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Response',
          style: theme.textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.successGreen.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            adminNotes,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampSection(BuildContext context) {
    final theme = Theme.of(context);
    final submittedAt = feedback['submitted_at'] as String?;
    final resolvedAt = feedback['resolved_at'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (submittedAt != null) ...[
          Row(
            children: [
              CustomIconWidget(
                iconName: 'schedule',
                size: 16,
                color: AppTheme.textSecondary,
              ),
              SizedBox(width: 2.w),
              Text(
                'Submitted: ${_formatDateTime(submittedAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
        if (resolvedAt != null) ...[
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'check_circle',
                size: 16,
                color: AppTheme.successGreen,
              ),
              SizedBox(width: 2.w),
              Text(
                'Resolved: ${_formatDateTime(resolvedAt)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.successGreen,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.borderSubtle, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Close',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type, ThemeData theme) {
    switch (type.toLowerCase()) {
      case 'complaint':
        return theme.colorScheme.error;
      case 'bug':
        return Colors.orange;
      case 'feature request':
        return AppTheme.instructorPrimary;
      default:
        return AppTheme.instructorPrimary;
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return AppTheme.instructorPrimary;
      case 'in_review':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return AppTheme.successGreen;
      case 'closed':
        return theme.colorScheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'course':
        return 'school';
      case 'payment':
        return 'payment';
      case 'student':
        return 'person';
      case 'app ui':
        return 'smartphone';
      default:
        return 'help_outline';
    }
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown date';
    }
  }
}
