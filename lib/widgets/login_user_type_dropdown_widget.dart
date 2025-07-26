import 'package:flutter/material.dart';
import 'package:knowble_app/config/theme.dart';

class LoginUserTypeDropdownWidget extends StatefulWidget {
  final String? value;
  final Function(String?) onChanged;

  const LoginUserTypeDropdownWidget({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<LoginUserTypeDropdownWidget> createState() =>
      _LoginUserTypeDropdownWidgetState();
}

class _LoginUserTypeDropdownWidgetState
    extends State<LoginUserTypeDropdownWidget> {
  // Login dropdown includes Admin option
  final List<String> _userTypes = ['Student', 'Instructor', 'Admin'];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppTheme.borderSubtle, width: 1),
      ),
      child: DropdownButtonFormField<String>(
        value: widget.value,
        isExpanded: true,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          prefixIcon: Icon(Icons.person_outline),
        ),
        hint: const Text(
          'Choose User Type',
          style: TextStyle(
            fontFamily: 'Jost',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        items: _userTypes.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Jost',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: widget.onChanged,
        dropdownColor: AppTheme.surfaceWhite,
        style: const TextStyle(
          fontFamily: 'Jost',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
