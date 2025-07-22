import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';
import 'package:knowble_app/widgets/custom_icon_widget.dart';
import '../../widgets/shared/app_logo_widget.dart';
import '../../widgets/forgot_password/continue_button_widget.dart';
import '../../widgets/forgot_password/email_card_widget.dart';

class EmailSelectionScreen extends StatefulWidget {
  const EmailSelectionScreen({Key? key}) : super(key: key);

  @override
  State<EmailSelectionScreen> createState() => _EmailSelectionScreenState();
}

class _EmailSelectionScreenState extends State<EmailSelectionScreen> {
  bool _isEmailSelected = false;
  bool _isLoading = false;
  String _errorMessage = '';

  // Mock user email data
  final String _userEmail = "john.doe@example.com";

  void _onEmailCardTap() {
    setState(() {
      _isEmailSelected = true;
      _errorMessage = '';
    });
  }

  Future<void> _onContinuePressed() async {
    if (!_isEmailSelected) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Simulate email verification initiation
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        Navigator.pushNamed(context, '/forgot-password/otp-verification');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Header with back button
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 10.w,
                          height: 5.h,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.cardColor,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.lightTheme.shadowColor
                                    .withValues(alpha: 0.1),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Center(
                            child: CustomIconWidget(
                              iconName: 'arrow_back',
                              color: AppTheme.textPrimary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 4.h),

                        // App logo
                        const AppLogoWidget(),

                        SizedBox(height: 4.h),

                        // Title and description
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Column(
                            children: [
                              Text(
                                'Forgot Password?',
                                style: AppTheme
                                    .lightTheme
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 24.sp,
                                      color: AppTheme.textPrimary,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Select which contact details should we use to reset your password',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                      fontSize: 14.sp,
                                      color: AppTheme.textSecondary,
                                      height: 1.4,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 6.h),

                        // Email selection card
                        EmailCardWidget(
                          email: _userEmail,
                          onTap: _onEmailCardTap,
                          isSelected: _isEmailSelected,
                        ),

                        // Error message
                        _errorMessage.isNotEmpty
                            ? Container(
                                margin: EdgeInsets.only(top: 2.h),
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                child: Text(
                                  _errorMessage,
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                        color: AppTheme.errorRed,
                                        fontSize: 12.sp,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : const SizedBox.shrink(),

                        SizedBox(height: 8.h),
                      ],
                    ),
                  ),
                ),

                // Continue button
                Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: ContinueButtonWidget(
                    onPressed: _isEmailSelected ? _onContinuePressed : null,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),

            // Loading overlay
            _isLoading
                ? Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryTeal,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Initiating verification...',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14.sp,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
