import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:Knowble/config/theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class InstructorListItemCard extends StatelessWidget {
  final Map<String, dynamic> instructor;
  final bool isMultiSelectMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onViewDocuments;

  const InstructorListItemCard({
    super.key,
    required this.instructor,
    required this.isMultiSelectMode,
    required this.isSelected,
    required this.onTap,
    this.onApprove,
    this.onReject,
    this.onViewDocuments,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppTheme.successGreen;
      case 'rejected':
        return AppTheme.errorRed;
      case 'pending':
      default:
        return AppTheme.warningAmber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = instructor['status'] as String;
    final name = instructor['name'] as String;
    final email = instructor['email'] as String;
    final specialization = instructor['specialization'] as String;
    final experience = instructor['experience'] as String;
    final profileImage = instructor['profileImage'] as String? ?? '';

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 1.w,
        vertical: 1.h,
      ), // Reduced horizontal margin from 4.w to 1.w
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: AppTheme.primaryTeal, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Selection Checkbox
                      if (isMultiSelectMode) ...[
                        Checkbox(
                          value: isSelected,
                          onChanged: (_) => onTap(),
                          activeColor: AppTheme.primaryTeal,
                        ),
                        SizedBox(width: 2.w),
                      ],
                      // Profile Image
                      Container(
                        width: 15.w,
                        height: 15.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.borderSubtle,
                            width: 1,
                          ),
                        ),
                        child: ClipOval(
                          child: profileImage.isNotEmpty
                              ? Image.network(
                                  profileImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppTheme.accentLight,
                                      child: CustomIconWidget(
                                        iconName: 'person',
                                        color: AppTheme.primaryTeal,
                                        size: 8.w,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: AppTheme.accentLight,
                                  child: CustomIconWidget(
                                    iconName: 'person',
                                    color: AppTheme.primaryTeal,
                                    size: 8.w,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      // Instructor Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name and Status
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    name,
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .titleMedium
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
                            // Email
                            Text(
                              email,
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                            SizedBox(height: 0.5.h),
                            // Specialization and Experience
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'school',
                                  color: AppTheme.textSecondary,
                                  size: 14,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  specialization,
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(color: AppTheme.textSecondary),
                                ),
                                SizedBox(width: 3.w),
                                CustomIconWidget(
                                  iconName: 'work',
                                  color: AppTheme.textSecondary,
                                  size: 14,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  experience,
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Action Buttons
                  if (!isMultiSelectMode &&
                      status.toLowerCase() == 'pending') ...[
                    SizedBox(height: 2.h),
                    Divider(color: AppTheme.borderSubtle, height: 1),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onViewDocuments,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryTeal.withValues(
                                alpha: 0.1,
                              ),
                              foregroundColor: AppTheme.primaryTeal,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: CustomIconWidget(
                              iconName: 'description',
                              color: AppTheme.primaryTeal,
                              size: 16,
                            ),
                            label: Text(
                              'Docs',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onApprove,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successGreen.withValues(
                                alpha: 0.1,
                              ),
                              foregroundColor: AppTheme.successGreen,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: CustomIconWidget(
                              iconName: 'check_circle',
                              color: AppTheme.successGreen,
                              size: 16,
                            ),
                            label: Text(
                              'Approve',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: onReject,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.errorRed.withValues(
                                alpha: 0.1,
                              ),
                              foregroundColor: AppTheme.errorRed,
                              elevation: 0,
                              padding: EdgeInsets.symmetric(vertical: 1.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            icon: CustomIconWidget(
                              iconName: 'cancel',
                              color: AppTheme.errorRed,
                              size: 16,
                            ),
                            label: Text(
                              'Reject',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
