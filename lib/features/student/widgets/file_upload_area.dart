import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../config/theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class FileUploadArea extends StatelessWidget {
  final PlatformFile? selectedFile;
  final Function(PlatformFile?) onFileSelected;
  final bool isLoading;

  const FileUploadArea({
    Key? key,
    required this.selectedFile,
    required this.onFileSelected,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: selectedFile != null
          ? _buildSelectedFileDisplay(context)
          : _buildUploadArea(context),
    );
  }

  Widget _buildUploadArea(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : () => _pickFile(context),
      child: DottedBorder(
        color: AppTheme.lightTheme.colorScheme.primary,
        strokeWidth: 2.0,
        dashPattern: [8, 4],
        borderType: BorderType.RRect,
        radius: Radius.circular(12.0),
        child: Container(
          width: double.infinity,
          height: 25.h,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.primaryContainer.withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading) ...[
                CircularProgressIndicator(
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Processing file...',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ] else ...[
                CustomIconWidget(
                  iconName: 'cloud_upload',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 12.w,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Tap to upload document',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Drag and drop or browse files',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Supports PDF, JPG, PNG (Max 10MB)',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFileDisplay(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary,
          width: 2.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: _getFileIcon(selectedFile!.extension ?? ''),
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 8.w,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedFile!.name,
                  style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 0.5.h),
                Text(
                  _formatFileSize(selectedFile!.size),
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onFileSelected(null),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 5.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Check file size (10MB limit)
        if (file.size > 10 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File size must be under 10MB'),
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
          );
          return;
        }

        onFileSelected(file);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting file. Please try again.'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  String _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'picture_as_pdf';
      case 'jpg':
      case 'jpeg':
      case 'png':
        return 'image';
      default:
        return 'description';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '\$bytes B';
    if (bytes < 1024 * 1024) return '\${(bytes / 1024).toStringAsFixed(1)} KB';
    return '\${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
