import 'package:flutter/material.dart';
import 'package:Knowble/config/theme.dart';


class TermsCheckboxWidget extends StatelessWidget {
  final bool isChecked;
  final Function(bool?) onChanged;

  const TermsCheckboxWidget({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isChecked ? AppTheme.successGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isChecked ? AppTheme.successGreen : AppTheme.borderSubtle,
              width: 2,
            ),
          ),
          child: isChecked
              ? const Icon(
                  Icons.check,
                  size: 14,
                  color: AppTheme.surfaceWhite,
                )
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!isChecked),
            child: const Text(
              'I agree to the Terms and Conditions',
              style: TextStyle(
                fontFamily: 'Jost',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
