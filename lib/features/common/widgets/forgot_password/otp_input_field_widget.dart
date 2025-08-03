import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/theme.dart';
import '../../../../widgets/custom_icon_widget.dart';

class OtpInputFieldWidget extends StatelessWidget {
  final String otpValue;
  final int otpLength;
  final bool hasError;

  const OtpInputFieldWidget({
    super.key,
    required this.otpValue,
    this.otpLength = 6,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasError ? AppTheme.errorRed : AppTheme.borderSubtle,
          width: hasError ? 2 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(otpLength, (index) {
          bool hasValue = index < otpValue.length;
          return Container(
            width: 10.w,
            height: 5.h,
            decoration: BoxDecoration(
              color: hasValue
                  ? AppTheme.primaryTeal.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: hasValue
                    ? AppTheme.primaryTeal
                    : AppTheme.borderSubtle.withValues(alpha: 0.5),
                width: hasValue ? 1.5 : 1,
              ),
            ),
            child: Center(
              child: hasValue
                  ? CustomIconWidget(
                      iconName: 'circle',
                      color: AppTheme.primaryTeal,
                      size: 12,
                    )
                  : Container(),
            ),
          );
        }),
      ),
    );
  }
}
