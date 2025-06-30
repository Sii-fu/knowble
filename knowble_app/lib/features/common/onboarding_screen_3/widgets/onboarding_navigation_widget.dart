import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';
import 'package:knowble_app/widgets/custom_icon_widget.dart';

class OnboardingNavigationWidget extends StatelessWidget {
  const OnboardingNavigationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      child: Column(
        children: [
          // Navigation row with dots and button aligned to right
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Pagination dots
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDot(isActive: false),
                  SizedBox(width: 2.w),
                  _buildDot(isActive: false),
                  SizedBox(width: 2.w),
                  _buildDot(isActive: true), // Current page (page 3)
                ],
              ),

              SizedBox(width: 4.w),

              // Get Started circular button
              GestureDetector(
                onTap: () {
                  // Navigate to registration screen
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/registration-screen',
                    (route) => false,
                  );
                },
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

          SizedBox(height: 4.h),

          // Get Started button
          _buildGetStartedButton(context),
        ],
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 8.w : 3.w,
      height: 1.5.h,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryTeal : AppTheme.borderSubtle,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildGetStartedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Get Started button with enhanced styling
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Navigate to registration screen
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/registration-screen',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: AppTheme.surfaceWhite,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                minimumSize: Size(50.w, 7.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Get Started',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.surfaceWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  CustomIconWidget(
                    iconName: 'arrow_forward',
                    color: AppTheme.surfaceWhite,
                    size: 5.w,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
