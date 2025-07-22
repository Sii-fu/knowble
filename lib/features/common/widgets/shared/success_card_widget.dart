import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/theme.dart';
import './auto_redirect_widget.dart';
import './success_icon_widget.dart';
import './success_message_widget.dart';

class SuccessCardWidget extends StatelessWidget {
  final VoidCallback onTimerComplete;

  const SuccessCardWidget({super.key, required this.onTimerComplete});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      constraints: BoxConstraints(maxWidth: 400, minHeight: 50.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SuccessIconWidget(),
            SizedBox(height: 4.h),
            const SuccessMessageWidget(),
            SizedBox(height: 4.h),
            AutoRedirectWidget(onTimerComplete: onTimerComplete),
          ],
        ),
      ),
    );
  }
}
