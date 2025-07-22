import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../config/theme.dart';
import '../../../../widgets/custom_icon_widget.dart';

class PasswordStrengthIndicatorWidget extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicatorWidget({super.key, required this.password});

  PasswordStrength _getPasswordStrength(String password) {
    if (password.isEmpty) return PasswordStrength.none;

    if (password.length >= 8) {
      return PasswordStrength.strong;
    } else {
      return PasswordStrength.weak;
    }
  }

  Color _getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return AppTheme.errorRed;
      case PasswordStrength.strong:
        return AppTheme.successGreen;
      case PasswordStrength.none:
        return AppTheme.borderSubtle;
      default:
        return AppTheme.borderSubtle;
    }
  }

  String _getStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.strong:
        return 'Strong';
      case PasswordStrength.none:
        return '';
      default:
        return '';
    }
  }

  double _getStrengthProgress(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.strong:
        return 1.0;
      case PasswordStrength.none:
        return 0.0;
      default:
        return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strength = _getPasswordStrength(password);
    final strengthColor = _getStrengthColor(strength);
    final strengthText = _getStrengthText(strength);
    final progress = _getStrengthProgress(strength);

    return password.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 0.5.h,
                      decoration: BoxDecoration(
                        color: AppTheme.borderSubtle,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: strengthColor,
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    strengthText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: strengthColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              _buildRequirement(),
            ],
          )
        : const SizedBox.shrink();
  }

  Widget _buildRequirement() {
    return Row(
      children: [
        CustomIconWidget(
          iconName: password.length >= 8
              ? 'check_circle'
              : 'radio_button_unchecked',
          color: password.length >= 8
              ? AppTheme.successGreen
              : AppTheme.textSecondary,
          size: 4.w,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            'At least 8 characters',
            style: TextStyle(
              color: password.length >= 8
                  ? AppTheme.successGreen
                  : AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

enum PasswordStrength { none, weak, strong }
