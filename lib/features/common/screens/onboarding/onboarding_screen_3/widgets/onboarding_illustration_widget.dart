import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:Knowble/config/theme.dart';
import 'package:Knowble/widgets/custom_icon_widget.dart';

class OnboardingIllustrationWidget extends StatelessWidget {
  const OnboardingIllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85.w,
      height: 35.h,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background learning environment
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.accentLight, AppTheme.surfaceWhite],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Teacher representation
          Positioned(
            left: 8.w,
            top: 3.h,
            child: Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'person',
                color: AppTheme.primaryTeal,
                size: 8.w,
              ),
            ),
          ),

          // Book stack on the left
          Positioned(
            left: 2.w,
            bottom: 4.h,
            child: Column(
              children: [
                _buildBookStack(),
                SizedBox(height: 1.h),
                CustomIconWidget(
                  iconName: 'menu_book',
                  color: AppTheme.primaryTeal,
                  size: 6.w,
                ),
              ],
            ),
          ),

          // Mathematical equations in center
          Positioned(
            left: 25.w,
            top: 8.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMathEquation('E = mc²'),
                SizedBox(height: 1.h),
                _buildMathEquation('∫ f(x)dx'),
                SizedBox(height: 1.h),
                _buildMathEquation('π = 3.14159'),
              ],
            ),
          ),

          // Charts and graphs
          Positioned(
            right: 8.w,
            top: 5.h,
            child: Container(
              width: 20.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderSubtle, width: 1),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildChartBar(0.4),
                        _buildChartBar(0.7),
                        _buildChartBar(0.5),
                        _buildChartBar(0.9),
                      ],
                    ),
                  ),
                  Container(height: 1, color: AppTheme.borderSubtle),
                ],
              ),
            ),
          ),

          // Graduation cap
          Positioned(
            right: 4.w,
            bottom: 6.h,
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'school',
                color: AppTheme.primaryTeal,
                size: 7.w,
              ),
            ),
          ),

          // Student learning environment indicators
          Positioned(
            left: 15.w,
            bottom: 2.h,
            child: Row(
              children: [
                _buildLearningIndicator(
                  CustomIconWidget(
                    iconName: 'laptop',
                    color: AppTheme.successGreen,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 2.w),
                _buildLearningIndicator(
                  CustomIconWidget(
                    iconName: 'headphones',
                    color: AppTheme.warningAmber,
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 2.w),
                _buildLearningIndicator(
                  CustomIconWidget(
                    iconName: 'edit',
                    color: AppTheme.primaryTeal,
                    size: 5.w,
                  ),
                ),
              ],
            ),
          ),

          // Floating knowledge symbols
          Positioned(
            left: 35.w,
            top: 2.h,
            child: CustomIconWidget(
              iconName: 'lightbulb',
              color: AppTheme.warningAmber.withValues(alpha: 0.6),
              size: 4.w,
            ),
          ),

          Positioned(
            right: 15.w,
            bottom: 8.h,
            child: CustomIconWidget(
              iconName: 'star',
              color: AppTheme.successGreen.withValues(alpha: 0.6),
              size: 3.5.w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookStack() {
    return Column(
      children: [
        Container(
          width: 8.w,
          height: 1.5.h,
          decoration: BoxDecoration(
            color: AppTheme.errorRed.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Container(
          width: 9.w,
          height: 1.5.h,
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Container(
          width: 7.w,
          height: 1.5.h,
          decoration: BoxDecoration(
            color: AppTheme.warningAmber.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildMathEquation(String equation) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.borderSubtle, width: 0.5),
      ),
      child: Text(
        equation,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 10.sp,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildChartBar(double height) {
    return Container(
      width: 2.w,
      height: (8.h * height),
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildLearningIndicator(Widget icon) {
    return Container(
      width: 8.w,
      height: 8.w,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.borderSubtle, width: 1),
      ),
      child: Center(child: icon),
    );
  }
}
