import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/theme.dart';

class FeedbackMessageField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final int maxLength;

  const FeedbackMessageField({
    super.key,
    required this.controller,
    this.errorText,
    this.maxLength = 500,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feedback Message *',
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
          child: TextFormField(
            controller: controller,
            maxLines: 6,
            minLines: 4,
            maxLength: maxLength,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
            ),
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
              hintText: 'Please describe your feedback in detail...',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              counterStyle: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
              errorText: null,
            ),
            textInputAction: TextInputAction.newline,
            keyboardType: TextInputType.multiline,
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
