import 'package:flutter/material.dart';
import '../../../../../../config/theme.dart';

class SubjectExpertiseSelectionWidget extends StatelessWidget {
  final List<String> subjects;
  final List<String> selectedSubjects;
  final ValueChanged<List<String>> onSelectionChanged;

  const SubjectExpertiseSelectionWidget({
    super.key,
    required this.subjects,
    required this.selectedSubjects,
    required this.onSelectionChanged,
  });

  void _toggleSubject(String subject) {
    List<String> updatedSelection = List.from(selectedSubjects);

    if (updatedSelection.contains(subject)) {
      updatedSelection.remove(subject);
    } else {
      updatedSelection.add(subject);
    }

    onSelectionChanged(updatedSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected subjects display
        if (selectedSubjects.isNotEmpty) ...[
          Text(
            'Selected Subjects (${selectedSubjects.length})',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.primaryTeal,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedSubjects.map((subject) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTeal,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        subject,
                        style: const TextStyle(
                          color: AppTheme.surfaceWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _toggleSubject(subject),
                        child: const Icon(
                          Icons.close,
                          color: AppTheme.surfaceWhite,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // All subjects selection
        Text(
          'Available Subjects',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: subjects.map((subject) {
            final isSelected = selectedSubjects.contains(subject);
            return FilterChip(
              label: Text(subject),
              selected: isSelected,
              onSelected: (selected) => _toggleSubject(subject),
              backgroundColor: AppTheme.surfaceWhite,
              selectedColor: AppTheme.primaryTeal,
              checkmarkColor: AppTheme.surfaceWhite,
              labelStyle: TextStyle(
                color: isSelected
                    ? AppTheme.surfaceWhite
                    : AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected
                    ? AppTheme.primaryTeal
                    : AppTheme.borderSubtle,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
          }).toList(),
        ),

        if (selectedSubjects.isEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.errorRed.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info, color: AppTheme.errorRed, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Please select at least one subject',
                    style: TextStyle(
                      color: AppTheme.errorRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
