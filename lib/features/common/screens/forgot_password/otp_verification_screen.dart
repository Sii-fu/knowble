import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';
import 'package:knowble_app/widgets/custom_icon_widget.dart';
import '../../widgets/forgot_password/countdown_timer_widget.dart';
import '../../widgets/forgot_password/phone_number_display_widget.dart';
import '../../widgets/forgot_password/verify_button_widget.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({Key? key}) : super(key: key);

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

  // Mock data for email
  final String _userEmail = 'john.doe@example.com';
  final int _otpLength = 6;
  final String _correctOtp = '123456'; // Mock OTP for validation

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

  void _onResendPressed() {
    // Simulate resend code functionality
    Fluttertoast.showToast(
      msg: "Verification code sent to your email",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.primaryTeal,
      textColor: AppTheme.surfaceWhite,
      fontSize: 14.sp,
    );

    setState(() {
      _otpController.clear();
      _hasError = false;
    });
  }

  Future<void> _verifyOtp() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (_otpController.text == _correctOtp) {
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
      Navigator.pushNamed(context, '/forgot-password/new-password');
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
        msg: "Invalid verification code. Please try again.",
        toastLength: Toast.LENGTH_LONG,
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
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.textPrimary,
            size: 24,
          ),
        ),
        title: Text(
          'Email Verification',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 4.h),

                // Header text
                Text(
                  'Enter Verification Code',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 2.h),

                // Email display
                PhoneNumberDisplayWidget(phoneNumber: _userEmail),

                SizedBox(height: 4.h),

                // Native OTP input field
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: Container(
                        width: 85.w,
                        child: TextField(
                          controller: _otpController,
                          focusNode: _otpFocusNode,
                          keyboardType: TextInputType.number,
                          maxLength: _otpLength,
                          textAlign: TextAlign.center,
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                                color: AppTheme.textPrimary,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 8.0,
                              ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '• • • • • •',
                            hintStyle: AppTheme
                                .lightTheme
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                  fontSize: 24.sp,
                                  letterSpacing: 8.0,
                                ),
                            filled: true,
                            fillColor: AppTheme.lightTheme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _hasError
                                    ? AppTheme.errorRed
                                    : AppTheme.borderSubtle,
                                width: _hasError ? 2 : 1,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _hasError
                                    ? AppTheme.errorRed
                                    : AppTheme.borderSubtle,
                                width: _hasError ? 2 : 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _hasError
                                    ? AppTheme.errorRed
                                    : AppTheme.primaryTeal,
                                width: 2,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 3.h,
                              horizontal: 4.w,
                            ),
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

                SizedBox(height: 2.h),

                // Error message
                _hasError
                    ? Container(
                        width: 85.w,
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        child: Text(
                          'Invalid verification code. Please try again.',
                          style: AppTheme.lightTheme.textTheme.bodySmall
                              ?.copyWith(
                                color: AppTheme.errorRed,
                                fontSize: 12.sp,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : SizedBox(height: 3.h),

                SizedBox(height: 4.h),

                // Countdown timer
                CountdownTimerWidget(
                  initialSeconds: 59,
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
