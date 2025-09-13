import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../data/models/assessment.dart';

class VideoQuizOverlay extends StatefulWidget {
  final Assessment assessment;
  final Function(bool passed) onCompleted;
  final VoidCallback onCancel;

  const VideoQuizOverlay({
    super.key,
    required this.assessment,
    required this.onCompleted,
    required this.onCancel,
  });

  @override
  State<VideoQuizOverlay> createState() => _VideoQuizOverlayState();
}

class _VideoQuizOverlayState extends State<VideoQuizOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  Map<String, String> _selectedAnswers = {};
  bool _isSubmitting = false;
  bool _showResults = false;
  bool _quizPassed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _submitQuiz() {
    setState(() {
      _isSubmitting = true;
    });

    // Simulate API call delay
    Future.delayed(const Duration(seconds: 1), () {
      // Calculate results (for demo purposes, we'll say passed if any answer is selected)
      final hasAnswers = _selectedAnswers.isNotEmpty;
      
      setState(() {
        _isSubmitting = false;
        _showResults = true;
        _quizPassed = hasAnswers; // Simple logic for demo
      });

      // Auto-close after showing results
      Future.delayed(const Duration(seconds: 2), () {
        _closeQuiz();
      });
    });
  }

  void _closeQuiz() {
    _animationController.reverse().then((_) {
      widget.onCompleted(_quizPassed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Background overlay
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                color: AppTheme.textPrimary.withValues(alpha: 0.7),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            
            // Quiz content
            SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowLight,
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _showResults ? _buildResults() : _buildQuizContent(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuizContent() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.primaryTeal,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.quiz,
                  color: AppTheme.surfaceWhite,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.assessment.title.isNotEmpty 
                        ? widget.assessment.title 
                        : 'Quick Quiz',
                    style: TextStyle(
                      color: AppTheme.surfaceWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Jost',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _animationController.reverse().then((_) {
                      widget.onCancel();
                    });
                  },
                  icon: Icon(
                    Icons.close,
                    color: AppTheme.surfaceWhite,
                  ),
                ),
              ],
            ),
          ),
          
          // Quiz content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Test your understanding of this lesson',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      fontFamily: 'Jost',
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Demo question (since Assessment model might not have questions)
                  _buildDemoQuestion(),
                  
                  const SizedBox(height: 24),
                  
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedAnswers.isNotEmpty && !_isSubmitting
                          ? _submitQuiz
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        foregroundColor: AppTheme.surfaceWhite,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppTheme.surfaceWhite,
                                ),
                              ),
                            )
                          : Text(
                              'Submit Quiz',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Jost',
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoQuestion() {
    const question = 'What is the main concept covered in this video lesson?';
    const options = [
      'Basic fundamentals',
      'Advanced topics',
      'Practical applications',
      'Theory and concepts',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
            fontFamily: 'Jost',
          ),
        ),
        const SizedBox(height: 16),
        
        ...options.asMap().entries.map((entry) {
          final option = entry.value;
          final isSelected = _selectedAnswers['q1'] == option;
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedAnswers['q1'] = option;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryTeal
                        : AppTheme.borderSubtle,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected
                      ? AppTheme.primaryTeal.withOpacity(0.1)
                      : AppTheme.backgroundLight,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primaryTeal
                              : AppTheme.textSecondary,
                          width: 2,
                        ),
                        color: isSelected
                            ? AppTheme.primaryTeal
                            : Colors.transparent,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 12,
                              color: AppTheme.surfaceWhite,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontFamily: 'Jost',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildResults() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _quizPassed ? Icons.check_circle : Icons.cancel,
            size: 64,
            color: _quizPassed ? AppTheme.successGreen : AppTheme.errorRed,
          ),
          const SizedBox(height: 16),
          Text(
            _quizPassed ? 'Great Job!' : 'Try Again',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _quizPassed ? AppTheme.successGreen : AppTheme.errorRed,
              fontFamily: 'Jost',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _quizPassed
                ? 'You can continue with the video'
                : 'Review the content and try again',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
              fontFamily: 'Jost',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}