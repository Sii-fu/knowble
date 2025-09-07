import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


import '../../../config/theme.dart';

class DocumentTypeSelectorWidget extends StatelessWidget {
  final String? selectedDocumentType;
  final Function(String?) onDocumentTypeChanged;

  const DocumentTypeSelectorWidget({
    Key? key,
    required this.selectedDocumentType,
    required this.onDocumentTypeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline,
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Document Type',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          _buildRadioOption('National ID'),
          SizedBox(height: 1.h),
          _buildRadioOption('Birth Certificate'),
        ],
      ),
    );
  }

  Widget _buildRadioOption(String value) {
    final isSelected = selectedDocumentType == value;

    return GestureDetector(
      onTap: () => onDocumentTypeChanged(value),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryTeal.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryTeal
                : AppTheme.lightTheme.colorScheme.outline,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 5.w,
              height: 5.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryTeal
                      : AppTheme.lightTheme.colorScheme.outline,
                  width: 2.0,
                ),
                color: isSelected ? AppTheme.primaryTeal : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 2.w,
                        height: 2.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.lightTheme.colorScheme.surface,
                        ),
                      ),
                    )
                  : null,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                value,
                style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                  color: isSelected
                      ? AppTheme.primaryTeal
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
