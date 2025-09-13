import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/consent_dialog.dart';
import './widgets/document_type_selector_widget.dart';
import './widgets/file_upload_area_widget.dart';
import './widgets/progress_indicator_widget.dart';
import './widgets/upload_requirements_widget.dart';
import './widgets/verification_info_card_widget.dart';
import '../../core/services/student/user_verification_service.dart';

class DocumentVerificationScreen extends StatefulWidget {
  const DocumentVerificationScreen({Key? key}) : super(key: key);

  @override
  State<DocumentVerificationScreen> createState() =>
      _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState
    extends State<DocumentVerificationScreen> {
  String? _selectedDocumentType;
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  bool _uploadSuccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),
              ProgressIndicatorWidget(currentStep: 2, totalSteps: 3),
              SizedBox(height: 4.h),
              VerificationInfoCardWidget(),
              SizedBox(height: 4.h),
              DocumentTypeSelectorWidget(
                selectedDocumentType: _selectedDocumentType,
                onDocumentTypeChanged: _onDocumentTypeChanged,
              ),
              SizedBox(height: 4.h),
              FileUploadAreaWidget(
                selectedFile: _selectedFile,
                onFileSelected: _onFileSelected,
                isUploading: _isUploading,
              ),
              SizedBox(height: 4.h),
              UploadRequirementsWidget(),
              SizedBox(height: 6.h),
              _buildUploadButton(),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CustomIconWidget(
          iconName: 'arrow_back',
          color: AppTheme.textPrimary,
          size: 6.w,
        ),
      ),
      title: Text(
        'Document Verification',
        style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildUploadButton() {
    final bool isButtonEnabled =
        _selectedDocumentType != null && _selectedFile != null && !_isUploading;

    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: isButtonEnabled ? _handleUpload : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isButtonEnabled
              ? (_uploadSuccess ? AppTheme.successGreen : AppTheme.primaryTeal)
              : AppTheme.borderSubtle,
          foregroundColor: AppTheme.surfaceWhite,
          elevation: isButtonEnabled ? 2.0 : 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: _isUploading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 5.w,
                    height: 5.w,
                    child: CircularProgressIndicator(
                      color: AppTheme.surfaceWhite,
                      strokeWidth: 2.0,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Uploading...',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.surfaceWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : _uploadSuccess
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'check_circle',
                    color: AppTheme.surfaceWhite,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Upload Successful',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.surfaceWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                'Upload Document',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: isButtonEnabled
                      ? AppTheme.surfaceWhite
                      : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  void _onDocumentTypeChanged(String? documentType) {
    setState(() {
      _selectedDocumentType = documentType;
    });
  }

  void _onFileSelected(PlatformFile? file) {
    setState(() {
      _selectedFile = file;
      _uploadSuccess = false;
    });
  }

  Future<void> _handleUpload() async {
    if (_selectedDocumentType == null || _selectedFile == null) {
      _showErrorMessage('Please select a document type and file');
      return;
    }

    // Show consent dialog first
    final hasConsent = await ConsentDialog.showDocumentConsentDialog(context);
    if (!hasConsent) {
      _showErrorMessage('Document submission requires your consent');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Validate file size
      if (_selectedFile!.size > 10 * 1024 * 1024) {
        throw Exception('File size exceeds 10MB limit');
      }

      // Get current user
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Upload document to storage
      String documentPath;
      if (kIsWeb && _selectedFile!.bytes != null) {
        documentPath = await UserVerificationService.uploadVerificationDocument(
          userId: user.id,
          documentType: _selectedDocumentType!.toLowerCase().replaceAll(
            ' ',
            '_',
          ),
          fileName: _selectedFile!.name,
          bytes: _selectedFile!.bytes!,
        );
      } else if (!kIsWeb && _selectedFile!.path != null) {
        documentPath = await UserVerificationService.uploadVerificationDocument(
          userId: user.id,
          documentType: _selectedDocumentType!.toLowerCase().replaceAll(
            ' ',
            '_',
          ),
          fileName: _selectedFile!.name,
          file: File(_selectedFile!.path!),
        );
      } else {
        throw Exception('No valid file data available');
      }

      // Submit verification request
      final success = await UserVerificationService.submitVerificationRequest(
        userId: user.id,
        documentType: _selectedDocumentType!,
        documentPath: documentPath,
      );

      if (!success) {
        throw Exception('Failed to submit verification request');
      }

      setState(() {
        _isUploading = false;
        _uploadSuccess = true;
      });

      _showSuccessMessage('Document uploaded successfully!');

      // Navigate to interest selection after success
      await Future.delayed(Duration(seconds: 1));
      _navigateToInterestSelection();
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadSuccess = false;
      });

      _showErrorMessage('Upload failed: ${e.toString()}');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.surfaceWhite,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.surfaceWhite,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: AppTheme.surfaceWhite,
              size: 5.w,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                message,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.surfaceWhite,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _navigateToInterestSelection() {
    // Navigate to interest selection screen (Step 3 of 3)
    Navigator.pushReplacementNamed(context, '/student-interest');
  }
}
