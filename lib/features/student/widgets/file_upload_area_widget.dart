import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../config/theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class FileUploadAreaWidget extends StatelessWidget {
  final PlatformFile? selectedFile;
  final Function(PlatformFile?) onFileSelected;
  final bool isUploading;

  const FileUploadAreaWidget({
    Key? key,
    required this.selectedFile,
    required this.onFileSelected,
    this.isUploading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: selectedFile != null
          ? _buildSelectedFileDisplay()
          : _buildUploadArea(context),
    );
  }

  Widget _buildUploadArea(BuildContext context) {
    return GestureDetector(
      onTap: isUploading ? null : () => _selectFile(context),
      child: DottedBorder(
        color: AppTheme.primaryTeal,
        strokeWidth: 2.0,
        dashPattern: [8, 4],
        borderType: BorderType.RRect,
        radius: Radius.circular(12.0),
        child: Container(
          width: double.infinity,
          height: 25.h,
          decoration: BoxDecoration(
            color: AppTheme.primaryTeal.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'cloud_upload',
                color: AppTheme.primaryTeal,
                size: 12.w,
              ),
              SizedBox(height: 2.h),
              Text(
                'Tap to select document',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryTeal,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'PDF, JPG, PNG • Max 10MB',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedFileDisplay() {
    final fileSize = _formatFileSize(selectedFile!.size);
    final isImage = _isImageFile(selectedFile!.extension);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppTheme.successGreen, width: 2.0),
      ),
      child: Row(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: AppTheme.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: isImage && selectedFile!.bytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.memory(
                      selectedFile!.bytes!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: CustomIconWidget(
                      iconName: selectedFile!.extension == 'pdf'
                          ? 'picture_as_pdf'
                          : 'insert_drive_file',
                      color: AppTheme.successGreen,
                      size: 6.w,
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
                  fileSize,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: isUploading ? null : () => onFileSelected(null),
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'close',
                color: AppTheme.errorRed,
                size: 4.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Check file size (10MB limit)
        if (file.size > 10 * 1024 * 1024) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('File size must be less than 10MB'),
              backgroundColor: AppTheme.errorRed,
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
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool _isImageFile(String? extension) {
    if (extension == null) return false;
    return ['jpg', 'jpeg', 'png'].contains(extension.toLowerCase());
  }
}
