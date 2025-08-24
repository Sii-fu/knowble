import 'package:flutter/material.dart';
import '../../core/services/student/generate_course_specific_quiz.dart';
import '../../config/theme.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  // 💾 Quiz data
  final String courseid = '9c341deb-5373-4a42-89df-867faa4f63d3';
  

  List<Map<String, dynamic>> quizData = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fetchQuizData();

  }

  Future<void> _fetchQuizData() async {
    try {
      // Replace 'yourCourseId' with the actual course ID or required argument
      final data = await QuizService().fetchQuizData(courseid);
      // print('Fetched quiz data: $data');
      setState(() {
        quizData = data;
        isLoading = false; // Set loading to false when data is loaded
      });
    } catch (e) {
      print('Error fetching quiz data: $e');
      setState(() {
        isLoading = false; // Set loading to false even on error
      });
    }
  }
  // 🔧 State management
  int currentQuestionIndex = 0;
  String? selectedOption;
  int score = 0;
  bool isAnswered = false;
  bool showFeedback = false;
  bool quizCompleted = false;
  bool isLoading = true; // Add loading state
  

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;


  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
    
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _selectOption(String option) {
    if (!isAnswered) {
      setState(() {
        selectedOption = option;
      });
    }
  }

  void _submitAnswer() {
    if (selectedOption == null) return;
    
    setState(() {
      isAnswered = true;
      showFeedback = true;
      
      // Check if answer is correct
      if (selectedOption == quizData[currentQuestionIndex]['answer']) {
        score++;
      }
    });

    // Auto-move to next question after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < quizData.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOption = null;
        isAnswered = false;
        showFeedback = false;
      });
      
      // Restart animations for next question
      _slideController.reset();
      _slideController.forward();
    } else {
      // Quiz completed
      setState(() {
        quizCompleted = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      selectedOption = null;
      score = 0;
      isAnswered = false;
      showFeedback = false;
      quizCompleted = false;
      isLoading = true; // Set loading when restarting
    });
    
    _slideController.reset();
    _slideController.forward();
    
    // Refetch quiz data
    _fetchQuizData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'Interactive Quiz',
          style: TextStyle(
            fontFamily: 'Jost',
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        backgroundColor: AppTheme.backgroundLight,
        foregroundColor: AppTheme.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading 
          ? _buildLoadingScreen()
          : quizData.isEmpty 
              ? _buildErrorScreen()
              : quizCompleted 
                  ? _buildCompletionScreen() 
                  : _buildQuizScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryTeal,
          ),
          SizedBox(height: 16),
          Text(
            'Loading Quiz...',
            style: TextStyle(
              fontFamily: 'Jost',
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 16),
            const Text(
              'No Quiz Available',
              style: TextStyle(
                fontFamily: 'Jost',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'There are no quiz questions available for this course.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Jost',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                });
                _fetchQuizData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                foregroundColor: AppTheme.surfaceWhite,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizScreen() {
    if (quizData.isEmpty) return _buildErrorScreen();
    
    final currentQuestion = quizData[currentQuestionIndex];
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress indicator
            _buildProgressIndicator(),
            
            const SizedBox(height: 30),
            
            // Question card
            SlideTransition(
              position: _slideAnimation,
              child: _buildQuestionCard(currentQuestion),
            ),
            
            const SizedBox(height: 30),
            
            // Options
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion['options'].length,
                itemBuilder: (context, index) {
                  final option = currentQuestion['options'][index];
                  return SlideTransition(
                    position: _slideAnimation,
                    child: _buildOptionCard(option, index),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Submit/Next button
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = (currentQuestionIndex + 1) / quizData.length;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1} of ${quizData.length}',
              style: const TextStyle(
                fontFamily: 'Jost',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              'Score: $score',
              style: const TextStyle(
                fontFamily: 'Jost',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.successGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.borderSubtle,
          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.quiz_rounded,
                color: AppTheme.primaryTeal,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Question',
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            question['question'],
            style: const TextStyle(
              fontFamily: 'Jost',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(String option, int index) {
    final currentQuestion = quizData[currentQuestionIndex];
    final correctAnswer = currentQuestion['answer'];
    final isSelected = selectedOption == option;
    final isCorrect = option == correctAnswer;
    
    Color cardColor = AppTheme.surfaceWhite;
    Color borderColor = AppTheme.borderSubtle;
    Color textColor = AppTheme.textPrimary;
    IconData? icon;
    
    if (showFeedback) {
      if (isCorrect) {
        cardColor = AppTheme.successGreen.withValues(alpha: 0.1);
        borderColor = AppTheme.successGreen;
        textColor = AppTheme.successGreen;
        icon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        cardColor = AppTheme.errorRed.withValues(alpha: 0.1);
        borderColor = AppTheme.errorRed;
        textColor = AppTheme.errorRed;
        icon = Icons.cancel;
      }
    } else if (isSelected) {
      cardColor = AppTheme.accentLight;
      borderColor = AppTheme.primaryTeal;
      textColor = AppTheme.primaryTeal;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _selectOption(option),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected || showFeedback ? borderColor : AppTheme.borderSubtle,
                    width: 2,
                  ),
                  color: isSelected || (showFeedback && isCorrect) ? borderColor : Colors.transparent,
                ),
                child: isSelected || (showFeedback && isCorrect)
                    ? const Icon(Icons.check, size: 16, color: AppTheme.surfaceWhite)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontFamily: 'Jost',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              if (showFeedback && icon != null)
                Icon(
                  icon,
                  color: borderColor,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    if (showFeedback) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.successGreen, AppTheme.successGreen.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_empty, color: AppTheme.surfaceWhite),
              SizedBox(width: 8),
              Text(
                'Moving to next question...',
                style: TextStyle(
                  fontFamily: 'Jost',
                  color: AppTheme.surfaceWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return ElevatedButton(
      onPressed: selectedOption != null ? _submitAnswer : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: AppTheme.surfaceWhite,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
      ),
      child: const Text(
        'Submit Answer',
        style: TextStyle(
          fontFamily: 'Jost',
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCompletionScreen() {
    final percentage = (score / quizData.length * 100).round();
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    percentage >= 70 ? Icons.celebration : Icons.psychology,
                    size: 80,
                    color: percentage >= 70 ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    percentage >= 70 ? 'Excellent!' : 'Good Effort!',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quiz Completed',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Final Score:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$score/${quizData.length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0EA5E9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Percentage:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: percentage >= 70 ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _restartQuiz,
                icon: const Icon(Icons.refresh),
                label: const Text(
                  'Restart Quiz',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0EA5E9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.home),
                label: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
