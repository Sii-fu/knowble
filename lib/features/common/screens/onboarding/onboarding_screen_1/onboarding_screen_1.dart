import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../../config/theme.dart';
import './widgets/onboarding_content_widget.dart';
import './widgets/onboarding_illustration_widget.dart';
import './widgets/onboarding_navigation_widget.dart';

class OnboardingScreen1 extends StatefulWidget {
  const OnboardingScreen1({super.key});

  @override
  State<OnboardingScreen1> createState() => _OnboardingScreen1State();
}

class _OnboardingScreen1State extends State<OnboardingScreen1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Skip button area
                SizedBox(height: 2.h),

                // Illustration section
                Expanded(flex: 5, child: OnboardingIllustrationWidget()),

                // Content section
                Expanded(flex: 3, child: OnboardingContentWidget()),

                // Navigation section
                Expanded(
                  flex: 2,
                  child: OnboardingNavigationWidget(
                    currentPage: 0,
                    totalPages: 3,
                    onNextPressed: () {
                      Navigator.pushNamed(context, '/onboarding-screen-2');
                    },
                  ),
                ),

                SizedBox(height: 2.h),
              ],
            ),

            // Skip button positioned at top-right
            Positioned(
              top: 2.h,
              right: 4.w,
              child: TextButton(
                onPressed: () {
                  // Navigate to main app or login screen
                  // For now, navigate to the last onboarding screen
                  Navigator.pushNamed(context, '/onboarding-screen-3');
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.textSecondary,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  minimumSize: Size(12.w, 6.h),
                ),
                child: Text(
                  'Skip',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
