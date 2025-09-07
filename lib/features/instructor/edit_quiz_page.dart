import 'package:flutter/material.dart';
import '../../../config/theme_instructor.dart';
import '../../../core/services/instructor/quiz_services.dart';

class EditQuizPage extends StatefulWidget {
  final String sectionId;
  final String lessonTitle;

  const EditQuizPage({
    super.key,
    required this.sectionId,
    required this.lessonTitle,
  });

  @override
  State<EditQuizPage> createState() => _EditQuizPageState();
}

class _EditQuizPageState extends State<EditQuizPage> {
  final QuizService _quizService = QuizService();
  bool _isLoading = true;
  bool _isSaving = false;
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

  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);
    
    try {
      // Here you would implement the save logic
      // For now, just refresh the data
      await _fetchQuizData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Changes saved successfully'),
            backgroundColor: AppThemeInstructor.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save changes: $e'),
            backgroundColor: AppThemeInstructor.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _addNewAssessment() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _AddAssessmentDialog(),
    );

    if (result != null) {
      try {
        setState(() => _isSaving = true);
        
        await _quizService.createAssessment(
          sectionId: widget.sectionId,
          title: result['title'],
          type: result['type'],
          totalMarks: result['totalMarks'],
        );
        
        await _fetchQuizData();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Assessment created successfully'),
              backgroundColor: AppThemeInstructor.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create assessment: $e'),
              backgroundColor: AppThemeInstructor.errorRed,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false);
        }
      }
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
            'Edit ${widget.lessonTitle}',
            style: TextStyle(
              color: AppThemeInstructor.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              TextButton(
                onPressed: _saveChanges,
                child: Text(
                  'Save',
                  style: TextStyle(
                    color: AppThemeInstructor.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
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
              'Create your first quiz for this lesson.',
              style: TextStyle(
                fontSize: 14,
                color: AppThemeInstructor.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _addNewAssessment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeInstructor.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Create Quiz', style: TextStyle(color: Colors.white)),
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
          return _EditableAssessmentCard(
            assessment: assessment,
            onAssessmentUpdated: _fetchQuizData,
            quizService: _quizService,
          );
        },
      ),
    );
  }
}

class _EditableAssessmentCard extends StatefulWidget {
  final Map<String, dynamic> assessment;
  final VoidCallback onAssessmentUpdated;
  final QuizService quizService;

  const _EditableAssessmentCard({
    required this.assessment,
    required this.onAssessmentUpdated,
    required this.quizService,
  });

  @override
  State<_EditableAssessmentCard> createState() => _EditableAssessmentCardState();
}

