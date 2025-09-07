import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VerificationInfoCardWidget extends StatelessWidget {
  const VerificationInfoCardWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'verified_user',
                color: AppTheme.primaryTeal,
                size: 10.w,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Verify Your Identity',
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            'To ensure the security of our platform and comply with educational standards, we need to verify your identity. Please upload a clear photo of your government-issued document.',
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
