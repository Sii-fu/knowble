import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';
import 'package:knowble_app/widgets/custom_icon_widget.dart';

class OnboardingIllustrationWidget extends StatelessWidget {
  const OnboardingIllustrationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main illustration container
          Container(
            width: 70.w,
            height: 35.h,
            decoration: BoxDecoration(
              color: AppTheme.accentLight,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background elements
                Positioned(
                  top: 3.h,
                  left: 5.w,
                  child: Container(
                    width: 15.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: CustomIconWidget(
                        iconName: 'school',
                        color: AppTheme.primaryTeal,
                        size: 6.w,
                      ),
                    ),
                  ),
                ),

                // Teacher representation
                Positioned(
                  top: 5.h,
                  right: 8.w,
                  child: Container(
                    width: 20.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'person',
                          color: AppTheme.primaryTeal,
                          size: 8.w,
                        ),
                        SizedBox(height: 0.5.h),
                        Container(
                          width: 12.w,
                          height: 0.5.h,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(height: 0.3.h),
                        Container(
                          width: 8.w,
                          height: 0.3.h,
                          decoration: BoxDecoration(
                            color: AppTheme.textSecondary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Mathematical equations
                Positioned(
                  bottom: 8.h,
                  left: 3.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'x² + y² = z²',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Chart representation
                Positioned(
                  bottom: 3.h,
                  right: 5.w,
                  child: Container(
                    width: 18.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowLight,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildChartBar(6.h),
                              _buildChartBar(4.h),
                              _buildChartBar(7.h),
                            ],
                          ),
                          SizedBox(height: 0.5.h),
                          CustomIconWidget(
                            iconName: 'trending_up',
                            color: AppTheme.successGreen,
                            size: 4.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Book stack
                Positioned(
                  top: 15.h,
                  left: 12.w,
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

                // Graduation cap
                Positioned(
                  top: 8.h,
                  left: 25.w,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.warningAmber.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'school',
                      color: AppTheme.warningAmber,
                      size: 7.w,
                    ),
                  ),
                ),

                // Students representation
                Positioned(
                  bottom: 12.h,
                  left: 20.w,
                  child: Row(
                    children: [
                      _buildStudentAvatar(),
                      SizedBox(width: 1.w),
                      _buildStudentAvatar(),
                      SizedBox(width: 1.w),
                      _buildStudentAvatar(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(double height) {
    return Container(
      width: 1.5.w,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildBookStack() {
    return Stack(
      children: [
        Container(
          width: 8.w,
          height: 1.h,
          decoration: BoxDecoration(
            color: AppTheme.errorRed,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Positioned(
          top: 0.8.h,
          child: Container(
            width: 8.w,
            height: 1.h,
            decoration: BoxDecoration(
              color: AppTheme.successGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Positioned(
          top: 1.6.h,
          child: Container(
            width: 8.w,
            height: 1.h,
            decoration: BoxDecoration(
              color: AppTheme.warningAmber,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentAvatar() {
    return Container(
      width: 6.w,
      height: 6.w,
      decoration: BoxDecoration(
        color: AppTheme.primaryTeal.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primaryTeal,
          width: 1,
        ),
      ),
      child: CustomIconWidget(
        iconName: 'person',
        color: AppTheme.primaryTeal,
        size: 3.w,
      ),
    );
  }
}
