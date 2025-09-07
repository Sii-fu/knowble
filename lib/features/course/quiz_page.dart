
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/student/generate_course_specific_quiz.dart';
import '../../core/services/student/quiz_submission_service.dart';
import '../../core/services/student/quiz_result_service.dart';
import '../../config/theme.dart';

class QuizPage extends StatefulWidget {
  final String sectionId;
  const QuizPage({super.key, required this.sectionId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  Future<void> updateEnrollmentProgress(String userId) async {
    // Get moduleId from sectionId
    print('Fetching section for sectionId: ${widget.sectionId}');
    final sectionRes = await Supabase.instance.client
        .from('sections')
        .select('id, module_id')
        .eq('id', widget.sectionId)
        .maybeSingle();
    print('Section result:');
    print(sectionRes);
    if (sectionRes == null) {
      print('No section found for sectionId: ${widget.sectionId}');
      return;
    }
    final moduleId = sectionRes['module_id'] as String;
    print('Fetched moduleId: $moduleId');

    // Get courseId from moduleId
    print('Fetching module for moduleId: $moduleId');
    final moduleRes = await Supabase.instance.client
        .from('modules')
        .select('id, course_id')
        .eq('id', moduleId)
        .maybeSingle();
    print('Module result:');
    print(moduleRes);
    if (moduleRes == null) {
      print('No module found for moduleId: $moduleId');
      return;
    }
    final courseId = moduleRes['course_id'] as String;
    print('Fetched courseId: $courseId');

  // Get all module IDs for this course
  print('Fetching modules for courseId: $courseId');
  final allModulesRes = await Supabase.instance.client
    .from('modules')
    .select('id')
    .eq('course_id', courseId);
  print('All modules for courseId $courseId:');
  print(allModulesRes);
  final moduleIds = (allModulesRes as List).map((m) => m['id'] as String).toList();

  // Get all section IDs for these modules
  print('Fetching sections for moduleIds: $moduleIds');
  final allSectionsRes = await Supabase.instance.client
    .from('sections')
    .select('id')
    .inFilter('module_id', moduleIds);
  print('All sections for moduleIds $moduleIds:');
  print(allSectionsRes);
  final sectionIds = (allSectionsRes as List).map((s) => s['id'] as String).toList();

    // Get all assessments for these sections
    final assessmentsRes = await Supabase.instance.client
        .from('assessments')
        .select('id, section_id')
        .eq('type', 'quiz')
        .inFilter('section_id', sectionIds);
    print('Assessments for sectionIds:');
    print(assessmentsRes);
    final assessmentIds = (assessmentsRes as List).map((a) => a['id'] as String).toList();
    final totalAssessments = assessmentIds.length;

    // Get passed assessments for this user
    final passedRes = await Supabase.instance.client
        .from('quiz_results')
        .select('assessment_id, status')
        .eq('student_id', userId)
        .inFilter('assessment_id', assessmentIds);
    print('Passed quiz results for user $userId:');
    print(passedRes);
    final passedCount = (passedRes as List)
        .where((r) => r['status'] == 'pass')
        .length;

    final progress = totalAssessments > 0 ? (passedCount / totalAssessments) * 100.0 : 0.0;
    print('Calculated progress: $progress');

    // Update enrollment progress
    final enrollmentRes = await Supabase.instance.client
        .from('enrollments')
        .select('id')
        .eq('student_id', userId)
        .eq('course_id', courseId)
        .maybeSingle();
    print('Enrollment result:');
    print(enrollmentRes);
    if (enrollmentRes == null) {
      print('No enrollment found for userId: $userId and courseId: $courseId');
      return;
    }
    final enrollmentId = enrollmentRes['id'] as String;
    final updateRes = await Supabase.instance.client
        .from('enrollments')
        .update({'progress': progress})
        .eq('id', enrollmentId);
    print('Update response:');
    print(updateRes);
  }
  final QuizSubmissionService _submissionService = QuizSubmissionService();

  List<Map<String, dynamic>> quizData = [];
  int currentQuestionIndex = 0;
  String? selectedOptionId;
  int score = 0;
  bool isAnswered = false;
  bool showFeedback = false;
  bool quizCompleted = false;
  bool isLoading = true;

  // Animations
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _fetchQuizData();
  }

  Future<void> _fetchQuizData() async {
    try {
      final data = await QuizService().fetchQuizData(widget.sectionId);
      // Ensure each question's options are List<Map<String, dynamic>>
      final normalizedData = (data as List).map<Map<String, dynamic>>((q) {
        final options = (q['options'] as List).map<Map<String, dynamic>>((opt) {
          if (opt is Map<String, dynamic>) {
            return opt;
          } else {
            return {'id': opt, 'text': opt};
          }
        }).toList();
        return {
          ...q,
          'options': options,
        };
      }).toList();
      setState(() {
        quizData = normalizedData;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error fetching quiz data: $e');
      setState(() => isLoading = false);
    }
  }

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
      setState(() => selectedOptionId = option);
    }
  }

  Future<void> _submitAnswer() async {
    if (selectedOptionId == null) return;

    final currentQuestion = quizData[currentQuestionIndex];
    final isCorrect = selectedOptionId == currentQuestion['answer_id'];
    final marks = isCorrect ? 1 : 0;

    setState(() {
      isAnswered = true;
      showFeedback = true;
      if (isCorrect) score++;
    });

    // Save submission
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    try {
      await _submissionService.submitAnswer(
        studentId: userId,
        questionId: currentQuestion['id'],
        selectedOptionIds: [selectedOptionId!],
        isCorrect: isCorrect,
        marksAwarded: marks,
      );
    } catch (e) {
      print("❌ Failed to save submission: $e");
    }

    Future.delayed(const Duration(seconds: 2), () => _nextQuestion());
  }

  void _nextQuestion() {
    if (currentQuestionIndex < quizData.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedOptionId = null;
        isAnswered = false;
        showFeedback = false;
      });
      _slideController.reset();
      _slideController.forward();
    } else {
      // Quiz finished, save result
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final sectionId = widget.sectionId;
      final assessmentId = quizData.isNotEmpty ? quizData[0]['assessment_id'] ?? '' : '';
      final percentage = (score / quizData.length * 100).round();
      final status = percentage >= 60 ? 'pass' : 'fail';
      final resultService = QuizResultService();
      resultService.saveQuizResult(
        studentId: userId,
        assessmentId: assessmentId,
        sectionId: sectionId,
        status: status,
        score: score,
      );
      if (status == 'pass') {
        updateEnrollmentProgress(userId);
      }
      setState(() => quizCompleted = true);
    }
  }

  void _restartQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      selectedOptionId = null;
      score = 0;
      isAnswered = false;
      showFeedback = false;
      quizCompleted = false;
      isLoading = true;
    });
    _slideController.reset();
    _slideController.forward();
    _fetchQuizData();
  }

  // ---------------- NEW: update progress if passed ----------------
  Future<void> _incrementProgress() async {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    if (userId.isEmpty) return;

    try {
      final enrollmentRes = await Supabase.instance.client
          .from('enrollments')
          .select()
          .eq('student_id', userId)
          .eq('course_id', widget.sectionId) // ⚠️ replace with real courseId if different
          .maybeSingle();

      if (enrollmentRes == null) return;

      final enrollmentId = enrollmentRes['id'] as String;
      final currentProgress = (enrollmentRes['progress'] as num).toDouble();
      final newProgress = (currentProgress + 1.0).clamp(0.0, 100.0);

      await Supabase.instance.client
          .from('enrollments')
          .update({'progress': newProgress})
          .eq('id', enrollmentId);
    } catch (e) {
      print("❌ Failed to update progress: $e");
    }
  }

  // ---------------- UI Builders ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('Section Quiz',
            style: TextStyle(
                fontFamily: 'Jost',
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
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

  Widget _buildLoadingScreen() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.primaryTeal),
            SizedBox(height: 16),
            Text('Loading Quiz...',
                style: TextStyle(
                  fontFamily: 'Jost',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                )),
          ],
        ),
      );

  Widget _buildErrorScreen() => Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 64, color: AppTheme.errorRed),
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
                'There are no quiz questions available for this section yet.',
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
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryTeal,
                  foregroundColor: AppTheme.surfaceWhite,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Lessons',
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

  Widget _buildQuizScreen() {
    final currentQuestion = quizData[currentQuestionIndex];
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildProgressIndicator(),
            const SizedBox(height: 30),
            SlideTransition(
              position: _slideAnimation,
              child: _buildQuestionCard(currentQuestion),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: currentQuestion['options'].length,
                itemBuilder: (context, index) {
                  final option = currentQuestion['options'][index];
                  return SlideTransition(
                    position: _slideAnimation,
                    child: _buildOptionCard(
                        option as Map<String, dynamic>, index),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
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
          valueColor:
              const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) => Container(
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
                Icon(Icons.quiz_rounded,
                    color: AppTheme.primaryTeal, size: 24),
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

  Widget _buildOptionCard(Map<String, dynamic> option, int index) {
    final currentQuestion = quizData[currentQuestionIndex];
    final optionId = option['id'];
    final optionText = option['text'];
    final correctAnswerId = currentQuestion['answer_id'];
    final isSelected = selectedOptionId == optionId;
    final isCorrect = optionId == correctAnswerId;

    Color cardColor = AppTheme.surfaceWhite;
    Color borderColor = AppTheme.borderSubtle;
    Color textColor = AppTheme.textPrimary;
    IconData? icon;

    if (showFeedback) {
      if (isCorrect) {
        cardColor = AppTheme.successGreen.withOpacity(0.1);
        borderColor = AppTheme.successGreen;
        textColor = AppTheme.successGreen;
        icon = Icons.check_circle;
      } else if (isSelected && !isCorrect) {
        cardColor = AppTheme.errorRed.withOpacity(0.1);
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
        onTap: () => _selectOption(optionId),
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
                    color: isSelected || showFeedback
                        ? borderColor
                        : AppTheme.borderSubtle,
                    width: 2,
                  ),
                  color: isSelected || (showFeedback && isCorrect)
                      ? borderColor
                      : Colors.transparent,
                ),
                child: isSelected || (showFeedback && isCorrect)
                    ? const Icon(Icons.check,
                        size: 16, color: AppTheme.surfaceWhite)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  optionText,
                  style: TextStyle(
                    fontFamily: 'Jost',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              if (showFeedback && icon != null)
                Icon(icon, color: borderColor, size: 24),
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
            colors: [
              AppTheme.successGreen,
              AppTheme.successGreen.withOpacity(0.8)
            ],
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
      onPressed: selectedOptionId != null ? _submitAnswer : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: AppTheme.surfaceWhite,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    final passed = percentage >= 60;

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
                    passed ? Icons.celebration : Icons.psychology,
                    size: 80,
                    color: passed
                        ? const Color(0xFF22C55E)
                        : const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    passed ? 'Great Job!' : 'Try Again!',
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
                                color: passed
                                    ? const Color(0xFF22C55E)
                                    : const Color(0xFFF59E0B),
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

            // ---------- BUTTONS ----------
            if (passed)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await _incrementProgress();
                    Navigator.pop(context); // back to lessons
                  },
                  icon: const Icon(Icons.check_circle),
                  label: const Text(
                    'Mark as Completed',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _restartQuiz,
                  icon: const Icon(Icons.refresh),
                  label: const Text(
                    'Retry Quiz',
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
                        borderRadius: BorderRadius.circular(12)),
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
                  'Back to Course',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF64748B),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
