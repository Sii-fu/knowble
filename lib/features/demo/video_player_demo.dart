import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../student/video_player_page.dart';

class VideoPlayerDemo extends StatelessWidget {
  const VideoPlayerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Video Player Demo'),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: AppTheme.surfaceWhite,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'YouTube Video Player Demo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Test the new video player with YouTube videos. Features include:',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Features list
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFeatureItem('▶️ YouTube video playback'),
                _buildFeatureItem('🎛️ Custom video controls'),
                _buildFeatureItem('⏩ Playback speed control'),
                _buildFeatureItem('📺 Fullscreen support'),
                _buildFeatureItem('❓ Quiz integration'),
                _buildFeatureItem('🤖 AI Assistant integration'),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Sample video buttons
            Text(
              'Sample Videos:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Sample video cards
            _buildVideoCard(
              context,
              'Flutter Basics Tutorial',
              'https://www.youtube.com/watch?v=1ukSR1GRtMU',
              'Learn Flutter basics in this comprehensive tutorial',
            ),
            const SizedBox(height: 12),
            _buildVideoCard(
              context,
              'Dart Programming Introduction',
              'https://www.youtube.com/watch?v=Ej_Pcr4uC2Q',
              'Introduction to Dart programming language',
            ),
            const SizedBox(height: 12),
            _buildVideoCard(
              context,
              'Widget Deep Dive',
              'https://www.youtube.com/watch?v=wE7khGHVkYY',
              'Understanding Flutter widgets in detail',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppTheme.primaryTeal,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            feature,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, String title, String url, String description) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerPage(
                videoUrl: url,
                title: title,
                contentId: 'demo_${DateTime.now().millisecondsSinceEpoch}',
                courseId: 'demo_course',
                sectionId: 'demo_section',
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.play_circle_fill,
                  color: AppTheme.primaryTeal,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}