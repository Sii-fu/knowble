import 'package:flutter/material.dart';
import '../../../../../../config/theme.dart';

class EducationDegreeDropdownWidget extends StatelessWidget {
  final String? selectedDegree;
  final List<String> degreeOptions;
  final ValueChanged<String?> onChanged;

  const EducationDegreeDropdownWidget({
    super.key,
    required this.selectedDegree,
    required this.degreeOptions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedDegree,
      decoration: InputDecoration(
        labelText: 'Education Degree *',
        hintText: 'Select your highest degree',
        prefixIcon: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.school, color: AppTheme.textSecondary, size: 20),
        ),
      ),
      items: degreeOptions.map((String degree) {
        return DropdownMenuItem<String>(
          value: degree,
          child: Text(degree, style: AppTheme.lightTheme.textTheme.bodyMedium),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select your education degree';
        }
        return null;
      },
      dropdownColor: AppTheme.surfaceWhite,
      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
        color: AppTheme.textPrimary,
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down,
        color: AppTheme.textSecondary,
        size: 24,
      ),
    );
  }
}
