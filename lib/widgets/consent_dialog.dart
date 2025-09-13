import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Reusable consent dialog for document submission
class ConsentDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onAccept;
  final VoidCallback? onDecline;

  const ConsentDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onAccept,
    this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: AppTheme.primaryTeal,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontFamily: 'Jost',
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Content
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
                fontFamily: 'Jost',
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                if (onDecline != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.borderSubtle),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Decline',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontFamily: 'Jost',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: AppTheme.surfaceWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'I Consent',
                      style: TextStyle(
                        color: AppTheme.surfaceWhite,
                        fontFamily: 'Jost',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show document submission consent dialog
  static Future<bool> showDocumentConsentDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ConsentDialog(
          title: 'Document Submission Consent',
          content: 'By submitting your document for verification, you consent to:\n\n'
              '• Sharing your personal information with our administrative team\n'
              '• Using your documents solely for verification purposes within the app\n'
              '• Storing your information securely for administrative purposes\n\n'
              'Your information will not be shared with third parties outside of our verification process.',
          onAccept: () => Navigator.of(context).pop(true),
          onDecline: () => Navigator.of(context).pop(false),
        );
      },
    ) ?? false;
  }
}
