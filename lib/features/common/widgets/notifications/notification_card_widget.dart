import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/theme.dart';
import '../../../../widgets/custom_icon_widget.dart';
import '../../screens/notifications/notifications_screen.dart';

class NotificationCardWidget extends StatelessWidget {
  final NotificationItem notification;
  final bool isClicked;
  final VoidCallback? onTap;

  const NotificationCardWidget({
    Key? key,
    required this.notification,
    this.isClicked = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.8.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isClicked
                  ? AppTheme.primaryTeal.withValues(alpha: 0.08)
                  : AppTheme.lightTheme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: isClicked
                  ? Border.all(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                      width: 1,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isClicked
                      ? AppTheme.primaryTeal.withValues(alpha: 0.15)
                      : AppTheme.lightTheme.shadowColor.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification icon
                _buildNotificationIcon(),

                SizedBox(width: 3.w),

                // Content area
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        notification.title,
                        style: AppTheme.lightTheme.textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                              color: isClicked
                                  ? AppTheme.primaryTeal.withValues(alpha: 0.9)
                                  : AppTheme.textPrimary,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 0.8.h),

                      // Description
                      Text(
                        notification.description,
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(
                              fontSize: 13.sp,
                              color: isClicked
                                  ? AppTheme.textSecondary.withValues(
                                      alpha: 0.8,
                                    )
                                  : AppTheme.textSecondary,
                              height: 1.3,
                            ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 2.w),

                // Timestamp and status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      notification.timestamp,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        fontSize: 11.sp,
                        color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // Read status indicator or clicked indicator
                    if (isClicked)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Read',
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    else if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTeal,
                          shape: BoxShape.circle,
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
  }

  Widget _buildNotificationIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isClicked
            ? notification.iconColor.withValues(alpha: 0.15)
            : notification.iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: isClicked
            ? Border.all(
                color: notification.iconColor.withValues(alpha: 0.3),
                width: 1,
              )
            : null,
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: notification.icon,
          size: 24,
          color: isClicked ? notification.iconColor : notification.iconColor,
        ),
      ),
    );
  }
}
