import 'package:flutter/material.dart';
import '../../../../../config/theme.dart';

class ReviewProcessWidget extends StatelessWidget {
  final List<Map<String, dynamic>> reviewSteps;

  const ReviewProcessWidget({super.key, required this.reviewSteps});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.assignment_turned_in,
                color: AppTheme.primaryTeal,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Review Process',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Process Steps
          Column(
            children: reviewSteps.asMap().entries.map((entry) {
              final int index = entry.key;
              final Map<String, dynamic> step = entry.value;
              final bool isCompleted = step["completed"] as bool;
              final bool isLast = index == reviewSteps.length - 1;

              return _buildProcessStep(
                step["step"] as String,
                isCompleted,
                isLast,
                index + 1,
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Progress Summary
          _buildProgressSummary(),
        ],
      ),
    );
  }

  Widget _buildProcessStep(
    String stepName,
    bool isCompleted,
    bool isLast,
    int stepNumber,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step Indicator
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppTheme.successGreen
                    : AppTheme.borderSubtle,
                border: Border.all(
                  color: isCompleted
                      ? AppTheme.successGreen
                      : AppTheme.borderSubtle,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: AppTheme.surfaceWhite,
                      size: 16,
                    )
                  : Center(
                      child: Text(
                        stepNumber.toString(),
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isCompleted
                    ? AppTheme.successGreen.withValues(alpha: 0.3)
                    : AppTheme.borderSubtle,
              ),
          ],
        ),

        const SizedBox(width: 16),

        // Step Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stepName,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isCompleted
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isCompleted ? 'Completed' : 'Pending',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: isCompleted
                        ? AppTheme.successGreen
                        : AppTheme.warningAmber,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!isLast) const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSummary() {
    final int completedSteps = reviewSteps
        .where((step) => step["completed"] as bool)
        .length;
    final int totalSteps = reviewSteps.length;
    final double progress = completedSteps / totalSteps;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$completedSteps of $totalSteps completed',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Progress Bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: AppTheme.borderSubtle,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryTeal, AppTheme.successGreen],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '${(progress * 100).toInt()}% Complete',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryTeal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
