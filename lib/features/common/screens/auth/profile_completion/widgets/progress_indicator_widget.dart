import 'package:flutter/material.dart';
import '../../../../../../config/theme.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final int currentCount;
  final int minimumRequired;

  const ProgressIndicatorWidget({
    super.key,
    required this.currentCount,
    required this.minimumRequired,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentCount / minimumRequired).clamp(0.0, 1.0);
    final isComplete = currentCount >= minimumRequired;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              '$currentCount / $minimumRequired',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isComplete
                    ? AppTheme.successGreen
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.borderSubtle,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: isComplete
                    ? AppTheme.successGreen
                    : AppTheme.primaryTeal,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isComplete
              ? 'Minimum requirement met! ✓'
              : 'Select ${minimumRequired - currentCount} more to continue',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: isComplete ? AppTheme.successGreen : AppTheme.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
