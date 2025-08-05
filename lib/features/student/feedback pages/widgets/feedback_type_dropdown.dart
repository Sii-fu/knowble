import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/theme.dart';
import '../../../../widgets/custom_icon_widget.dart';

class FeedbackTypeDropdown extends StatelessWidget {
  final String? selectedValue;
  final Function(String?) onChanged;
  final String? errorText;

  const FeedbackTypeDropdown({
    super.key,
    required this.selectedValue,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feedback Type *',
          style: theme.textTheme.labelLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null
                  ? AppTheme.errorRed
                  : AppTheme.borderSubtle,
              width: errorText != null ? 2.0 : 1.0,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 4.w,
                vertical: 2.h,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              hintText: 'Select feedback type',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              errorText: null,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
            dropdownColor: AppTheme.surfaceWhite,
            icon: CustomIconWidget(
              iconName: 'keyboard_arrow_down',
              color: AppTheme.primaryTeal,
              size: 24,
            ),
            items:
                const [
                  'Complaint',
                  'Bug',
                  'Feature Request',
                  'General Feedback',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
        errorText != null ? SizedBox(height: 0.5.h) : const SizedBox.shrink(),
        errorText != null
            ? Text(
                errorText!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.errorRed,
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
