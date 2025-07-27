import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/theme.dart';

class VerifyButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isLoading;

  const VerifyButtonWidget({
    super.key,
    required this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 85.w,
      height: 7.h,
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppTheme.primaryTeal
              : AppTheme.borderSubtle,
          foregroundColor: AppTheme.surfaceWhite,
          elevation: isEnabled ? 2 : 0,
          shadowColor: AppTheme.shadowLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        ),
        child: isLoading
            ? SizedBox(
                width: 5.w,
                height: 5.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.surfaceWhite,
                  ),
                ),
              )
            : Text(
                'Verify',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.surfaceWhite,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
