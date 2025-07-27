import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';
import 'package:knowble_app/widgets/custom_icon_widget.dart';
import '../../widgets/forgot_password/countdown_timer_widget.dart';
import '../../widgets/forgot_password/phone_number_display_widget.dart';
import '../../widgets/forgot_password/verify_button_widget.dart';
import '../../../../core/services/forgot_password_service.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  bool _isLoading = false;
  bool _hasError = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  String _userEmail = '';

  final int _otpLength = 6;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _otpController.addListener(_onOtpChanged);

    // Auto-focus on the input field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNode.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get email from navigation arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args.containsKey('email')) {
      _userEmail = args['email'] as String;
    }
  }

  void _initializeAnimations() {
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  void _onOtpChanged() {
    setState(() {
      _hasError = false;
    });

    // Auto-verify when OTP is complete
    if (_otpController.text.length == _otpLength) {
      _verifyOtp();
    }
  }

  void _onTimerComplete() {
    // Timer completed, user can now resend code
    HapticFeedback.lightImpact();
  }

  void _onResendPressed() async {
    if (_userEmail.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ForgotPasswordService.resendOTP(email: _userEmail);

      if (result.success) {
        Fluttertoast.showToast(
          msg: result.message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.primaryTeal,
          textColor: AppTheme.surfaceWhite,
          fontSize: 14.sp,
        );
      } else {
        Fluttertoast.showToast(
          msg: result.message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.errorRed,
          textColor: AppTheme.surfaceWhite,
          fontSize: 14.sp,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "An error occurred while resending the code",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.errorRed,
        textColor: AppTheme.surfaceWhite,
        fontSize: 14.sp,
      );
    } finally {
      setState(() {
        _isLoading = false;
        _otpController.clear();
        _hasError = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    if (_userEmail.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final result = await ForgotPasswordService.verifyOTP(
        email: _userEmail,
        otp: _otpController.text,
      );

      if (result.success) {
        // Successful verification
        setState(() {
          _isLoading = false;
        });

        Fluttertoast.showToast(
          msg: "Email verification successful",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.successGreen,
          textColor: AppTheme.surfaceWhite,
          fontSize: 14.sp,
        );

        // Navigate to new password creation screen
        Navigator.pushNamed(
          context,
          '/forgot-password/new-password',
          arguments: {'email': _userEmail},
        );
      } else {
        // Invalid OTP
        setState(() {
          _isLoading = false;
          _hasError = true;
          _otpController.clear();
        });

        // Trigger shake animation
        _shakeController.forward().then((_) {
          _shakeController.reverse();
        });

        Fluttertoast.showToast(
          msg: result.message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppTheme.errorRed,
          textColor: AppTheme.surfaceWhite,
          fontSize: 14.sp,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _otpController.clear();
      });

      Fluttertoast.showToast(
        msg: "An error occurred while verifying the code",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppTheme.errorRed,
        textColor: AppTheme.surfaceWhite,
        fontSize: 14.sp,
      );
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            child: Column(
              children: [
                SizedBox(height: 4.h),

                // Header with back button
                Row(
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
                              color: AppTheme.lightTheme.shadowColor.withValues(
                                alpha: 0.1,
                              ),
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

                SizedBox(height: 2.h),

                Text(
                  'We sent a verification code to',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 1.h),

                // Email display
                PhoneNumberDisplayWidget(phoneNumber: _userEmail),

                SizedBox(height: 2.h),

                // TESTING NOTE
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'Enter OTP code',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13.sp,
                      color: AppTheme.primaryTeal,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 4.h),

                // OTP input field with shake animation
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: SizedBox(
                        width: 80.w,
                        child: TextFormField(
                          controller: _otpController,
                          focusNode: _otpFocusNode,
                          keyboardType: TextInputType.number,
                          maxLength: _otpLength,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 8,
                            color: AppTheme.textPrimary,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '● ● ● ● ● ●',
                            hintStyle: TextStyle(
                              fontSize: 24.sp,
                              color: AppTheme.textSecondary.withOpacity(0.3),
                              letterSpacing: 8,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _hasError
                                    ? AppTheme.errorRed
                                    : AppTheme.lightTheme.dividerColor,
                                width: _hasError ? 2 : 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _hasError
                                    ? AppTheme.errorRed
                                    : AppTheme.primaryTeal,
                                width: _hasError ? 2 : 1,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _hasError
                                    ? AppTheme.errorRed
                                    : AppTheme.lightTheme.dividerColor,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: AppTheme.lightTheme.cardColor,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(_otpLength),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 4.h),

                // Error message or success message space
                _hasError
                    ? Text(
                        'Invalid verification code. Please try again.',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              color: AppTheme.errorRed,
                              fontSize: 12.sp,
                            ),
                        textAlign: TextAlign.center,
                      )
                    : const SizedBox.shrink(),

                SizedBox(height: 4.h),

                // Countdown timer and resend
                CountdownTimerWidget(
                  initialSeconds: 600, // 10 minutes
                  onTimerComplete: _onTimerComplete,
                  onResendPressed: _onResendPressed,
                ),

                SizedBox(height: 4.h),

                // Verify button
                VerifyButtonWidget(
                  onPressed: _verifyOtp,
                  isEnabled: _otpController.text.length == _otpLength,
                  isLoading: _isLoading,
                ),

                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
