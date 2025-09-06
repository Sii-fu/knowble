import 'package:flutter/material.dart';
import '../../config/theme_instructor.dart';
import '../../core/services/Instructor/manual_quiz_service.dart';

class QuizOption {
  final TextEditingController textController = TextEditingController();
  bool isCorrect = false;

  QuizOption({String? text, this.isCorrect = false}) {
    if (text != null) textController.text = text;
  }

  void dispose() {
    textController.dispose();
  }

  Map<String, dynamic> toJson() {
    return {
      'text': textController.text.trim(),
      'is_correct': isCorrect,
    };
  }
}

class ManualQuiz {
  final TextEditingController questionController = TextEditingController();
  final List<QuizOption> options = [];

  ManualQuiz() {
    // Start with 2 empty options
    options.add(QuizOption());
    options.add(QuizOption());
  }

  void addOption() {
    if (options.length < 4) {
      options.add(QuizOption());
    }
  }

  void removeOption(int index) {
    if (options.length > 2 && index < options.length) {
      options[index].dispose();
      options.removeAt(index);
    }
  }

  bool get hasCorrectAnswer {
    return options.any((option) => option.isCorrect);
  }

  void setCorrectAnswer(int index) {
    // Unmark all options first
    for (var option in options) {
      option.isCorrect = false;
    }
    // Mark the selected option as correct
    if (index < options.length) {
      options[index].isCorrect = true;
    }
  }

  bool get isValid {
    return questionController.text.trim().isNotEmpty &&
           options.every((option) => option.textController.text.trim().isNotEmpty) &&
           hasCorrectAnswer;
  }

  void dispose() {
    questionController.dispose();
    for (var option in options) {
      option.dispose();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'question': questionController.text.trim(),
      'options': options.map((option) => option.toJson()).toList(),
    };
  }
}

class ManualQuizCreationPage extends StatefulWidget {
  final String lessonTitle;
  final List<ManualQuiz> existingQuizzes;
  // Optional: sectionId from the DB. If provided, confirmed quizzes will be
  // persisted to the DB and linked to this section.
  final String? sectionId;

  const ManualQuizCreationPage({
    Key? key,
    required this.lessonTitle,
    required this.existingQuizzes,
    this.sectionId,
  }) : super(key: key);

  @override
  State<ManualQuizCreationPage> createState() => _ManualQuizCreationPageState();
}

class _ManualQuizCreationPageState extends State<ManualQuizCreationPage> {
  late List<ManualQuiz> quizzes;
  bool _isSaving = false;
  final ManualQuizService _quizService = ManualQuizService();

  @override
  void initState() {
    super.initState();
    quizzes = widget.existingQuizzes.isEmpty 
        ? [ManualQuiz()] 
        : List.from(widget.existingQuizzes);
  }

  void _addQuiz() {
    setState(() {
      quizzes.add(ManualQuiz());
    });
  }

  void _removeQuiz(int index) {
    if (quizzes.length > 1) {
      setState(() {
        quizzes[index].dispose();
        quizzes.removeAt(index);
      });
    }
  }

  Future<void> _confirmQuizzes() async {
    final validQuizzes = quizzes.where((quiz) => quiz.isValid).toList();
    if (validQuizzes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create at least one valid quiz before confirming.')),
      );
      return;
    }

