import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UploadRequirementsWidget extends StatelessWidget {
  const UploadRequirementsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> requirements = [
      'Document must be clear and readable',
      'All four corners must be visible',
      'Document must be valid and not expired',
      'File size must be under 10MB',
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.warningAmber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppTheme.warningAmber.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: AppTheme.warningAmber,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Upload Requirements',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.warningAmber,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          ...requirements
              .map((requirement) => _buildRequirementItem(requirement)),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String requirement) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 0.5.h),
            width: 1.w,
            height: 1.w,
            decoration: BoxDecoration(
              color: AppTheme.warningAmber,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              requirement,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
