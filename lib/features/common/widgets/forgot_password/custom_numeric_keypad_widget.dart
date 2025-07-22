import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/theme.dart';
import '../../../../widgets/custom_icon_widget.dart';

class CustomNumericKeypadWidget extends StatelessWidget {
  final Function(String) onKeyPressed;
  final VoidCallback onBackspacePressed;

  const CustomNumericKeypadWidget({
    Key? key,
    required this.onKeyPressed,
    required this.onBackspacePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> keys = [
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '*',
      '0',
      'backspace',
    ];

    return Container(
      width: 85.w,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: keys.length,
        itemBuilder: (context, index) {
          final key = keys[index];
          final isBackspace = key == 'backspace';

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              isBackspace ? onBackspacePressed() : onKeyPressed(key);
            },
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderSubtle, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  splashColor: AppTheme.primaryTeal.withValues(alpha: 0.1),
                  highlightColor: AppTheme.primaryTeal.withValues(alpha: 0.05),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    isBackspace ? onBackspacePressed() : onKeyPressed(key);
                  },
                  child: Center(
                    child: isBackspace
                        ? CustomIconWidget(
                            iconName: 'backspace',
                            color: AppTheme.textPrimary,
                            size: 24,
                          )
                        : Text(
                            key,
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
