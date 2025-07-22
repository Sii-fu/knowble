import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/theme.dart';

class DateSectionHeaderWidget extends StatelessWidget {
  final String dateLabel;

  const DateSectionHeaderWidget({Key? key, required this.dateLabel})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(left: 4.w, right: 4.w, top: 2.h, bottom: 1.h),
      child: Text(
        dateLabel,
        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 16.sp,
          color: AppTheme.textPrimary,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
