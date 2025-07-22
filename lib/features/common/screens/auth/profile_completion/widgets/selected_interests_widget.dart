import 'package:flutter/material.dart';
import '../../../../../../config/theme.dart';

class SelectedInterestsWidget extends StatelessWidget {
  final List<String> selectedInterests;
  final Function(String) onRemove;

  const SelectedInterestsWidget({
    super.key,
    required this.selectedInterests,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.2)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: selectedInterests.map((interest) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  interest,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.surfaceWhite,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => onRemove(interest),
                  child: const Icon(
                    Icons.close,
                    color: AppTheme.surfaceWhite,
                    size: 16,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