class _EditableAssessmentCardState extends State<_EditableAssessmentCard> {
  late TextEditingController _titleController;
  late TextEditingController _typeController;
  late TextEditingController _totalMarksController;
  bool _isEditing = false;
  bool _isExpanded = false;
  late List<Map<String, dynamic>> _localQuestions;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.assessment['title'] ?? '');
    _typeController = TextEditingController(text: widget.assessment['type'] ?? 'quiz');
    _totalMarksController = TextEditingController(text: (widget.assessment['total_marks'] ?? 0).toString());
  _localQuestions = List<Map<String, dynamic>>.from(widget.assessment['questions'] ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _typeController.dispose();
    _totalMarksController.dispose();
    super.dispose();
  }

  Future<void> _saveAssessment() async {
    try {
      await widget.quizService.updateAssessment(
        assessmentId: widget.assessment['id'],
        title: _titleController.text,
        type: _typeController.text,
        totalMarks: int.tryParse(_totalMarksController.text) ?? 0,
      );
      
      setState(() => _isEditing = false);
      widget.onAssessmentUpdated();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Assessment updated successfully'),
            backgroundColor: AppThemeInstructor.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update assessment: $e'),
            backgroundColor: AppThemeInstructor.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _deleteAssessment() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Assessment'),
        content: const Text('Are you sure you want to delete this assessment? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppThemeInstructor.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.quizService.deleteAssessment(widget.assessment['id']);
        widget.onAssessmentUpdated();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Assessment deleted successfully'),
              backgroundColor: AppThemeInstructor.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete assessment: $e'),
              backgroundColor: AppThemeInstructor.errorRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
  // Use _localQuestions for editable question list

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
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: _isExpanded ? Radius.zero : const Radius.circular(16),
                bottomRight: _isExpanded ? Radius.zero : const Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                Row(
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
                      child: _isEditing ? _buildEditingFields() : _buildDisplayFields(),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isEditing) ...[
                          IconButton(
                            onPressed: _saveAssessment,
                            icon: Icon(Icons.check, color: AppThemeInstructor.successGreen),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _isEditing = false),
                            icon: Icon(Icons.close, color: AppThemeInstructor.errorRed),
                          ),
                        ] else ...[
                          IconButton(
                            onPressed: () => setState(() => _isEditing = true),
                            icon: Icon(Icons.edit, color: AppThemeInstructor.primaryBlue),
                          ),
                          IconButton(
                            onPressed: _deleteAssessment,
                            icon: Icon(Icons.delete, color: AppThemeInstructor.errorRed),
                          ),
                        ],
                        IconButton(
                          onPressed: () => setState(() => _isExpanded = !_isExpanded),
                          icon: Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: AppThemeInstructor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Questions List
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  ..._localQuestions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    return _EditableQuestionCard(
                      question: question,
                      questionNumber: index + 1,
                      assessmentId: widget.assessment['id'],
                      onQuestionUpdated: (updated) {
                        // Update the local question entry in-place
                        setState(() {
                          _localQuestions[index] = updated;
                        });
                        // If the question has an id (saved), notify parent to refresh assessment data
                        if (updated['id'] != null) widget.onAssessmentUpdated();
                      },
                      quizService: widget.quizService,
                    );
                  }),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _addNewQuestion(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppThemeInstructor.primaryBlue,
                        side: BorderSide(color: AppThemeInstructor.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Question'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDisplayFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _titleController.text,
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
                _typeController.text.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppThemeInstructor.successGreen,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${_totalMarksController.text} marks',
              style: TextStyle(
                fontSize: 12,
                color: AppThemeInstructor.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(widget.assessment['questions'] ?? []).length} questions',
              style: TextStyle(
                fontSize: 12,
                color: AppThemeInstructor.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditingFields() {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppThemeInstructor.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Assessment Title',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _typeController,
                decoration: InputDecoration(
                  hintText: 'Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _totalMarksController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Total Marks',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _addNewQuestion() async {
    // Add a local placeholder question and expand the card.
    setState(() {
      _isExpanded = true;
      _localQuestions.add({
        'id': null,
        'question_text': '',
        'type': 'multiple_choice',
        'marks': 1,
        'options': <Map<String, dynamic>>[],
        'isNew': true,
      });
    });
    // Do not refresh the whole page; user will edit and save the new question.
  }
}

class _EditableQuestionCard extends StatefulWidget {
  final Map<String, dynamic> question;
  final int questionNumber;
  final String assessmentId;
  final ValueChanged<Map<String, dynamic>> onQuestionUpdated;
  final QuizService quizService;

  const _EditableQuestionCard({
    required this.question,
    required this.questionNumber,
    required this.assessmentId,
    required this.onQuestionUpdated,
    required this.quizService,
  });

  @override
  State<_EditableQuestionCard> createState() => _EditableQuestionCardState();
}

class _EditableQuestionCardState extends State<_EditableQuestionCard> {
  late TextEditingController _questionController;
  late TextEditingController _typeController;
  late TextEditingController _marksController;
  bool _isEditing = false;
  List<Map<String, dynamic>> _options = [];

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.question['question_text'] ?? '');
    _typeController = TextEditingController(text: widget.question['type'] ?? 'multiple_choice');
    _marksController = TextEditingController(text: (widget.question['marks'] ?? 1).toString());
    _options = List<Map<String, dynamic>>.from(widget.question['options'] ?? []);
  }

  @override
  void dispose() {
    _questionController.dispose();
    _typeController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    try {
      await widget.quizService.updateQuestion(
        questionId: widget.question['id'],
        questionText: _questionController.text,
        type: _typeController.text,
        marks: int.tryParse(_marksController.text) ?? 1,
      );

      await widget.quizService.updateQuestionOptions(
        questionId: widget.question['id'],
        options: _options,
      );
      
      setState(() => _isEditing = false);
      widget.onQuestionUpdated({
        'id': widget.question['id'],
        'question_text': _questionController.text,
        'type': _typeController.text,
        'marks': int.tryParse(_marksController.text) ?? 1,
        'options': _options,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Question updated successfully'),
            backgroundColor: AppThemeInstructor.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update question: $e'),
            backgroundColor: AppThemeInstructor.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _deleteQuestion() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Question'),
        content: const Text('Are you sure you want to delete this question?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppThemeInstructor.errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await widget.quizService.deleteQuestion(widget.question['id']);
        widget.onQuestionUpdated({
          'id': null,
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Question deleted successfully'),
              backgroundColor: AppThemeInstructor.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete question: $e'),
              backgroundColor: AppThemeInstructor.errorRed,
            ),
          );
        }
      }
    }
  }

  void _addOption() {
    setState(() {
      _options.add({
        'option_text': 'New Option',
        'is_correct': false,
        'order': _options.length + 1,
      });
    });
  }

  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index);
      // Update order for remaining options
      for (int i = 0; i < _options.length; i++) {
        _options[i]['order'] = i + 1;
      }
    });
  }

  void _setCorrectOption(int index) {
    setState(() {
      // Set all options to false first
      for (var option in _options) {
        option['is_correct'] = false;
      }
      // Set the selected option to true
      if (index < _options.length) {
        _options[index]['is_correct'] = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    '${widget.questionNumber}',
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
                child: _isEditing ? _buildEditingQuestion() : _buildDisplayQuestion(),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isEditing) ...[
                    IconButton(
                      onPressed: _saveQuestion,
                      icon: Icon(Icons.check, color: AppThemeInstructor.successGreen, size: 20),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                          // Reset to original values
                          _questionController.text = widget.question['question_text'] ?? '';
                          _typeController.text = widget.question['type'] ?? 'multiple_choice';
                          _marksController.text = (widget.question['marks'] ?? 1).toString();
                          _options = List<Map<String, dynamic>>.from(widget.question['options'] ?? []);
                        });
                      },
                      icon: Icon(Icons.close, color: AppThemeInstructor.errorRed, size: 20),
                    ),
                  ] else ...[
                    IconButton(
                      onPressed: () => setState(() => _isEditing = true),
                      icon: Icon(Icons.edit, color: AppThemeInstructor.primaryBlue, size: 20),
                    ),
                    IconButton(
                      onPressed: _deleteQuestion,
                      icon: Icon(Icons.delete, color: AppThemeInstructor.errorRed, size: 20),
                    ),
                  ],
                ],
              ),
            ],
          ),
          
          // Options
          if (_options.isNotEmpty) ...[
            const SizedBox(height: 16),
            ..._options.asMap().entries.map((entry) {
              final optionIndex = entry.key;
              final option = entry.value;
              return _buildOptionWidget(option, optionIndex);
            }),
          ],
          
          // Add Option Button (only in editing mode)
          if (_isEditing) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _addOption,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppThemeInstructor.successGreen,
                  side: BorderSide(color: AppThemeInstructor.successGreen),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Option', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDisplayQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _questionController.text,
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
                '${_marksController.text} ${int.tryParse(_marksController.text) == 1 ? 'mark' : 'marks'}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppThemeInstructor.warningAmber,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _typeController.text.replaceAll('_', ' '),
              style: TextStyle(
                fontSize: 11,
                color: AppThemeInstructor.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditingQuestion() {
    return Column(
      children: [
        TextField(
          controller: _questionController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Question text',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _typeController,
                decoration: InputDecoration(
                  hintText: 'Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _marksController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Marks',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOptionWidget(Map<String, dynamic> option, int optionIndex) {
    final String optionLetter = String.fromCharCode(65 + optionIndex); // A, B, C, D...
    final bool isCorrect = option['is_correct'] ?? false;

    if (_isEditing) {
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppThemeInstructor.surfaceWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppThemeInstructor.borderSubtle),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _setCorrectOption(optionIndex),
              child: Container(
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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: TextEditingController(text: option['option_text'] ?? ''),
                onChanged: (value) {
                  option['option_text'] = value;
                },
                decoration: InputDecoration(
                  hintText: 'Option text',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            IconButton(
              onPressed: () => _removeOption(optionIndex),
              icon: Icon(Icons.delete, color: AppThemeInstructor.errorRed, size: 18),
            ),
          ],
        ),
      );
    } else {
      // Display mode - same as view quiz page
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
                option['option_text'] ?? 'No option text',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isCorrect ? FontWeight.w600 : FontWeight.w400,
                  color: isCorrect 
                      ? AppThemeInstructor.successGreen
                      : AppThemeInstructor.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

class _AddAssessmentDialog extends StatefulWidget {
  @override
  State<_AddAssessmentDialog> createState() => _AddAssessmentDialogState();
}

class _AddAssessmentDialogState extends State<_AddAssessmentDialog> {
  final _titleController = TextEditingController();
  final _typeController = TextEditingController(text: 'quiz');
  final _totalMarksController = TextEditingController(text: '10');

  @override
  void dispose() {
    _titleController.dispose();
    _typeController.dispose();
    _totalMarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Assessment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Assessment Title',
              hintText: 'Enter assessment title',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _typeController,
            decoration: const InputDecoration(
              labelText: 'Assessment Type',
              hintText: 'quiz, test, exam, etc.',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _totalMarksController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Total Marks',
              hintText: 'Enter total marks',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              Navigator.pop(context, {
                'title': _titleController.text,
                'type': _typeController.text,
                'totalMarks': int.tryParse(_totalMarksController.text) ?? 10,
              });
            }
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}
