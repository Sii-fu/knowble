import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/theme.dart';

class AutoRedirectWidget extends StatefulWidget {
  final VoidCallback onTimerComplete;

  const AutoRedirectWidget({super.key, required this.onTimerComplete});

  @override
  State<AutoRedirectWidget> createState() => _AutoRedirectWidgetState();
}

class _AutoRedirectWidgetState extends State<AutoRedirectWidget> {
  int _countdown = 5;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _countdown--;
        });

        if (_countdown > 0) {
          _startCountdown();
        } else {
          widget.onTimerComplete();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 4.w,
              height: 4.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
              ),
            ),
            SizedBox(width: 3.w),
            Text(
              'Redirecting in $_countdown seconds...',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Text(
          'You will be automatically redirected to the login screen.',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
