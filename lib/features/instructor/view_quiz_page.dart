import 'package:flutter/material.dart';
import '../../../config/theme_instructor.dart';
import '../../../core/services/instructor/quiz_services.dart';

class ViewQuizPage extends StatefulWidget {
  final String sectionId;
  final String lessonTitle;

  const ViewQuizPage({
    super.key,
    required this.sectionId,
    required this.lessonTitle,
  });

  @override
  State<ViewQuizPage> createState() => _ViewQuizPageState();
}

class _ViewQuizPageState extends State<ViewQuizPage> {
  final QuizService _quizService = QuizService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _assessments = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchQuizData();
  }

  Future<void> _fetchQuizData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final assessments = await _quizService.fetchCompleteQuizData(widget.sectionId);
      setState(() {
        _assessments = assessments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppThemeInstructor.lightTheme,
      child: Scaffold(
        backgroundColor: AppThemeInstructor.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppThemeInstructor.backgroundLight,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppThemeInstructor.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.lessonTitle,
            style: TextStyle(
              color: AppThemeInstructor.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppThemeInstructor.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading quizzes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppThemeInstructor.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: AppThemeInstructor.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchQuizData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeInstructor.primaryBlue,
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_assessments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.quiz_outlined,
              size: 64,
              color: AppThemeInstructor.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Quizzes Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppThemeInstructor.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no quizzes available for this lesson.',
              style: TextStyle(
                fontSize: 14,
                color: AppThemeInstructor.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchQuizData,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _assessments.length,
        itemBuilder: (context, index) {
          final assessment = _assessments[index];
          return _buildAssessmentCard(assessment);
        },
      ),
    );
  }

  Widget _buildAssessmentCard(Map<String, dynamic> assessment) {
    final List<dynamic> questions = assessment['questions'] ?? [];
    final String title = assessment['title'] ?? 'Untitled Quiz';
    final String type = assessment['type'] ?? 'quiz';
    final int totalMarks = assessment['total_marks'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppThemeInstructor.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeInstructor.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: AppThemeInstructor.shadowLight.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Assessment Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppThemeInstructor.primaryBlue.withOpacity(0.1),
                  AppThemeInstructor.primaryBlue.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppThemeInstructor.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.quiz,
                    color: AppThemeInstructor.surfaceWhite,
                    size: 24,
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppThemeInstructor.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppThemeInstructor.successGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              type.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppThemeInstructor.successGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$totalMarks marks',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppThemeInstructor.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${questions.length} questions',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppThemeInstructor.textSecondary,
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
          // Questions List
          if (questions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: questions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final question = entry.value;
                  return _buildQuestionCard(question, index + 1);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int questionNumber) {
    final String questionText = question['question_text'] ?? 'No question text';
    final String type = question['type'] ?? 'multiple_choice';
    final int marks = question['marks'] ?? 1;
    final List<dynamic> options = question['options'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeInstructor.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeInstructor.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppThemeInstructor.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$questionNumber',
                    style: TextStyle(
                      color: AppThemeInstructor.surfaceWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      questionText,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppThemeInstructor.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppThemeInstructor.warningAmber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$marks ${marks == 1 ? 'mark' : 'marks'}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppThemeInstructor.warningAmber,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          type.replaceAll('_', ' '),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppThemeInstructor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Options
          if (options.isNotEmpty) ...[  
            const SizedBox(height: 16),
            ...options.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final option = entry.value;
              return _buildOptionCard(option, optionIndex);
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionCard(Map<String, dynamic> option, int optionIndex) {
    final String optionText = option['option_text'] ?? 'No option text';
    final bool isCorrect = option['is_correct'] ?? false;
    final String optionLetter = String.fromCharCode(65 + optionIndex); // A, B, C, D...

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCorrect 
            ? AppThemeInstructor.successGreen.withOpacity(0.1)
            : AppThemeInstructor.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCorrect 
              ? AppThemeInstructor.successGreen
              : AppThemeInstructor.borderSubtle,
          width: isCorrect ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCorrect 
                  ? AppThemeInstructor.successGreen
                  : AppThemeInstructor.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: isCorrect
                  ? Icon(
                      Icons.check,
                      color: AppThemeInstructor.surfaceWhite,
                      size: 16,
                    )
                  : Text(
                      optionLetter,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppThemeInstructor.textSecondary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              optionText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w400,
                color: isCorrect 
                    ? AppThemeInstructor.successGreen
                    : AppThemeInstructor.textPrimary,
              ),
            ),
          ),
          // if (isCorrect)
          //   Container(
          //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          //     decoration: BoxDecoration(
          //       color: AppThemeInstructor.successGreen,
          //       borderRadius: BorderRadius.circular(6),
          //     ),
          //     child: Text(
          //       'CORRECT',
          //       style: TextStyle(
          //         fontSize: 10,
          //         fontWeight: FontWeight.bold,
          //         color: AppThemeInstructor.surfaceWhite,
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
