import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/theme.dart';

class GraduationCapIconWidget extends StatelessWidget {
  const GraduationCapIconWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: const BoxDecoration(
        color: AppTheme.primaryTeal,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.w),
          child: Image.asset(
            'assets/images/logo 3.png',
            width: 12.w,
            height: 12.w,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
