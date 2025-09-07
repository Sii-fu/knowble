import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../config/theme.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressIndicatorWidget({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Step $currentStep of $totalSteps',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                '${((currentStep / totalSteps) * 100).round()}%',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.primaryTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            value: currentStep / totalSteps,
            backgroundColor: AppTheme.borderSubtle,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
            minHeight: 1.h,
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepLabel('Registration', 1),
              _buildStepLabel('Document Upload', 2),
              _buildStepLabel('Interest Selection', 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel(String label, int step) {
    final isCompleted = step < currentStep;
    final isCurrent = step == currentStep;
    final isUpcoming = step > currentStep;

    Color textColor;
    FontWeight fontWeight;

    if (isCompleted) {
      textColor = AppTheme.successGreen;
      fontWeight = FontWeight.w600;
    } else if (isCurrent) {
      textColor = AppTheme.primaryTeal;
      fontWeight = FontWeight.w600;
    } else {
      textColor = AppTheme.textSecondary;
      fontWeight = FontWeight.w400;
    }

    return Flexible(
      child: Text(
        label,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: textColor,
          fontWeight: fontWeight,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
