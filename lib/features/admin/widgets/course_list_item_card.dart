import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:Knowble/config/theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class CourseListItemCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onTap;
  final VoidCallback? onDetails;

  const CourseListItemCard({
    super.key,
    required this.course,
    required this.onTap,
    this.onDetails,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppTheme.successGreen;
      case 'pending':
        return AppTheme.warningAmber;
      case 'rejected':
        return AppTheme.errorRed;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = course['status'] as String;
    final reportCount = course['reportCount'] as int? ?? 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
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
              children: [
                // Course Header with Thumbnail and Info
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    children: [
                      // Course Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          course['thumbnail'] as String,
                          width: 20.w,
                          height: 15.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 20.w,
                              height: 15.w,
                              color: AppTheme.borderSubtle,
                              child: CustomIconWidget(
                                iconName: 'school',
                                color: AppTheme.textSecondary,
                                size: 30,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 3.w),
                      // Course Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Course Title and Status
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    course['title'] as String,
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textPrimary,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      status,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: _getStatusColor(status),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            // Instructor
                            Text(
                              'By ${course['instructor'] as String}',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                            SizedBox(height: 1.h),
                            // Course Stats
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'people',
                                  color: AppTheme.textSecondary,
                                  size: 16,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  '${course['enrollmentCount']} enrolled',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(color: AppTheme.textSecondary),
                                ),
                                SizedBox(width: 3.w),
                                CustomIconWidget(
                                  iconName: 'schedule',
                                  color: AppTheme.textSecondary,
                                  size: 16,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  course['duration'] as String,
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                            SizedBox(height: 0.5.h),
                            // Price Information
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'attach_money',
                                  color: course['isPaid'] == true
                                      ? AppTheme.primaryTeal
                                      : AppTheme.successGreen,
                                  size: 16,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  course['isPaid'] == true
                                      ? '৳${(course['price'] ?? 0.0).toStringAsFixed(0)}'
                                      : 'Free',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                        color: course['isPaid'] == true
                                            ? AppTheme.primaryTeal
                                            : AppTheme.successGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                            if (reportCount > 0) ...[
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'report',
                                    color: AppTheme.errorRed,
                                    size: 16,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    '$reportCount reports',
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.errorRed,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Action Buttons
                Divider(color: AppTheme.borderSubtle, height: 1),
                Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Center(
                    child: SizedBox(
                      width: 40.w,
                      child: _buildActionButton(
                        'Details',
                        AppTheme.primaryTeal,
                        'visibility',
                        onDetails,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    Color color,
    String iconName,
    VoidCallback? onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 1.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: CustomIconWidget(iconName: iconName, color: color, size: 16),
      label: Text(
        label,
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
      ),
    );
  }
}
