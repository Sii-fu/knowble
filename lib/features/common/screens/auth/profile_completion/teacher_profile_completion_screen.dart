import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:file_picker/file_picker.dart';

import '../../../../../config/theme.dart';
import '../../../../../core/services/auth_manager.dart';
import '../../../../../core/services/instructor_info_service.dart';
import './widgets/cv_upload_widget.dart';
import './widgets/education_degree_dropdown_widget.dart';
import './widgets/subject_expertise_selection_widget.dart';

class TeacherProfileCompletionScreen extends StatefulWidget {
  const TeacherProfileCompletionScreen({super.key});

  @override
  State<TeacherProfileCompletionScreen> createState() =>
      _TeacherProfileCompletionScreenState();
}

class _TeacherProfileCompletionScreenState
    extends State<TeacherProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _experienceController = TextEditingController();
  final _locationController = TextEditingController();
  final _bioController = TextEditingController();
  final _universityController =
      TextEditingController(); // Add university controller

  String? _selectedDegree;
  List<String> _selectedSubjects = [];
  String? _selectedFileName;
  File? _selectedFile; // Add File object storage
  PlatformFile? _selectedPlatformFile; // Add PlatformFile for web compatibility
  bool _isFormValid = false;
  bool _isSubmitting = false; // Add submission state

  final List<String> _degreeOptions = [
    'HSC',
    'Bachelors',
    'Masters',
    'PhD',
    'Other',
  ];

  final List<String> _subjectOptions = [
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'English',
    'History',
    'Geography',
    'Computer Science',
    'Economics',
    'Psychology',
    'Art',
    'Music',
    'Physical Education',
    'Foreign Languages',
    'Literature',
  ];

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validateForm);
    _experienceController.addListener(_validateForm);
    _bioController.addListener(_validateForm);
    _universityController.addListener(_validateForm); // Add university listener
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _experienceController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _universityController.dispose(); // Add university disposal
    super.dispose();
  }

  void _validateForm() {
    final isDegreeWithUniversityValid =
        _selectedDegree == null ||
        (_selectedDegree != null && _universityController.text.isNotEmpty);

    final isFileSelected =
        _selectedFileName != null &&
        (_selectedFile != null || _selectedPlatformFile != null);

    final isValid =
        _phoneController.text.isNotEmpty &&
        _selectedDegree != null &&
        isDegreeWithUniversityValid && // Check university is provided when degree is selected
        _experienceController.text.isNotEmpty &&
        _selectedSubjects.isNotEmpty &&
        _bioController.text.isNotEmpty &&
        isFileSelected; // Check that a file is selected

    if (_isFormValid != isValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  void _onDegreeChanged(String? value) {
    setState(() {
      _selectedDegree = value;
      // Clear university when degree changes
      if (value == null) {
        _universityController.clear();
      }
    });
    _validateForm();
  }

  void _onSubjectsChanged(List<String> subjects) {
    setState(() {
      _selectedSubjects = subjects;
    });
    _validateForm();
  }

  void _onFileSelected(String fileName) {
    print('DEBUG: File selected: $fileName');
    setState(() {
      _selectedFileName = fileName;
    });
    _validateForm();
  }

  void _onFileObjectSelected(File file) {
    print('DEBUG: File object selected: ${file.path}');
    setState(() {
      _selectedFile = file;
    });
  }

  void _onPlatformFileSelected(PlatformFile platformFile) {
    print(
      'DEBUG: Platform file selected: ${platformFile.name}, ${kIsWeb ? 'bytes: ${platformFile.bytes?.length}' : 'path: ${platformFile.path}'}',
    );
    setState(() {
      _selectedPlatformFile = platformFile;
      // Store file info similar to course creation pattern
      Map<String, dynamic> fileInfo = {'name': platformFile.name};
      if (kIsWeb) {
        fileInfo['bytes'] = platformFile.bytes;
      } else {
        fileInfo['path'] = platformFile.path;
      }
    });
    _validateForm(); // Add this to update form validation state
  }

  Future<void> _submitForm() async {
    print(
      '[DEBUG] _submitForm called, isFormValid: $_isFormValid, isSubmitting: $_isSubmitting',
    );

    // Debug each validation condition separately
    print('[DEBUG] Form validation details:');
    print('[DEBUG] - _isFormValid: $_isFormValid');
    print(
      '[DEBUG] - _formKey.currentState!.validate(): ${_formKey.currentState!.validate()}',
    );
    print('[DEBUG] - _isSubmitting: $_isSubmitting');

    if (!_isFormValid || !_formKey.currentState!.validate() || _isSubmitting) {
      print('[DEBUG] Early return - form validation failed');
      return;
    }

    // Get current user ID
    final userId = AuthManager.currentUserId;
    print('[DEBUG] User ID: $userId');
    if (userId == null) {
      _showErrorSnackBar('User not authenticated. Please log in again.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
    print('[DEBUG] Set submitting to true');

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryTeal),
        ),
      );
      print('[DEBUG] Loading dialog shown');

      // Check if file is selected
      print(
        '[DEBUG] Checking files - selectedFile: $_selectedFile, selectedPlatformFile: $_selectedPlatformFile',
      );
      if (_selectedFile == null && _selectedPlatformFile == null) {
        print('[DEBUG] No file selected');
        // Close loading dialog before showing error
        if (mounted) Navigator.pop(context);
        _showErrorSnackBar('Please select a CV/document file.');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Combine degree and university for storage
      final String combinedEducationInfo = _universityController.text.isNotEmpty
          ? '${_selectedDegree!} from ${_universityController.text.trim()}'
          : _selectedDegree!;

      // Submit instructor profile with platform-specific file handling
      print(
        '[DEBUG] Platform check - kIsWeb: $kIsWeb, platformFile bytes: ${_selectedPlatformFile?.bytes != null}${kIsWeb ? '' : ', platformFile path: ${_selectedPlatformFile?.path}'}',
      );

      if (kIsWeb &&
          _selectedPlatformFile != null &&
          _selectedPlatformFile!.bytes != null) {
        print('[DEBUG] Web upload path');
        // Web platform: use bytes (following course creation pattern)
        print(
          '[DEBUG] Calling InstructorInfoService.submitInstructorProfile (web)',
        );
        await InstructorInfoService.submitInstructorProfile(
          userId: userId,
          phoneNumber: _phoneController.text.trim(),
          educationDegree: combinedEducationInfo,
          teachingExperience: int.parse(_experienceController.text.trim()),
          currentLocation: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          subjectExpertise: _selectedSubjects,
          bio: _bioController.text.trim(),
          cvFileBytes: _selectedPlatformFile!.bytes!,
          cvFileName: _selectedFileName!,
        );
        print(
          '[DEBUG] InstructorInfoService.submitInstructorProfile (web) completed',
        );
      } else if (!kIsWeb &&
          _selectedPlatformFile != null &&
          _selectedPlatformFile!.path != null) {
        print('[DEBUG] Mobile upload path');
        // Mobile/Desktop platform: use File object (following course creation pattern)
        final file = File(_selectedPlatformFile!.path!);
        print(
          '[DEBUG] Calling InstructorInfoService.submitInstructorProfile (mobile/desktop)',
        );
        await InstructorInfoService.submitInstructorProfile(
          userId: userId,
          phoneNumber: _phoneController.text.trim(),
          educationDegree: combinedEducationInfo,
          teachingExperience: int.parse(_experienceController.text.trim()),
          currentLocation: _locationController.text.trim().isEmpty
              ? null
              : _locationController.text.trim(),
          subjectExpertise: _selectedSubjects,
          bio: _bioController.text.trim(),
          cvFile: file,
          cvFileName: _selectedFileName!,
        );
        print(
          '[DEBUG] InstructorInfoService.submitInstructorProfile (mobile/desktop) completed',
        );
      } else {
        print('[DEBUG] No valid upload path found');
        // Close loading dialog before showing error
        if (mounted) Navigator.pop(context);
        _showErrorSnackBar('Please select a CV/document file.');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      print('[DEBUG] Upload successful');

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profile submitted successfully! Awaiting verification.',
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      // Navigate to verification pending screen
      Navigator.pushReplacementNamed(context, '/teacher-verification');
    } catch (e) {
      print('[ERROR] Error occurred in _submitForm: $e');
      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // Show error message
      _showErrorSnackBar('Failed to submit profile: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppTheme.errorRed),
    );
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryTeal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'E',
                  style: TextStyle(
                    color: AppTheme.surfaceWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Complete Your Profile',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.school,
                      color: AppTheme.primaryTeal,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Professional Information',
                      style: AppTheme.lightTheme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Help us verify your teaching credentials',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Contact Information Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(15),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Phone Number *',
                        hintText: 'Enter your phone number',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.phone,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        if (value.length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Education Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Education & Experience',
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),
                    EducationDegreeDropdownWidget(
                      selectedDegree: _selectedDegree,
                      degreeOptions: _degreeOptions,
                      onChanged: _onDegreeChanged,
                    ),
                    // Show university field when degree is selected
                    if (_selectedDegree != null) ...[
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _universityController,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'University/Institution *',
                          hintText: 'Enter your university or institution name',
                          prefixIcon: Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.account_balance,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (_selectedDegree != null &&
                              (value == null || value.isEmpty)) {
                            return 'University/Institution name is required';
                          }
                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _experienceController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(2),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Teaching Experience (Years) *',
                        hintText: 'Enter years of experience',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.work,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Teaching experience is required';
                        }
                        final years = int.tryParse(value);
                        if (years == null || years < 0 || years > 50) {
                          return 'Please enter valid years (0-50)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _locationController,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Current Teaching Location (Optional)',
                        hintText: 'Enter your current workplace',
                        prefixIcon: Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.location_on,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Subject Expertise Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Subject Expertise',
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select subjects you can teach *',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SubjectExpertiseSelectionWidget(
                      subjects: _subjectOptions,
                      selectedSubjects: _selectedSubjects,
                      onSelectionChanged: _onSubjectsChanged,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bio Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Me',
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _bioController,
                      maxLines: 4,
                      maxLength: 500,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Bio/About Me *',
                        hintText:
                            'Tell us about your teaching philosophy and experience...',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Bio is required';
                        }
                        if (value.length < 50) {
                          return 'Please provide at least 50 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // CV Upload Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verification Documents',
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload your CV or teaching credentials *',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    CVUploadWidget(
                      selectedFileName: _selectedFileName,
                      selectedFile: _selectedFile,
                      selectedPlatformFile: _selectedPlatformFile,
                      onFileSelected: _onFileSelected,
                      onFileObjectSelected: _onFileObjectSelected,
                      onPlatformFileSelected: _onPlatformFileSelected,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Submit Button
              Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  gradient: _isFormValid && !_isSubmitting
                      ? LinearGradient(
                          colors: [
                            AppTheme.primaryTeal,
                            AppTheme.primaryTeal.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        )
                      : null,
                  color: _isFormValid && !_isSubmitting
                      ? null
                      : AppTheme.borderSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton(
                  onPressed: _isFormValid && !_isSubmitting
                      ? _submitForm
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
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
                          'Submit for Verification',
                          style: TextStyle(
                            color: _isFormValid && !_isSubmitting
                                ? AppTheme.surfaceWhite
                                : AppTheme.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
