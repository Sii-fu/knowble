
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/services/Instructor/course_service.dart';
import '../../core/services/Instructor/questionai_service.dart';

import 'package:Knowble/core/services/Instructor/course_service.dart';
// import 'package:Knowble/core/services/Instructor/questionai_service.dart';

import 'package:flutter/foundation.dart';
import '../../config/theme.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  bool _isUploading = false;

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Container(
        color: Colors.black26,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryTeal, AppTheme.successGreen],
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Creating Course...',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we process your course',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _hideLoadingDialog() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }
  // Store all chapters and their lessons before upload
  final List<Map<String, dynamic>> _allChapters = [];

  // String? _createdCourseId;
  // Question section controllers
  final TextEditingController _questionTitleController = TextEditingController();
  final TextEditingController _questionMarksController = TextEditingController();

  // Helper to get the current courseId (you may want to store this after course creation)
  // Future<String?> _getCurrentCourseId() async {
  //   return _createdCourseId;
  // }
  // Gemini API key (replace with your actual key or load from secure storage)
  // final String _geminiApiKey = 'AIzaSyAUoA_MGBSzZHSIQsMRZ4BgM6vQcKhM9pI';
  // late final QuestionAIService _questionAIService;


  final CourseService _courseService = CourseService();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseDescriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationDaysController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _totalChaptersController = TextEditingController();
  final TextEditingController _totalLessonsController = TextEditingController();
  final TextEditingController _chapterNameController = TextEditingController();
  // Store parsed chapter names
  List<String> _chapterNames = [];
  int _currentChapterIndex = 0;
  final TextEditingController _lesson1Controller = TextEditingController();
  final TextEditingController _lessonCountController = TextEditingController();
  List<TextEditingController> _lessonControllers = [];

  // Store picked PDF info for each lesson: { 'path': ..., 'bytes': ..., 'name': ... }
  List<Map<String, dynamic>?> _lessonPdfInfos = [];

  String selectedLessonCount = '4 Lesson';
  String _selectedQuestionType = 'Mcq';

  final List<String> lessonCounts = [
    '1 Lesson',
    '2 Lesson',
    '3 Lesson',
    '4 Lesson',
    '5 Lesson',
    '6 Lesson',
  ];

  @override
  void initState() {
    super.initState();
    _courseNameController.text = '';
    _courseDescriptionController.text = '';
    _priceController.text = '';
    _durationDaysController.text = '';
    _tagController.text = '';
    _totalChaptersController.text = '';
    _totalLessonsController.text = '';
    _chapterNameController.text = '';
    _lesson1Controller.text = '';
    _lessonCountController.text = '';
    _updateLessonControllers();

    // _questionAIService = QuestionAIService(geminiApiKey: _geminiApiKey);
  }

  void _updateLessonControllers() {
    int lessonCount = int.tryParse(selectedLessonCount.split(' ')[0]) ?? 4;
    if (_lessonControllers.length < lessonCount) {
      for (int i = _lessonControllers.length; i < lessonCount; i++) {
        _lessonControllers.add(TextEditingController());
      }
    } else if (_lessonControllers.length > lessonCount) {
      _lessonControllers = _lessonControllers.sublist(0, lessonCount);
    }
    // Keep _lessonPdfPaths in sync
    if (_lessonPdfInfos.length < lessonCount) {
      for (int i = _lessonPdfInfos.length; i < lessonCount; i++) {
        _lessonPdfInfos.add(null);
      }
    } else if (_lessonPdfInfos.length > lessonCount) {
      _lessonPdfInfos = _lessonPdfInfos.sublist(0, lessonCount);
    }
    setState(() {});
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.shadowLight.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.successGreen, AppTheme.successGreen.withOpacity(0.8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Success!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryTeal, AppTheme.successGreen],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> _handlePdfUpload(int lessonIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      Map<String, dynamic> pdfInfo = {
        'name': file.name,
      };
      if (kIsWeb) {
        pdfInfo['bytes'] = file.bytes;
      } else {
        pdfInfo['path'] = file.path;
      }
      setState(() {
        if (_lessonPdfInfos.length <= lessonIndex) {
          _lessonPdfInfos.length = lessonIndex + 1;
        }
        _lessonPdfInfos[lessonIndex] = pdfInfo;
      });
      _showSuccessDialog('Lesson ${lessonIndex + 1}: PDF selected successfully!');
    }
  }

  // void _handleQuestionUpload() {
  //   _showSuccessDialog('Question uploaded successfully!');
  // }

  // Helper to collect current chapter's data into _allChapters
  void _saveCurrentChapterToList() {
    final chapterName = _chapterNameController.text.trim();
    if (chapterName.isEmpty) return;
    final lessons = <Map<String, dynamic>>[];
    for (int i = 0; i < _lessonControllers.length; i++) {
      final lessonTitle = _lessonControllers[i].text.trim();
      final lessonDescription = ""; // You can add a controller for description if needed
      final pdfInfo = i < _lessonPdfInfos.length ? _lessonPdfInfos[i] : null;
      Map<String, dynamic> lesson = {
        'title': lessonTitle,
        'description': lessonDescription,
        'pdf': pdfInfo != null ? {
          'fileName': pdfInfo['name'],
          if (kIsWeb && pdfInfo['bytes'] != null) 'bytes': pdfInfo['bytes'],
          if (!kIsWeb && pdfInfo['path'] != null) 'filePath': pdfInfo['path'],
        } : null,
      };
      lessons.add(lesson);
    }
    // If editing an existing chapter, replace it
    if (_allChapters.length > _currentChapterIndex) {
      _allChapters[_currentChapterIndex] = {
        'title': chapterName,
        'lessons': lessons,
      };
    } else {
      _allChapters.add({
        'title': chapterName,
        'lessons': lessons,
      });
    }
  }

  Future<void> _handleFinalUpload() async {
    // Save the last chapter before upload
    _saveCurrentChapterToList();
    final title = _courseNameController.text.trim();
    final description = _courseDescriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final durationDays = int.tryParse(_durationDaysController.text.trim()) ?? 0;
    final tag = _tagController.text.trim();

    if (title.isEmpty || _allChapters.isEmpty) {
      _showSuccessDialog('Course name and at least one chapter are required.');
      return;
    }

    setState(() {
      _isUploading = true;
    });
    _showLoadingDialog();
    try {
      final courseData = {
        'title': title,
        'description': description,
        'price': price,
        'durationDays': durationDays,
        'tag': tag,
      };
      final courseId = await _courseService.createFullCourse(
        courseData: courseData,
        chapters: _allChapters,
      );
      _hideLoadingDialog();
      setState(() {
        _isUploading = false;
        // _createdCourseId = courseId;
      });
      if (courseId == null) {
        _showSuccessDialog('Failed to create course.');
        return;
      }
      _showSuccessDialog('Course created and uploaded successfully!');
    } catch (e) {
      _hideLoadingDialog();
      setState(() {
        _isUploading = false;
      });
      _showSuccessDialog('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppTheme.surfaceWhite,
          elevation: 0,
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Course',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Chapter ${_currentChapterIndex + 1} of ${_chapterNames.length}',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          centerTitle: false,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryTeal.withOpacity(0.1), AppTheme.successGreen.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.save_outlined, color: AppTheme.primaryTeal, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Draft',
                    style: TextStyle(
                      color: AppTheme.primaryTeal,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Progress Indicator
              Container(
                width: double.infinity,
                color: AppTheme.surfaceWhite,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${((_currentChapterIndex + 1) / (_chapterNames.isEmpty ? 1 : _chapterNames.length) * 100).toInt()}%',
                          style: TextStyle(
                            color: AppTheme.primaryTeal,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_currentChapterIndex + 1) / (_chapterNames.isEmpty ? 1 : _chapterNames.length),
                      backgroundColor: AppTheme.borderSubtle,
                      valueColor: AlwaysStoppedAnimation(AppTheme.primaryTeal),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),
              
              // Content Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
            if (_currentChapterIndex == 0) ...[
              // Course Information Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryTeal.withOpacity(0.1), AppTheme.successGreen.withOpacity(0.1)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.school_outlined,
                            color: AppTheme.primaryTeal,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Course Information',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Basic details about your course',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    _buildModernTextField(
                      controller: _courseNameController,
                      label: 'Course Name',
                      hint: 'Enter an engaging course title',
                      icon: Icons.title_outlined,
                    ),
                    const SizedBox(height: 20),
                    
                    _buildModernTextField(
                      controller: _courseDescriptionController,
                      label: 'Description',
                      hint: 'Describe what students will learn',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernTextField(
                            controller: _priceController,
                            label: 'Price',
                            hint: '0.00',
                            icon: Icons.attach_money_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernTextField(
                            controller: _durationDaysController,
                            label: 'Duration (days)',
                            hint: '30',
                            icon: Icons.schedule_outlined,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildModernTextField(
                            controller: _tagController,
                            label: 'Category Tag',
                            hint: 'e.g., Mathematics, Science',
                            icon: Icons.tag_outlined,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildModernTextField(
                            controller: _totalChaptersController,
                            label: 'Total Chapters',
                            hint: '5',
                            icon: Icons.menu_book_outlined,
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              int count = int.tryParse(value) ?? 0;
                              if (count > 0) {
                                setState(() {
                                  _chapterNames = List.generate(count, (i) => '');
                                  _currentChapterIndex = 0;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
            // Chapter Content Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryTeal.withOpacity(0.1), AppTheme.successGreen.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.book_outlined,
                          color: AppTheme.primaryTeal,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chapter ${_currentChapterIndex + 1}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              'Add chapter details and lessons',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildModernTextField(
                    controller: _chapterNameController,
                    label: 'Chapter Name',
                    hint: 'Enter chapter title',
                    icon: Icons.title_outlined,
                    onChanged: (value) {
                      if (_chapterNames.isNotEmpty && _currentChapterIndex < _chapterNames.length) {
                        setState(() {
                          _chapterNames[_currentChapterIndex] = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  _buildModernTextField(
                    controller: _totalLessonsController,
                    label: 'Number of Lessons',
                    hint: 'How many lessons in this chapter?',
                    icon: Icons.list_outlined,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      int lessonCount = int.tryParse(value) ?? 0;
                      if (lessonCount > 0) {
                        setState(() {
                          selectedLessonCount = '$lessonCount Lesson';
                          _updateLessonControllers();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            
            if (_lessonControllers.isNotEmpty) ...[
              const SizedBox(height: 24),
              // Lessons Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadowLight.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppTheme.successGreen.withOpacity(0.1), AppTheme.primaryTeal.withOpacity(0.1)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.playlist_play_outlined,
                            color: AppTheme.successGreen,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lessons',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '${_lessonControllers.length} lessons to configure',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    for (int i = 0; i < _lessonControllers.length; i++) ...[
                      Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryTeal,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${i + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Lesson ${i + 1}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            _buildCompactTextField(
                              controller: _lessonControllers[i],
                              hint: 'Lesson title',
                              icon: Icons.play_lesson_outlined,
                            ),
                            const SizedBox(height: 12),
                            
                            _buildCompactTextField(
                              hint: 'Lesson description (optional)',
                              icon: Icons.notes_outlined,
                            ),
                            const SizedBox(height: 16),
                            
                            // PDF Upload Section
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceWhite,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _lessonPdfInfos[i] != null ? AppTheme.successGreen : AppTheme.borderSubtle,
                                  width: _lessonPdfInfos[i] != null ? 2 : 1,
                                ),
                              ),
                              child: InkWell(
                                onTap: () => _handlePdfUpload(i),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _lessonPdfInfos[i] != null 
                                              ? AppTheme.successGreen.withOpacity(0.1)
                                              : AppTheme.textSecondary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          _lessonPdfInfos[i] != null ? Icons.check_circle_outline : Icons.upload_file_outlined,
                                          color: _lessonPdfInfos[i] != null ? AppTheme.successGreen : AppTheme.textSecondary,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _lessonPdfInfos[i] != null ? 'PDF Uploaded' : 'Upload PDF Material',
                                              style: TextStyle(
                                                color: _lessonPdfInfos[i] != null ? AppTheme.successGreen : AppTheme.textPrimary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (_lessonPdfInfos[i] != null)
                                              Text(
                                                _lessonPdfInfos[i]!['name'] ?? 'Unknown file',
                                                style: TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              )
                                            else
                                              Text(
                                                'Add study materials for this lesson',
                                                style: TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 12,
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
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Questions Section
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderSubtle),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.shadowLight.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange.withOpacity(0.1), Colors.deepOrange.withOpacity(0.1)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.quiz_outlined,
                          color: Colors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Assessment',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Add questions for this chapter',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  _buildModernTextField(
                    controller: _questionTitleController,
                    label: 'Question Title',
                    hint: 'Enter your question',
                    icon: Icons.help_outline,
                  ),
                  const SizedBox(height: 20),
                  
                  // Question Type Dropdown
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderSubtle),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedQuestionType,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            prefixIcon: Icon(
                              Icons.category_outlined,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'Mcq', child: Text('Multiple Choice')),
                            DropdownMenuItem(value: 'Code', child: Text('Code Challenge')),
                            DropdownMenuItem(value: 'Text', child: Text('Written Answer')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedQuestionType = value!;
                            });
                          },
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                          ),
                          dropdownColor: AppTheme.surfaceWhite,
                          icon: Icon(
                            Icons.expand_more,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  _buildModernTextField(
                    controller: _questionMarksController,
                    label: 'Total Marks',
                    hint: 'Points for this question',
                    icon: Icons.star_outline,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            // Action Buttons
            Row(
              children: [
                if (_currentChapterIndex < _chapterNames.length - 1)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryTeal, AppTheme.successGreen],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryTeal.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          _saveCurrentChapterToList();
                          setState(() {
                            _currentChapterIndex++;
                            _chapterNameController.clear();
                            _totalLessonsController.clear();
                            _lessonControllers.clear();
                            _lessonPdfInfos.clear();
                            selectedLessonCount = '4 Lesson';
                            _updateLessonControllers();
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Next Chapter',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_currentChapterIndex == _chapterNames.length - 1)
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.successGreen, Colors.green.shade600],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.successGreen.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _isUploading ? null : _handleFinalUpload,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          disabledBackgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: _isUploading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.publish_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Publish Course',
                                    style: TextStyle(
                                      color: Colors.white,
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
            const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for modern text fields
  Widget _buildModernTextField({
    required String label,
    required String hint,
    required IconData icon,
    TextEditingController? controller,
    TextInputType? keyboardType,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.borderSubtle),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper method for compact text fields
  Widget _buildCompactTextField({
    required String hint,
    required IconData icon,
    TextEditingController? controller,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 14,
          color: AppTheme.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: AppTheme.textSecondary,
            size: 18,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
