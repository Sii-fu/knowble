import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../config/theme.dart';
import '../../../widgets/custom_icon_widget.dart';
import './widgets/feedback_category_dropdown.dart';
import './widgets/feedback_message_field.dart';
import './widgets/feedback_type_dropdown.dart';
import './widgets/submit_button.dart';

class FeedbackFormScreen extends StatefulWidget {
  const FeedbackFormScreen({super.key});

  @override
  State<FeedbackFormScreen> createState() => _FeedbackFormScreenState();
}

class _FeedbackFormScreenState extends State<FeedbackFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  String? _selectedFeedbackType;
  String? _selectedCategory;
  bool _isLoading = false;

  // Form validation errors
  String? _feedbackTypeError;
  String? _categoryError;
  String? _messageError;

  // Mock user data for demonstration
  final Map<String, dynamic> _mockUserData = {
    "user_id": "student_12345",
    "role": "student",
    "name": "Alex Johnson",
    "email": "alex.johnson@university.edu",
  };

  @override
  void initState() {
    super.initState();
    _messageController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _selectedFeedbackType != null &&
        _selectedCategory != null &&
        _messageController.text.trim().isNotEmpty;
  }

  void _validateForm() {
    setState(() {
      _feedbackTypeError = _selectedFeedbackType == null
          ? 'Please select a feedback type'
          : null;
      _categoryError = _selectedCategory == null
          ? 'Please select a category'
          : null;
      _messageError = _messageController.text.trim().isEmpty
          ? 'Please enter your feedback message'
          : null;
    });
  }

  Future<void> _submitFeedback() async {
    _validateForm();

    if (!_isFormValid) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate Supabase API call
      await Future.delayed(const Duration(seconds: 2));

      // Mock feedback data structure for Supabase insertion
      final Map<String, dynamic> feedbackData = {
        "user_id": _mockUserData["user_id"],
        "role": _mockUserData["role"],
        "feedback_type": _selectedFeedbackType,
        "category": _selectedCategory,
        "message": _messageController.text.trim(),
        "created_at": DateTime.now().toIso8601String(),
        "status": "submitted",
      };

      // Simulate successful submission
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Feedback submitted successfully!',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.surfaceWhite),
            ),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(4.w),
            duration: const Duration(seconds: 3),
          ),
        );

        // Reset form after successful submission
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit feedback. Please try again.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.surfaceWhite),
            ),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(4.w),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    setState(() {
      _selectedFeedbackType = null;
      _selectedCategory = null;
      _messageController.clear();
      _feedbackTypeError = null;
      _categoryError = null;
      _messageError = null;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Logout',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppTheme.textPrimary),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppTheme.textPrimary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Simulate logout - in real app, clear auth state
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Logged out successfully',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.surfaceWhite,
                      ),
                    ),
                    backgroundColor: AppTheme.primaryTeal,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: EdgeInsets.all(4.w),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: AppTheme.surfaceWhite,
              ),
              child: Text(
                'Logout',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppTheme.surfaceWhite),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: CustomIconWidget(
                iconName: 'arrow_back',
                color: AppTheme.textPrimary,
                size: 24,
              ),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
            SizedBox(width: 2.w),
            Text(
              'Submit Feedback',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 2.0,
        shadowColor: Colors.black26,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryTeal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.2),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${_mockUserData["name"]}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppTheme.primaryTeal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'We value your feedback to improve our educational platform.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Main form card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Form title
                        Text(
                          'Feedback Details',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        SizedBox(height: 3.h),

                        // Feedback Type Dropdown
                        FeedbackTypeDropdown(
                          selectedValue: _selectedFeedbackType,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedFeedbackType = value;
                              _feedbackTypeError = null;
                            });
                          },
                          errorText: _feedbackTypeError,
                        ),

                        SizedBox(height: 3.h),

                        // Category Dropdown
                        FeedbackCategoryDropdown(
                          selectedValue: _selectedCategory,
                          onChanged: (String? value) {
                            setState(() {
                              _selectedCategory = value;
                              _categoryError = null;
                            });
                          },
                          errorText: _categoryError,
                        ),

                        SizedBox(height: 3.h),

                        // Message Field
                        FeedbackMessageField(
                          controller: _messageController,
                          errorText: _messageError,
                          maxLength: 500,
                        ),

                        SizedBox(height: 4.h),

                        // Submit Button
                        SubmitButton(
                          onPressed: _submitFeedback,
                          isLoading: _isLoading,
                          isEnabled: _isFormValid,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 3.h),

                  // Navigation hint
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.borderSubtle,
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'info_outline',
                          color: AppTheme.primaryTeal,
                          size: 20,
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text(
                            'You can view your previous feedback submissions in the Feedback History section.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/feedback-history');
                          },
                          child: Text(
                            'View History',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
