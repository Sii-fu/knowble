import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../../../config/theme.dart';
import './widgets/onboarding_content_widget.dart';
import './widgets/onboarding_illustration_widget.dart';
import './widgets/onboarding_navigation_widget.dart';

class OnboardingScreen3 extends StatelessWidget {
  const OnboardingScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button at top right
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/splash-screen',
                        (route) => false,
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.h,
                      ),
                    ),
                    child: Text(
                      'Skip',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Main content area
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 2.h),

                    // Central illustration
                    OnboardingIllustrationWidget(),

                    SizedBox(height: 4.h),

                    // Content section with heading and subtitle
                    OnboardingContentWidget(),

                    SizedBox(height: 6.h),
                  ],
                ),
              ),
            ),

            // Bottom navigation with pagination and continue button
            OnboardingNavigationWidget(),

            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
