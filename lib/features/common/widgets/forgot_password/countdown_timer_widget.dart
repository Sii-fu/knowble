import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/theme.dart';

class CountdownTimerWidget extends StatefulWidget {
  final int initialSeconds;
  final VoidCallback onTimerComplete;
  final VoidCallback onResendPressed;

  const CountdownTimerWidget({
    super.key,
    this.initialSeconds = 59,
    required this.onTimerComplete,
    required this.onResendPressed,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isTimerActive = true;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.initialSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _isTimerActive = false;
        });
        _timer?.cancel();
        widget.onTimerComplete();
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _remainingSeconds = widget.initialSeconds;
      _isTimerActive = true;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isTimerActive
              ? Text(
                  'Resend Code in ${_remainingSeconds}s',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 14.sp,
                  ),
                )
              : GestureDetector(
                  onTap: () {
                    _resetTimer();
                    widget.onResendPressed();
                  },
                  child: Text(
                    'Resend Code',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryTeal,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
