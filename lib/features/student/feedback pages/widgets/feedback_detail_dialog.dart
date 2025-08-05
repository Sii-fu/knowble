import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/theme.dart';
import '../../../../widgets/custom_icon_widget.dart';

class FeedbackDetailDialog extends StatelessWidget {
  final Map<String, dynamic> feedback;

  const FeedbackDetailDialog({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    if (feedback['admin_response'] != null) ...[
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
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
                color: theme.colorScheme.primary,
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
    final type = feedback['feedback_type'] as String? ?? 'General Feedback';
    final category = feedback['category'] as String? ?? 'Other';
    final status = feedback['status'] as String? ?? 'Submitted';

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
              color: theme.colorScheme.secondary,
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
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Text(message, style: theme.textTheme.bodyMedium),
        ),
      ],
    );
  }

  Widget _buildResponseSection(BuildContext context) {
    final theme = Theme.of(context);
    final response = feedback['admin_response'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'support_agent',
              size: 20,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: 2.w),
            Text(
              'Admin Response',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Text(
            response,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimestampSection(BuildContext context) {
    final theme = Theme.of(context);
    final createdAt = feedback['created_at'] as String?;
    final updatedAt = feedback['updated_at'] as String?;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (createdAt != null)
            _buildTimestampRow(
              context,
              'Submitted',
              _formatFullDate(createdAt),
              'schedule',
            ),
          if (updatedAt != null && updatedAt != createdAt) ...[
            SizedBox(height: 1.h),
            _buildTimestampRow(
              context,
              'Last Updated',
              _formatFullDate(updatedAt),
              'update',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimestampRow(
    BuildContext context,
    String label,
    String date,
    String icon,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CustomIconWidget(
          iconName: icon,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        SizedBox(width: 2.w),
        Text(
          '$label: ',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          date,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final status = feedback['status'] as String? ?? 'Submitted';
    final canFollowUp =
        status.toLowerCase() != 'resolved' && status.toLowerCase() != 'closed';

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          if (canFollowUp)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/feedback-form-screen');
                },
                icon: CustomIconWidget(
                  iconName: 'add_comment',
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                label: Text('Follow Up'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
          if (canFollowUp) SizedBox(width: 4.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
              child: Text('Close'),
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
        return Colors.blue;
      default:
        return theme.colorScheme.primary;
    }
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'under review':
        return Colors.orange;
      case 'resolved':
        return AppTheme.successGreen;
      case 'closed':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'course':
        return 'school';
      case 'payment':
        return 'payment';
      case 'instructor':
        return 'person';
      case 'app ui':
        return 'smartphone';
      default:
        return 'help_outline';
    }
  }

  String _formatFullDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Unknown date';
    }
  }
}
