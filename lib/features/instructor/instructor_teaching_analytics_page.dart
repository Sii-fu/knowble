import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class InstructorTeachingAnalyticsPage extends StatelessWidget {
  const InstructorTeachingAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teaching Analytics'),
          backgroundColor: AppTheme.surfaceWhite,
          foregroundColor: AppTheme.textPrimary,
          elevation: 0.5,
        ),
        backgroundColor: AppTheme.backgroundLight,
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Teaching Analytics',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAnalyticsCard(
                  icon: Icons.people,
                  title: 'Total Students',
                  value: '1,250',
                  color: Colors.blue[100]!,
                ),
                const SizedBox(height: 16),
                _buildAnalyticsCard(
                  icon: Icons.book,
                  title: 'Courses Published',
                  value: '8',
                  color: Colors.green[100]!,
                ),
                const SizedBox(height: 16),
                _buildAnalyticsCard(
                  icon: Icons.bar_chart,
                  title: 'Average Course Rating',
                  value: '4.7/5',
                  color: Colors.orange[100]!,
                ),
                const SizedBox(height: 16),
                _buildAnalyticsCard(
                  icon: Icons.access_time,
                  title: 'Total Teaching Hours',
                  value: '320h',
                  color: Colors.purple[100]!,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildActivityItem('Enrolled 20 new students in "Algebra I"'),
                _buildActivityItem('Received a 5-star review for "Biology Basics"'),
                _buildActivityItem('Published new course "Intro to Chemistry"'),
                _buildActivityItem('Answered 3 student questions'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: AppTheme.primaryTeal),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppTheme.primaryTeal, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
