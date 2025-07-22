import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/theme.dart';
import './widgets/interest_chip_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/selected_interests_widget.dart';

class StudentInterestSelectionScreen extends StatefulWidget {
  const StudentInterestSelectionScreen({super.key});

  @override
  State<StudentInterestSelectionScreen> createState() =>
      _StudentInterestSelectionScreenState();
}

class _StudentInterestSelectionScreenState
    extends State<StudentInterestSelectionScreen> {
  final List<String> selectedInterests = [];
  final int minimumInterests = 5;

  final List<Map<String, dynamic>> availableInterests = [
    {"id": 1, "name": "Mathematics", "category": "STEM"},
    {"id": 2, "name": "Computer Science", "category": "Technology"},
    {"id": 3, "name": "Physics", "category": "STEM"},
    {"id": 4, "name": "Chemistry", "category": "STEM"},
    {"id": 5, "name": "Biology", "category": "STEM"},
    {"id": 6, "name": "English Literature", "category": "Language Arts"},
    {"id": 7, "name": "Creative Writing", "category": "Language Arts"},
    {"id": 8, "name": "History", "category": "Social Studies"},
    {"id": 9, "name": "Geography", "category": "Social Studies"},
    {"id": 10, "name": "Psychology", "category": "Social Studies"},
    {"id": 11, "name": "Art & Design", "category": "Creative Arts"},
    {"id": 12, "name": "Music Theory", "category": "Creative Arts"},
    {"id": 13, "name": "Photography", "category": "Creative Arts"},
    {"id": 14, "name": "Business Studies", "category": "Business"},
    {"id": 15, "name": "Economics", "category": "Business"},
    {"id": 16, "name": "Marketing", "category": "Business"},
    {"id": 17, "name": "Philosophy", "category": "Humanities"},
    {"id": 18, "name": "Sociology", "category": "Social Studies"},
    {"id": 19, "name": "Environmental Science", "category": "STEM"},
    {"id": 20, "name": "Foreign Languages", "category": "Language Arts"},
    {"id": 21, "name": "Statistics", "category": "STEM"},
    {"id": 22, "name": "Data Science", "category": "Technology"},
    {"id": 23, "name": "Web Development", "category": "Technology"},
    {"id": 24, "name": "Graphic Design", "category": "Creative Arts"},
  ];

  void _toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else {
        selectedInterests.add(interest);
      }
    });

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  void _navigateToDashboard() {
    if (selectedInterests.length >= minimumInterests) {
      // Navigate to student dashboard
      Navigator.pushReplacementNamed(context, '/student');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully selected ${selectedInterests.length} interests!',
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: AppTheme.textPrimary,
            size: 24,
          ),
        ),
        title: Text(
          'Select Your Interests',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personalize Your Learning',
                      style: AppTheme.lightTheme.textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select at least $minimumInterests subjects that interest you. This helps us recommend the best learning content for you.',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ProgressIndicatorWidget(
                      currentCount: selectedInterests.length,
                      minimumRequired: minimumInterests,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Interests Grid Section
              Text(
                'Available Subjects',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: availableInterests.map((interest) {
                  final interestName = interest["name"] as String;
                  final isSelected = selectedInterests.contains(interestName);

                  return InterestChipWidget(
                    label: interestName,
                    isSelected: isSelected,
                    onTap: () => _toggleInterest(interestName),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Selected Interests Display
              selectedInterests.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Interests (${selectedInterests.length})',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 8),
                        SelectedInterestsWidget(
                          selectedInterests: selectedInterests,
                          onRemove: _toggleInterest,
                        ),
                        const SizedBox(height: 24),
                      ],
                    )
                  : const SizedBox.shrink(),

              // Continue Button
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: selectedInterests.length >= minimumInterests
                      ? LinearGradient(
                          colors: [
                            AppTheme.primaryTeal,
                            AppTheme.primaryTeal.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: selectedInterests.length >= minimumInterests
                      ? null
                      : AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: selectedInterests.length >= minimumInterests
                        ? _navigateToDashboard
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Continue to Dashboard',
                        style: AppTheme.lightTheme.textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color:
                                  selectedInterests.length >= minimumInterests
                                  ? AppTheme.surfaceWhite
                                  : AppTheme.textSecondary,
                            ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Helper Text
              Center(
                child: Text(
                  selectedInterests.length < minimumInterests
                      ? 'Select ${minimumInterests - selectedInterests.length} more interests to continue'
                      : 'Great! You can add more or continue to dashboard',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: selectedInterests.length >= minimumInterests
                        ? AppTheme.successGreen
                        : AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
