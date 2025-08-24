import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:Knowble/config/theme.dart';
import 'package:Knowble/widgets/custom_icon_widget.dart';
import '../../widgets/shared/app_logo_widget.dart';
import '../../widgets/forgot_password/continue_button_widget.dart';
import '../../../../core/services/forgot_password_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EmailSelectionScreen extends StatefulWidget {
  const EmailSelectionScreen({super.key});

  @override
  State<EmailSelectionScreen> createState() => _EmailSelectionScreenState();
}

class _EmailSelectionScreenState extends State<EmailSelectionScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _onContinuePressed() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address.';
      });
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await ForgotPasswordService.initiateForgotPassword(
        email: email,
      );

      if (result.success) {
        Fluttertoast.showToast(
          msg: result.message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.successGreen,
          textColor: AppTheme.surfaceWhite,
          fontSize: 14.sp,
        );

        if (mounted) {
          Navigator.pushNamed(
            context,
            '/forgot-password/otp-verification',
            arguments: {'email': email},
          );
        }
      } else {
        // Check if the error is about account not existing
        if (result.message.contains("don't have an account")) {
          // Show popup and redirect to registration
          _showAccountNotFoundDialog(email);
        } else {
          setState(() {
            _errorMessage = result.message;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showAccountNotFoundDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Account Not Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            "You don't have an account with this email address. Would you like to create a new account?",
            style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Stay on current screen
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to registration screen
                Navigator.pushReplacementNamed(context, '/register');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Create Account',
                style: TextStyle(
                  color: AppTheme.surfaceWhite,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
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
                                'Enter your email address to receive a password reset code',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                      fontSize: 14.sp,
                                      color: AppTheme.textSecondary,
                                      height: 1.4,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 1.h),
                              // TESTING NOTE
                              Container(
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryTeal.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: AppTheme.primaryTeal.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Enter your email.',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                        fontSize: 12.sp,
                                        color: AppTheme.primaryTeal,
                                        fontWeight: FontWeight.w500,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 6.h),

                        // Email input field
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontFamily: 'Jost',
                              fontSize: 16.sp,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              hintText: 'Enter your email address',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppTheme.textSecondary,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.lightTheme.dividerColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.lightTheme.dividerColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryTeal,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.errorRed,
                                ),
                              ),
                              filled: true,
                              fillColor: AppTheme.lightTheme.cardColor,
                            ),
                            onChanged: (value) {
                              setState(() {
                                _errorMessage = '';
                              });
                            },
                          ),
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
                    onPressed: _onContinuePressed,
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
