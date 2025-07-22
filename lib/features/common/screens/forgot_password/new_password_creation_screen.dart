import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:knowble_app/config/theme.dart';
import 'package:knowble_app/widgets/custom_icon_widget.dart';
import '../../widgets/forgot_password/continue_button_widget.dart';
import '../../widgets/forgot_password/graduation_cap_icon_widget.dart';
import '../../widgets/forgot_password/password_input_field_widget.dart';
import '../../widgets/forgot_password/password_strength_indicator_widget.dart';

class NewPasswordCreationScreen extends StatefulWidget {
  const NewPasswordCreationScreen({super.key});

  @override
  State<NewPasswordCreationScreen> createState() =>
      _NewPasswordCreationScreenState();
}

class _NewPasswordCreationScreenState extends State<NewPasswordCreationScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _passwordMatchError = '';

  @override
  void initState() {
    super.initState();
    _newPasswordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged() {
    setState(() {
      _passwordMatchError = '';
      if (_confirmPasswordController.text.isNotEmpty &&
          _newPasswordController.text != _confirmPasswordController.text) {
        _passwordMatchError = 'Passwords do not match';
      }
    });
  }

  bool _isPasswordValid() {
    final password = _newPasswordController.text;
    return password.length >= 8;
  }

  bool _doPasswordsMatch() {
    return _newPasswordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _newPasswordController.text == _confirmPasswordController.text;
  }

  bool _canContinue() {
    return _isPasswordValid() &&
        _doPasswordsMatch() &&
        _passwordMatchError.isEmpty;
  }

  Future<void> _handleContinue() async {
    if (!_canContinue()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate password creation process
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Show congratulations dialog
      _showCongratulationsDialog();
    }
  }

  void _showCongratulationsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.accentPurple, Color(0xFF9C27B0)],
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: EdgeInsets.all(6.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 25.w,
                  height: 25.w,
                  decoration: const BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'lock',
                      color: AppTheme.primaryTeal,
                      size: 12.w,
                    ),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Congratulations!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.surfaceWhite,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Your password has been successfully created. You will be redirected to the login screen in a few seconds.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.surfaceWhite,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 3.h),
                SizedBox(
                  width: 6.w,
                  height: 6.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.surfaceWhite,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Auto-redirect after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.textPrimary,
            size: 6.w,
          ),
        ),
        title: Text(
          'Create New Password',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(6.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 4.h),
                const GraduationCapIconWidget(),
                SizedBox(height: 4.h),
                Text(
                  'Create Your New Password',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Your new password must be at least 8 characters long.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                PasswordInputFieldWidget(
                  label: 'New Password',
                  hintText: 'Enter your new password',
                  controller: _newPasswordController,
                  onChanged: _onPasswordChanged,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (!_isPasswordValid()) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 2.h),
                PasswordStrengthIndicatorWidget(
                  password: _newPasswordController.text,
                ),
                SizedBox(height: 3.h),
                PasswordInputFieldWidget(
                  label: 'Confirm Password',
                  hintText: 'Confirm your new password',
                  controller: _confirmPasswordController,
                  isConfirmPassword: true,
                  onChanged: _onPasswordChanged,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                _passwordMatchError.isNotEmpty
                    ? Padding(
                        padding: EdgeInsets.only(top: 1.h),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _passwordMatchError,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppTheme.errorRed),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                SizedBox(height: 6.h),
                ContinueButtonWidget(
                  onPressed: _canContinue() ? _handleContinue : null,
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
