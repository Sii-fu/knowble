import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../config/theme.dart';
import '../../core/services/student/course_services.dart';
import '../../data/models/assessment.dart';
import 'chatbot/chatbotpage.dart';
import 'quiz/video_quiz_overlay.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String contentId;
  final String? courseId;
  final String? sectionId;

  const VideoPlayerPage({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.contentId,
    this.courseId,
    this.sectionId,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _isFullScreen = false;
  bool _isLoading = true;
  String? _errorMsg;
  
  // Quiz integration
  List<Assessment> _assessments = [];
  bool _showQuiz = false;
  Assessment? _currentQuiz;
  
  // Progress tracking
  Duration _videoDuration = Duration.zero;
  Duration _currentPosition = Duration.zero;
  bool _hasStartedWatching = false;
  
  final CourseServices _courseServices = CourseServices();

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _loadQuizzes();
  }

  void _initializePlayer() {
    try {
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      if (videoId == null) {
        setState(() {
          _errorMsg = 'Invalid YouTube URL';
          _isLoading = false;
        });
        return;
      }

      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          captionLanguage: 'en',
          showLiveFullscreenButton: true,
        ),
      );

      _controller.addListener(_playerListener);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMsg = 'Error loading video: $e';
        _isLoading = false;
      });
    }
  }

  void _playerListener() {
    if (_controller.value.isReady && !_isPlayerReady) {
      setState(() {
        _isPlayerReady = true;
        _videoDuration = _controller.metadata.duration;
      });
    }

    if (_controller.value.isPlaying && !_hasStartedWatching) {
      setState(() {
        _hasStartedWatching = true;
      });
    }

    // Update current position
    setState(() {
      _currentPosition = _controller.value.position;
    });

    // Check for quiz trigger points (every 25% of video)
    if (_assessments.isNotEmpty && _controller.value.isPlaying) {
      final progress = _currentPosition.inSeconds / _videoDuration.inSeconds;
      _checkQuizTrigger(progress);
    }

    // Handle fullscreen changes
    if (_controller.value.isFullScreen != _isFullScreen) {
      setState(() {
        _isFullScreen = _controller.value.isFullScreen;
      });
    }
  }

  Future<void> _loadQuizzes() async {
    if (widget.sectionId == null) return;
    
    try {
      final assessments = await _courseServices.fetchAssessments(widget.sectionId!);
      setState(() {
        _assessments = assessments;
      });
    } catch (e) {
      print('Error loading quizzes: $e');
    }
  }

  void _checkQuizTrigger(double progress) {
    // Trigger quiz at 25%, 50%, 75% progress
    if (!_showQuiz && _assessments.isNotEmpty) {
      if (progress >= 0.25 && progress <= 0.26) {
        _triggerQuiz(_assessments.first);
      } else if (progress >= 0.50 && progress <= 0.51) {
        _triggerQuiz(_assessments.first);
      } else if (progress >= 0.75 && progress <= 0.76) {
        _triggerQuiz(_assessments.first);
      }
    }
  }

  void _triggerQuiz(Assessment assessment) {
    if (_controller.value.isPlaying) {
      _controller.pause();
    }
    
    setState(() {
      _showQuiz = true;
      _currentQuiz = assessment;
    });
  }

  void _onQuizCompleted(bool passed) {
    setState(() {
      _showQuiz = false;
      _currentQuiz = null;
    });
    
    if (passed) {
      // Resume video
      _controller.play();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quiz completed successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please try the quiz again'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _togglePlayPause() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  void _seekToPosition(Duration position) {
    _controller.seekTo(position);
  }

  void _changePlaybackSpeed(double speed) {
    _controller.setPlaybackRate(speed);
  }

  void _toggleFullScreen() {
    if (_isFullScreen) {
      _controller.toggleFullScreenMode();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      _controller.toggleFullScreenMode();
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _openChatBot() {
    if (widget.courseId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatBotPage(
            courseId: widget.courseId!,
            contentId: widget.contentId,
          ),
        ),
      );
    }
  }

  void _showQuizManually() {
    if (_assessments.isNotEmpty) {
      _triggerQuiz(_assessments.first);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No quizzes available for this video'),
        ),
      );
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_playerListener);
    _controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppTheme.backgroundLight,
          foregroundColor: AppTheme.textPrimary,
          title: Text(widget.title),
          elevation: 0,
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryTeal,
          ),
        ),
      );
    }

    if (_errorMsg != null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppTheme.textPrimary,
          foregroundColor: AppTheme.textPrimary,
          title: Text(widget.title),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorRed,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMsg!,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.backgroundDark,
                  foregroundColor: AppTheme.backgroundDark,
                ),  
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: _isFullScreen ? null : AppBar(
        backgroundColor: AppTheme.backgroundLight,
        foregroundColor: AppTheme.textPrimary,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _openChatBot,
            icon: Icon(Icons.smart_toy, color: AppTheme.primaryTeal),
            tooltip: 'AI Assistant',
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Video Player
              Container(
                color: Colors.black, // Keep black for video player background
                child: YoutubePlayerBuilder(
                  player: YoutubePlayer(
                    controller: _controller,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: AppTheme.primaryTeal,
                    progressColors: ProgressBarColors(
                      playedColor: AppTheme.primaryTeal,
                      handleColor: AppTheme.primaryTeal,
                      bufferedColor: AppTheme.primaryTeal.withValues(alpha: 0.3),
                      backgroundColor: AppTheme.borderSubtle,
                    ),
                    onReady: () {
                      setState(() {
                        _isPlayerReady = true;
                      });
                    },
                  ),
                  builder: (context, player) => player,
                ),
              ),
              
              // Custom Controls (when not in fullscreen)
              if (!_isFullScreen) ...[
                _buildVideoControls(),
                _buildVideoInfo(),
                _buildActionButtons(),
              ],
            ],
          ),
          
          // Quiz Overlay
          if (_showQuiz && _currentQuiz != null)
            VideoQuizOverlay(
              assessment: _currentQuiz!,
              onCompleted: _onQuizCompleted,
              onCancel: () {
                setState(() {
                  _showQuiz = false;
                  _currentQuiz = null;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        border: Border(
          top: BorderSide(color: AppTheme.borderSubtle, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              Text(
                _formatDuration(_currentPosition),
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  value: _videoDuration.inSeconds > 0 
                      ? _currentPosition.inSeconds / _videoDuration.inSeconds 
                      : 0.0,
                  activeColor: AppTheme.primaryTeal,
                  inactiveColor: AppTheme.borderSubtle,
                  onChanged: (value) {
                    final position = Duration(
                      seconds: (value * _videoDuration.inSeconds).round(),
                    );
                    _seekToPosition(position);
                  },
                ),
              ),
              Text(
                _formatDuration(_videoDuration),
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              ),
            ],
          ),
          
          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Rewind 10s
              IconButton(
                onPressed: () {
                  final newPosition = _currentPosition - const Duration(seconds: 10);
                  _seekToPosition(newPosition.isNegative ? Duration.zero : newPosition);
                },
                icon: Icon(Icons.replay_10, color: AppTheme.textSecondary),
                tooltip: 'Rewind 10 seconds',
              ),
              
              // Play/Pause
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: AppTheme.surfaceWhite,
                    size: 32,
                  ),
                  tooltip: _controller.value.isPlaying ? 'Pause' : 'Play',
                ),
              ),
              
              // Forward 10s
              IconButton(
                onPressed: () {
                  final newPosition = _currentPosition + const Duration(seconds: 10);
                  _seekToPosition(newPosition > _videoDuration ? _videoDuration : newPosition);
                },
                icon: Icon(Icons.forward_10, color: AppTheme.textSecondary),
                tooltip: 'Forward 10 seconds',
              ),
              
              // Speed control
              PopupMenuButton<double>(
                icon: Icon(Icons.speed, color: AppTheme.textSecondary),
                tooltip: 'Playback speed',
                onSelected: _changePlaybackSpeed,
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0.25, child: Text('0.25x')),
                  const PopupMenuItem(value: 0.5, child: Text('0.5x')),
                  const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                  const PopupMenuItem(value: 1.0, child: Text('1x (Normal)')),
                  const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                  const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                  const PopupMenuItem(value: 2.0, child: Text('2x')),
                ],
              ),
              
              // Fullscreen
              IconButton(
                onPressed: _toggleFullScreen,
                icon: Icon(Icons.fullscreen, color: AppTheme.textSecondary),
                tooltip: 'Fullscreen',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              fontFamily: 'Jost',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${_formatDuration(_videoDuration)} • Video Lesson',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontFamily: 'Jost',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.backgroundLight,
      child: Row(
        children: [
          // Take Quiz button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _showQuizManually,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: AppTheme.surfaceWhite,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.quiz),
              label: Text(
                'Take Quiz',
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // AI Assistant button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _openChatBot,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentPurple,
                foregroundColor: AppTheme.surfaceWhite,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              icon: const Icon(Icons.smart_toy),
              label: Text(
                'AI Assistant',
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}