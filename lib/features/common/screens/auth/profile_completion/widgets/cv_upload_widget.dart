import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../../../config/theme.dart';

class CVUploadWidget extends StatelessWidget {
  final String? selectedFileName;
  final File? selectedFile;
  final PlatformFile?
  selectedPlatformFile; // Add PlatformFile for web compatibility
  final ValueChanged<String> onFileSelected;
  final ValueChanged<File>? onFileObjectSelected;
  final ValueChanged<PlatformFile>?
  onPlatformFileSelected; // Add callback for PlatformFile

  const CVUploadWidget({
    super.key,
    required this.selectedFileName,
    this.selectedFile,
    this.selectedPlatformFile,
    required this.onFileSelected,
    this.onFileObjectSelected,
    this.onPlatformFileSelected,
  });

  Future<void> _pickFile(BuildContext context) async {
    try {
      print('[DEBUG] _pickFile called');
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null) {
        final PlatformFile platformFile = result.files.first;
        print(
          '[DEBUG] FilePicker result: name: ${platformFile.name}, size: ${platformFile.size}${kIsWeb ? ', bytes available: ${platformFile.bytes != null}' : ', path: ${platformFile.path}'}',
        );

        // Check file size (10MB limit)
        if (platformFile.size > 10 * 1024 * 1024) {
          print('[ERROR] File too large: ${platformFile.size} bytes');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File size must be less than 10MB'),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
          return;
        }

        // Call the callback with the selected file name
        print('[DEBUG] Calling onFileSelected with: ${platformFile.name}');
        onFileSelected(platformFile.name);

        // Create file info map similar to working pattern
        Map<String, dynamic> fileInfo = {'name': platformFile.name};

        // Platform-specific file handling (following working pattern)
        if (kIsWeb && platformFile.bytes != null) {
          print(
            '[DEBUG] Web platform: storing bytes (${platformFile.bytes!.length} bytes)',
          );
          fileInfo['bytes'] = platformFile.bytes;
        } else if (!kIsWeb && platformFile.path != null) {
          print(
            '[DEBUG] Mobile/Desktop platform: storing path (${platformFile.path})',
          );
          fileInfo['path'] = platformFile.path;
        } else {
          print('[ERROR] No valid file data available');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('File data not available. Please try again.'),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
          return;
        }

        // Pass the PlatformFile object (works for both web and mobile)
        if (onPlatformFileSelected != null) {
          print(
            '[DEBUG] Calling onPlatformFileSelected with fileInfo: $fileInfo',
          );
          try {
            onPlatformFileSelected!(platformFile);
            print(
              '[DEBUG] onPlatformFileSelected callback executed successfully',
            );
          } catch (e) {
            print('[ERROR] Exception in onPlatformFileSelected callback: $e');
          }
        }

        // Handle file object creation for mobile/desktop platforms only
        if (!kIsWeb &&
            onFileObjectSelected != null &&
            platformFile.path != null) {
          print('[DEBUG] Creating File object for: ${platformFile.path}');
          try {
            final file = File(platformFile.path!);
            onFileObjectSelected!(file);
            print('[DEBUG] File object created successfully');
          } catch (e) {
            print('[ERROR] Exception creating File object: $e');
          }
        }
      } else {
        print('[DEBUG] FilePicker result is null');
      }
    } catch (e) {
      print('[ERROR] Exception in _pickFile: $e');
      // Handle any errors during file picking
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting file: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Upload Button
        Container(
          width: double.infinity,
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.primaryTeal,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
            color: AppTheme.primaryTeal.withValues(alpha: 0.05),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _pickFile(context),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_upload,
                    color: AppTheme.primaryTeal,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    selectedFileName != null
                        ? 'Change Document'
                        : 'Upload Document',
                    style: const TextStyle(
                      color: AppTheme.primaryTeal,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Selected File Display
        if (selectedFileName != null) ...[
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.successGreen.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.description,
                    color: AppTheme.surfaceWhite,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedFileName!,
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Document uploaded successfully',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(color: AppTheme.successGreen),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.check_circle,
                  color: AppTheme.successGreen,
                  size: 24,
                ),
              ],
            ),
          ),
        ],

        // Help Text
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.info, color: AppTheme.textSecondary, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Accepted formats: PDF, DOC, DOCX (Max 10MB)',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
