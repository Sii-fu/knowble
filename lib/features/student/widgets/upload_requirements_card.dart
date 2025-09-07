import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class UploadRequirementsCard extends StatelessWidget {
  const UploadRequirementsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                size: 6.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Upload Requirements',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.warningAmber,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildRequirementItem('Document must be clear and readable'),
          SizedBox(height: 1.h),
          _buildRequirementItem('All corners of the document must be visible'),
          SizedBox(height: 1.h),
          _buildRequirementItem('Document must be valid and not expired'),
          SizedBox(height: 1.h),
          _buildRequirementItem('File size must be under 10MB'),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 0.5.h),
          child: CustomIconWidget(
            iconName: 'check_circle',
            color: AppTheme.successGreen,
            size: 4.w,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
