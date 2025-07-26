import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../config/theme.dart';
import '../../../../../core/services/student/tag_service.dart';
import '../../../../../data/models/tag.dart';
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
  final TagService _tagService = TagService();

  List<Tag> availableTags = [];
  bool isLoading = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() {
      isLoading = true;
    });

    try {
      final tags = await _tagService.fetchAllTags();
      setState(() {
        availableTags = tags;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading interests: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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

  Future<void> _saveInterestsAndNavigate() async {
    if (selectedInterests.length < minimumInterests) return;

    setState(() {
      isSaving = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Get tag IDs for selected interests
      final selectedTagIds = availableTags
          .where((tag) => selectedInterests.contains(tag.name))
          .map((tag) => tag.id)
          .toList();

      // Save interests to database
      final success = await _tagService.saveStudentInterests(
        user.id,
        selectedTagIds,
      );

      if (success) {
        // Navigate to student dashboard
        if (mounted) {
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
      } else {
        throw Exception('Failed to save interests');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving interests: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isSaving = false;
      });
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
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryTeal),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
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
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
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
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                    ),

                    const SizedBox(height: 16),

                    if (availableTags.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No subjects available',
                              style: AppTheme.lightTheme.textTheme.bodyLarge
                                  ?.copyWith(color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadTags,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableTags.map((tag) {
                          final isSelected = selectedInterests.contains(
                            tag.name,
                          );

                          return InterestChipWidget(
                            label: tag.name,
                            isSelected: isSelected,
                            onTap: () => _toggleInterest(tag.name),
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
                          onTap:
                              (selectedInterests.length >= minimumInterests &&
                                  !isSaving)
                              ? _saveInterestsAndNavigate
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            alignment: Alignment.center,
                            child: isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppTheme.surfaceWhite,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Continue to Dashboard',
                                    style: AppTheme
                                        .lightTheme
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color:
                                              selectedInterests.length >=
                                                  minimumInterests
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
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              color:
                                  selectedInterests.length >= minimumInterests
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
