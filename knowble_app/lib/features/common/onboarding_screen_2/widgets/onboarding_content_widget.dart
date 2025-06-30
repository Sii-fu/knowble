import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';
import 'package:knowble_app/widgets/custom_icon_widget.dart';

class OnboardingContentWidget extends StatelessWidget {
  final BuildContext context;

  const OnboardingContentWidget({
    super.key,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIllustration(),
          SizedBox(height: 6.h),
          _buildHeading(),
          SizedBox(height: 2.h),
          _buildSubtitle(),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 70.w,
      height: 35.h,
      decoration: BoxDecoration(
        color: AppTheme.accentLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.accentLight,
                  AppTheme.primaryTeal.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          // Main illustration content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Graduation cap with books stack
              Stack(
                alignment: Alignment.center,
                children: [
                  // Books stack background
                  _buildBooksStack(),
                  // Graduation cap on top
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: _buildGraduationCap(),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              // Learning elements
              _buildLearningElements(),
            ],
          ),
          // Floating decorative elements
          _buildFloatingElements(),
        ],
      ),
    );
  }

  Widget _buildBooksStack() {
    return Column(
      children: [
        // Book 1 (bottom)
        Container(
          width: 20.w,
          height: 3.h,
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        // Book 2 (middle)
        Transform.translate(
          offset: const Offset(-10, -8),
          child: Container(
            width: 18.w,
            height: 3.h,
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
        // Book 3 (top)
        Transform.translate(
          offset: const Offset(8, -16),
          child: Container(
            width: 16.w,
            height: 3.h,
            decoration: BoxDecoration(
              color: AppTheme.warningAmber.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGraduationCap() {
    return SizedBox(
      width: 15.w,
      height: 15.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cap base
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: AppTheme.textPrimary,
              shape: BoxShape.circle,
            ),
          ),
          // Cap top
          Container(
            width: 18.w,
            height: 2.h,
            decoration: BoxDecoration(
              color: AppTheme.textPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          // Tassel
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 1.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Graduation icon
          CustomIconWidget(
            iconName: 'school',
            color: AppTheme.surfaceWhite,
            size: 6.w,
          ),
        ],
      ),
    );
  }

  Widget _buildLearningElements() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Online learning icon
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: 'laptop',
            color: AppTheme.primaryTeal,
            size: 6.w,
          ),
        ),
        // Course variety icon
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.successGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: 'library_books',
            color: AppTheme.successGreen,
            size: 6.w,
          ),
        ),
        // Achievement icon
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.warningAmber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomIconWidget(
            iconName: 'emoji_events',
            color: AppTheme.warningAmber,
            size: 6.w,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingElements() {
    return Stack(
      children: [
        // Top left floating element
        Positioned(
          top: 3.h,
          left: 4.w,
          child: Container(
            width: 3.w,
            height: 3.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Top right floating element
        Positioned(
          top: 5.h,
          right: 6.w,
          child: Container(
            width: 2.w,
            height: 2.w,
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Bottom left floating element
        Positioned(
          bottom: 4.h,
          left: 8.w,
          child: Container(
            width: 2.5.w,
            height: 2.5.w,
            decoration: BoxDecoration(
              color: AppTheme.warningAmber.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Bottom right floating element
        Positioned(
          bottom: 6.h,
          right: 4.w,
          child: Container(
            width: 3.5.w,
            height: 3.5.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeading() {
    return SizedBox(
      width: double.infinity,
      child: Text(
        'Learn and Upskill as You Want',
        textAlign: TextAlign.center,
        style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Text(
        'Access thousands of courses and learn at your own pace',
        textAlign: TextAlign.center,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          color: AppTheme.textSecondary,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