    // If sectionId is provided, persist to DB and return created assessment info
    final sectionId = widget.sectionId;
    if (sectionId != null && sectionId.isNotEmpty) {
      setState(() => _isSaving = true);
      try {
        final quizzesPayload = validQuizzes.map((q) => q.toJson()).toList();
        final title = widget.lessonTitle.isNotEmpty ? widget.lessonTitle : 'Manual Quiz';
        final res = await _quizService.createAssessmentWithQuizzes(
          sectionId: sectionId,
          title: title,
          quizzes: quizzesPayload.cast<Map<String, dynamic>>(),
        );
        setState(() => _isSaving = false);
        if (res == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save quizzes. Please try again.')),
          );
          return;
        }

        // Return the created assessment info to the caller
        Navigator.of(context).pop(res);
        return;
      } catch (e) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving quizzes: ${e.toString()}')),
        );
        return;
      }
    }

    // Fallback: no sectionId provided — return the quizzes to the caller (in-memory)
    Navigator.of(context).pop(validQuizzes);
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeInstructor.lightTheme;
    
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: AppThemeInstructor.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppThemeInstructor.surfaceWhite,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: AppThemeInstructor.accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: AppThemeInstructor.textPrimary, size: 18),
              onPressed: () => Navigator.pop(context),
              padding: const EdgeInsets.only(left: 4),
            ),
          ),
          title: Text(
            'Create Quizzes',
            style: theme.textTheme.titleLarge?.copyWith(
              color: AppThemeInstructor.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            // Lesson header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppThemeInstructor.surfaceWhite,
                border: Border(
                  bottom: BorderSide(color: AppThemeInstructor.borderSubtle),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppThemeInstructor.primaryBlue.withOpacity(0.1), AppThemeInstructor.successGreen.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.quiz_outlined,
                          color: AppThemeInstructor.primaryBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.lessonTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppThemeInstructor.textPrimary,
                              ),
                            ),
                            Text(
                              'Create quizzes for this lesson',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppThemeInstructor.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Quiz cards
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    for (int quizIndex = 0; quizIndex < quizzes.length; quizIndex++) ...[
                      _buildQuizCard(quizIndex),
                      const SizedBox(height: 16),
                    ],
                    
                    // Add Quiz button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppThemeInstructor.primaryBlue.withOpacity(0.3),
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: InkWell(
                        onTap: _addQuiz,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_circle_outline,
                                color: AppThemeInstructor.primaryBlue,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add Quiz',
                                style: TextStyle(
                                  color: AppThemeInstructor.primaryBlue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom action bar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppThemeInstructor.surfaceWhite,
                border: Border(
                  top: BorderSide(color: AppThemeInstructor.borderSubtle),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${quizzes.where((quiz) => quiz.isValid).length} valid quiz${quizzes.where((quiz) => quiz.isValid).length != 1 ? 'zes' : ''} created',
                      style: TextStyle(
                        color: AppThemeInstructor.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: (_isSaving || !quizzes.any((quiz) => quiz.isValid)) ? null : _confirmQuizzes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemeInstructor.primaryBlue,
                        foregroundColor: AppThemeInstructor.surfaceWhite,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Confirm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizCard(int quizIndex) {
    final quiz = quizzes[quizIndex];
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppThemeInstructor.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeInstructor.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: AppThemeInstructor.shadowLight.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quiz header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppThemeInstructor.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${quizIndex + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Quiz ${quizIndex + 1}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppThemeInstructor.textPrimary,
                  ),
                ),
              ),
              if (quizzes.length > 1)
                IconButton(
                  onPressed: () => _removeQuiz(quizIndex),
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red.shade400,
                    size: 18,
                  ),
                  tooltip: 'Remove Quiz',
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Question field
          Container(
            decoration: BoxDecoration(
              color: AppThemeInstructor.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppThemeInstructor.borderSubtle),
            ),
            child: TextField(
              controller: quiz.questionController,
              decoration: InputDecoration(
                hintText: 'Enter your quiz question...',
                hintStyle: TextStyle(color: AppThemeInstructor.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              maxLines: 2,
              onChanged: (_) => setState(() {}), // Rebuild for validation
            ),
          ),
          const SizedBox(height: 16),
          
          // Options
          Text(
            'Options',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppThemeInstructor.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          
          for (int optionIndex = 0; optionIndex < quiz.options.length; optionIndex++) ...[
            _buildOptionField(quizIndex, optionIndex),
            if (optionIndex < quiz.options.length - 1) const SizedBox(height: 12),
          ],
          
          // Add option button
          if (quiz.options.length < 4) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                setState(() {
                  quiz.addOption();
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppThemeInstructor.primaryBlue.withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: AppThemeInstructor.primaryBlue.withOpacity(0.05),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      color: AppThemeInstructor.primaryBlue,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Add Option',
                      style: TextStyle(
                        color: AppThemeInstructor.primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Validation message
          if (!quiz.isValid && quiz.questionController.text.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              quiz.hasCorrectAnswer 
                  ? 'Please fill in all option texts'
                  : 'Please mark one option as correct',
              style: TextStyle(
                color: Colors.red.shade400,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionField(int quizIndex, int optionIndex) {
    final quiz = quizzes[quizIndex];
    final option = quiz.options[optionIndex];
    
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppThemeInstructor.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: option.isCorrect 
              ? AppThemeInstructor.successGreen 
              : AppThemeInstructor.borderSubtle,
          width: option.isCorrect ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Radio button for correct answer
          Container(
            padding: const EdgeInsets.all(0),
            child: Radio<int>(
              value: optionIndex,
              groupValue: quiz.options.indexWhere((opt) => opt.isCorrect),
              onChanged: (value) {
                setState(() {
                  quiz.setCorrectAnswer(value!);
                });
              },
              activeColor: AppThemeInstructor.successGreen,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          
          // Option text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: TextField(
                controller: option.textController,
                style: TextStyle(
                  color: AppThemeInstructor.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter option ${optionIndex + 1}...',
                  hintStyle: TextStyle(
                    color: AppThemeInstructor.textSecondary,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  // Provide padding inside the TextField so the hint and text don't touch the edges
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}), // Rebuild for validation
              ),
            ),
          ),
          
          // Delete option button
          if (quiz.options.length > 2)
            Container(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    quiz.removeOption(optionIndex);
                  });
                },
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: Colors.red.shade400,
                  size: 20,
                ),
                tooltip: 'Remove Option',
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var quiz in quizzes) {
      quiz.dispose();
    }
    super.dispose();
  }
}

class QuizViewDialog extends StatelessWidget {
  final String lessonTitle;
  final List<ManualQuiz> quizzes;

  const QuizViewDialog({
    Key? key,
    required this.lessonTitle,
    required this.quizzes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final validQuizzes = quizzes.where((quiz) => quiz.isValid).toList();
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.quiz_outlined,
                  color: AppThemeInstructor.primaryBlue,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lessonTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppThemeInstructor.textPrimary,
                        ),
                      ),
                      Text(
                        '${validQuizzes.length} quiz${validQuizzes.length != 1 ? 'zes' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppThemeInstructor.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: AppThemeInstructor.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Quiz list
            Expanded(
              child: validQuizzes.isEmpty
                  ? Center(
                      child: Text(
                        'No valid quizzes found',
                        style: TextStyle(
                          color: AppThemeInstructor.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: validQuizzes.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final quiz = validQuizzes[index];
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppThemeInstructor.backgroundLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppThemeInstructor.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Question
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppThemeInstructor.primaryBlue,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      quiz.questionController.text,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppThemeInstructor.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Options
                              for (int optIndex = 0; optIndex < quiz.options.length; optIndex++) ...[
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.only(bottom: 4),
                                  decoration: BoxDecoration(
                                    color: quiz.options[optIndex].isCorrect
                                        ? AppThemeInstructor.successGreen.withOpacity(0.1)
                                        : AppThemeInstructor.surfaceWhite,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: quiz.options[optIndex].isCorrect
                                          ? AppThemeInstructor.successGreen
                                          : AppThemeInstructor.borderSubtle,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        '${String.fromCharCode(65 + optIndex)}.',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: AppThemeInstructor.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          quiz.options[optIndex].textController.text,
                                          style: TextStyle(
                                            color: AppThemeInstructor.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (quiz.options[optIndex].isCorrect)
                                        Icon(
                                          Icons.check_circle,
                                          color: AppThemeInstructor.successGreen,
                                          size: 16,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
            
            // Footer
            const SizedBox(height: 16),
            Row(
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: AppThemeInstructor.primaryBlue,
                      fontWeight: FontWeight.w600,
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
}
