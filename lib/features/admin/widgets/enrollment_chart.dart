import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:Knowble/config/theme.dart';

class EnrollmentChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;
  final bool isLoading;

  const EnrollmentChart({
    super.key,
    required this.chartData,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (chartData.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
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
          // Chart Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enrollments (Last 30 Days)',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_getTotalEnrollments()} Total',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Simple Line Chart
          SizedBox(height: 25.h, child: _buildSimpleLineChart()),

          SizedBox(height: 2.h),

          // Chart Legend/Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Peak Day',
                '${_getMaxEnrollments()}',
                AppTheme.successGreen,
              ),
              _buildStatItem(
                'Average',
                '${_getAverageEnrollments()}',
                AppTheme.primaryTeal,
              ),
              _buildStatItem(
                'Recent',
                '${_getRecentEnrollments()}',
                AppTheme.errorRed,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 35.h,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryTeal,
            strokeWidth: 3,
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading enrollment data...',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 35.h,
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 48,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: 2.h),
          Text(
            'No enrollment data available',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Chart will appear when students enroll in courses',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleLineChart() {
    final maxValue = _getMaxEnrollments().toDouble();

    return CustomPaint(
      size: Size(double.infinity, 25.h),
      painter: LineChartPainter(
        chartData: chartData,
        maxValue: maxValue > 0 ? maxValue : 1,
        primaryColor: AppTheme.primaryTeal,
        backgroundColor: AppTheme.backgroundLight,
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  int _getTotalEnrollments() {
    return chartData.fold(
      0,
      (sum, item) => sum + (item['enrollments'] as int? ?? 0),
    );
  }

  int _getMaxEnrollments() {
    if (chartData.isEmpty) return 0;
    return chartData
        .map((item) => item['enrollments'] as int? ?? 0)
        .reduce((a, b) => a > b ? a : b);
  }

  int _getAverageEnrollments() {
    if (chartData.isEmpty) return 0;
    return (_getTotalEnrollments() / chartData.length).round();
  }

  int _getRecentEnrollments() {
    if (chartData.isEmpty) return 0;
    // Get enrollments from last 3 days
    final recentData = chartData.length >= 3
        ? chartData.sublist(chartData.length - 3)
        : chartData;
    return recentData.fold(
      0,
      (sum, item) => sum + (item['enrollments'] as int? ?? 0),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> chartData;
  final double maxValue;
  final Color primaryColor;
  final Color backgroundColor;

  LineChartPainter({
    required this.chartData,
    required this.maxValue,
    required this.primaryColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (chartData.isEmpty) return;

    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = primaryColor.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    // Draw grid lines
    final gridLines = 5;
    for (int i = 0; i <= gridLines; i++) {
      final y = (size.height / gridLines) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Calculate points
    final points = <Offset>[];
    final fillPoints = <Offset>[Offset(0, size.height)];

    for (int i = 0; i < chartData.length; i++) {
      final x = (size.width / (chartData.length - 1)) * i;
      final enrollments = (chartData[i]['enrollments'] as int? ?? 0).toDouble();
      final y = size.height - (enrollments / maxValue) * size.height;

      points.add(Offset(x, y));
      fillPoints.add(Offset(x, y));
    }

    fillPoints.add(Offset(size.width, size.height));

    // Draw filled area
    final fillPath = Path();
    fillPath.addPolygon(fillPoints, true);
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);

      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }

      canvas.drawPath(path, paint);
    }

    // Draw points
    final pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
      canvas.drawCircle(
        point,
        4,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(point, 2, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
