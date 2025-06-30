import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';
import 'package:knowble_app/widgets/custom_icon_widget.dart';

class OnboardingContentWidget extends StatelessWidget {
  const OnboardingContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 85.w,
      child: Column(
        children: [
          // Main heading
          Text(
            'Ready to Start Your Learning Journey?',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 18.sp,
              color: AppTheme.textPrimary,
              height: 1.3,
            ),
          ),

          SizedBox(height: 3.h),

          // Subtitle text
          Text(
            'Join thousands of learners and unlock your potential with our comprehensive courses designed for your success',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),

          SizedBox(height: 4.h),

          // Feature highlights
          _buildFeatureHighlights(),
        ],
      ),
    );
  }

  Widget _buildFeatureHighlights() {
    final List<Map<String, dynamic>> features = [
      {
        'icon': 'play_circle_outline',
        'title': 'Expert-Led Courses',
        'description': 'Learn from industry professionals',
      },
      {
        'icon': 'schedule',
        'title': 'Learn at Your Pace',
        'description': 'Flexible scheduling that fits your life',
      },
      {
        'icon': 'verified',
        'title': 'Certified Learning',
        'description': 'Earn certificates upon completion',
      },
    ];

    return Column(
      children: features
          .map((feature) => _buildFeatureItem(
                iconName: feature['icon'] as String,
                title: feature['title'] as String,
                description: feature['description'] as String,
              ))
          .toList(),
    );
  }

  Widget _buildFeatureItem({
    required String iconName,
    required String title,
    required String description,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: AppTheme.primaryTeal,
              size: 6.w,
            ),
          ),

          SizedBox(width: 4.w),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontSize: 11.sp,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
