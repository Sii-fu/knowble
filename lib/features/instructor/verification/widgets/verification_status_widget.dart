import 'package:flutter/material.dart';
import '../../../../../config/theme.dart';

class VerificationStatusWidget extends StatelessWidget {
  final String status;
  final String submissionDate;
  final String estimatedCompletion;
  final AnimationController progressController;

  const VerificationStatusWidget({
    super.key,
    required this.status,
    required this.submissionDate,
    required this.estimatedCompletion,
    required this.progressController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Status Icon with Animation
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryTeal.withValues(alpha: 0.1),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated Progress Ring
                RotationTransition(
                  turns: progressController,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: CustomPaint(
                      painter: _ProgressRingPainter(
                        color: AppTheme.primaryTeal,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
                // Center Icon
                Icon(_getStatusIcon(), color: AppTheme.primaryTeal, size: 32),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Status Title
          Text(
            _getStatusTitle(),
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Status Description
          Text(
            _getStatusDescription(),
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Timeline Information
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildTimelineItem(
                  'Submitted',
                  _formatDate(submissionDate),
                  Icons.check_circle,
                  AppTheme.successGreen,
                ),
                const SizedBox(height: 16),
                _buildTimelineItem(
                  'Expected Completion',
                  _formatDate(estimatedCompletion),
                  Icons.schedule,
                  AppTheme.warningAmber,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String label,
    String date,
    IconData iconData,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(iconData, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                date,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon() {
    switch (status) {
      case 'under_review':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.pending;
    }
  }

  String _getStatusTitle() {
    switch (status) {
      case 'under_review':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Needs Attention';
      default:
        return 'Pending';
    }
  }

  String _getStatusDescription() {
    switch (status) {
      case 'under_review':
        return 'Your profile is being reviewed by our verification team. This typically takes 2-3 business days.';
      case 'approved':
        return 'Congratulations! Your profile has been approved and you can now access all teacher features.';
      case 'rejected':
        return 'Some documents need to be updated. Please check the details below and resubmit.';
      default:
        return 'Your verification is in progress.';
    }
  }

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      final List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

class _ProgressRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _ProgressRingPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double radius = (size.width - strokeWidth) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Draw partial arc (75% of circle)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // Start from top (-90 degrees in radians)
      4.7124, // 75% of circle (270 degrees in radians)
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
