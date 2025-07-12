import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class AdminListItemCard extends StatelessWidget {
  final String title;
  final String description;
  final String timestamp;
  final String status;
  final String avatarUrl;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AdminListItemCard({
    super.key,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.status,
    required this.avatarUrl,
    this.onTap,
    this.onLongPress,
  });

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppTheme.successGreen;
      case 'rejected':
        return AppTheme.errorRed;
      case 'pending':
      default:
        return AppTheme.primaryTeal;
    }
  }

  String _getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'check_circle';
      case 'rejected':
        return 'cancel';
      case 'pending':
      default:
        return 'schedule';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12.0),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.borderSubtle, width: 1),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      avatarUrl,
                      width: 12.w,
                      height: 12.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppTheme.borderSubtle,
                          child: Icon(
                            Icons.person,
                            color: AppTheme.textSecondary,
                            size: 6.w,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 3.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppTheme.lightTheme.textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor().withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: _getStatusIcon(),
                                  color: _getStatusColor(),
                                  size: 12,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  status.toUpperCase(),
                                  style: AppTheme
                                      .lightTheme
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: _getStatusColor(),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        description,
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(color: AppTheme.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'access_time',
                            color: AppTheme.textSecondary,
                            size: 14,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            timestamp,
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Action indicator
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
