import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/theme.dart';
import '../../../../widgets/custom_icon_widget.dart';

class FeedbackCardWidget extends StatelessWidget {
  final Map<String, dynamic> feedback;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const FeedbackCardWidget({
    super.key,
    required this.feedback,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTypeBadge(context),
                  const Spacer(),
                  Text(
                    _formatDate(
                      (feedback['submitted_at'] as String?) ??
                          DateTime.now().toIso8601String(),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                (feedback['message'] as String? ?? '').isNotEmpty
                    ? (feedback['message'] as String)
                    : 'No message provided',
                style: theme.textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  _buildCategoryChip(context),
                  const Spacer(),
                  _buildStatusIndicator(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(BuildContext context) {
    final theme = Theme.of(context);
    final type = feedback['type'] as String? ?? 'General Feedback';

    Color badgeColor;
    switch (type.toLowerCase()) {
      case 'complaint':
        badgeColor = theme.colorScheme.error;
        break;
      case 'bug':
        badgeColor = Colors.orange;
        break;
      case 'feature request':
        badgeColor = Colors.blue;
        break;
      default:
        badgeColor = theme.colorScheme.primary;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        type,
        style: theme.textTheme.labelSmall?.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context) {
    final theme = Theme.of(context);
    final category = feedback['category'] as String? ?? 'Other';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: _getCategoryIcon(category),
            size: 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 1.w),
          Text(
            category,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final status = feedback['status'] as String? ?? 'Submitted';

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'under review':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'resolved':
        statusColor = AppTheme.successGreen;
        statusIcon = Icons.check_circle;
        break;
      case 'closed':
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = theme.colorScheme.onSurfaceVariant;
        statusIcon = Icons.info;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: statusIcon.codePoint.toString(),
          size: 16,
          color: statusColor,
        ),
        SizedBox(width: 1.w),
        Text(
          status,
          style: theme.textTheme.labelSmall?.copyWith(
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Unknown date';
    }
  }
}
