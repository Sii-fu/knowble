import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';
import 'package:knowble_app/widgets/custom_icon_widget.dart';


class OnboardingNavigationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNextPressed;

  const OnboardingNavigationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onNextPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Pagination dots
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              totalPages,
              (index) => _buildPaginationDot(index == currentPage),
            ),
          ),

          SizedBox(width: 4.w),

          // Next button
          GestureDetector(
            onTap: onNextPressed,
            child: Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'arrow_forward',
                  color: AppTheme.surfaceWhite,
                  size: 6.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationDot(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      width: isActive ? 8.w : 2.w,
      height: 2.w,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryTeal : AppTheme.borderSubtle,
        borderRadius: BorderRadius.circular(1.w),
      ),
    );
  }
}
