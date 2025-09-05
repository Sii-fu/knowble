
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:Knowble/core/services/Instructor/questionai_service.dart';
import 'package:Knowble/core/services/Instructor/course_service.dart';
import 'package:flutter/foundation.dart';
import '../../config/theme_instructor.dart';
import 'manual_quiz_creation.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  bool _isUploading = false;
  Map<String, dynamic>? _courseBannerInfo;
  Future<void> _handleBannerUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      setState(() {
        // include actual bytes (web) or local path (mobile) so backend can upload
        final info = <String, dynamic>{'name': file.name};
        if (kIsWeb) {
          info['bytes'] = file.bytes;
        } else {
          info['path'] = file.path;
        }
        _courseBannerInfo = info;
      });
    }
  }

  // Course basic info controllers
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseDescriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationDaysController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final List<String> _tagSuggestions = [];
  Timer? _tagDebounce;

  // Dynamic chapters and lessons structure
  final List<ChapterData> _chapters = [];

  // (Per-chapter) question section controllers moved into ChapterData

  // Course service and other services
  final CourseService _courseService = CourseService();
  String? _currentCourseId;
  

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
              color: AppThemeInstructor.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppThemeInstructor.shadowLight.withOpacity(0.15),
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
                    gradient: AppThemeInstructor.instructorGradient,
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
                    color: AppThemeInstructor.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we process your course',
                  style: TextStyle(
                    color: AppThemeInstructor.textSecondary,
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
  final QuestionAIService _questionAI = QuestionAIService();
  void _hideLoadingDialog() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize with one chapter and one lesson
    _addNewChapter();
  // Listen to tag input and fetch suggestions
  _tagController.addListener(_onTagChanged);
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseDescriptionController.dispose();
    _priceController.dispose();
    _durationDaysController.dispose();
    _tagController.dispose();
  // per-chapter controllers disposed by ChapterData.dispose()
    
    // Dispose all chapters and lessons
    for (var chapter in _chapters) {
      chapter.dispose();
    }
    _tagDebounce?.cancel();
    _tagController.removeListener(_onTagChanged);
    
    super.dispose();
  }

  void _onTagChanged() {
    final value = _tagController.text.trim();
    _tagDebounce?.cancel();
    _tagDebounce = Timer(const Duration(milliseconds: 300), () async {
      if (value.isEmpty) {
        setState(() => _tagSuggestions.clear());
        return;
      }
      final tags = await _courseService.fetchTagsByPrefix(value);
      setState(() {
        _tagSuggestions
          ..clear()
          ..addAll(tags);
      });
    });
  }

  // Dynamic chapter and lesson management
  void _addNewChapter() {
    setState(() {
      _chapters.add(ChapterData(
        nameController: TextEditingController(),
  lessons: [_createNewLesson()],
  questionTitleController: TextEditingController(),
  questionMarksController: TextEditingController(),
      ));
    });
  }

  LessonData _createNewLesson() {
    return LessonData(
      titleController: TextEditingController(),
      descriptionController: TextEditingController(),
  aiQuizCount: 5,
    );
  }

  void _addLessonToChapter(int chapterIndex) {
    setState(() {
      _chapters[chapterIndex].lessons.add(_createNewLesson());
    });
  }

  void _removeChapter(int chapterIndex) {
    if (_chapters.length > 1) {
      setState(() {
        _chapters[chapterIndex].dispose();
        _chapters.removeAt(chapterIndex);
      });
    }
  }

  void _removeLesson(int chapterIndex, int lessonIndex) {
    if (_chapters[chapterIndex].lessons.length > 1) {
      setState(() {
        _chapters[chapterIndex].lessons[lessonIndex].dispose();
        _chapters[chapterIndex].lessons.removeAt(lessonIndex);
      });
    }
  }

  // File upload functions
  Future<void> _handlePdfUpload(int chapterIndex, int lessonIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom, 
      allowedExtensions: ['pdf']
    );
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
        _chapters[chapterIndex].lessons[lessonIndex].pdfFile = pdfInfo;
      });
      _showSuccessDialog('PDF uploaded successfully!');
    }
  }

  Future<void> _handleVideoUpload(int chapterIndex, int lessonIndex) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      Map<String, dynamic> videoInfo = {
        'name': file.name,
      };
      if (kIsWeb) {
        videoInfo['bytes'] = file.bytes;
      } else {
        videoInfo['path'] = file.path;
      }
      setState(() {
        _chapters[chapterIndex].lessons[lessonIndex].videoFile = videoInfo;
      });
      _showSuccessDialog('Video uploaded successfully!');
    }
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
              color: AppThemeInstructor.surfaceWhite,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppThemeInstructor.shadowLight.withOpacity(0.15),
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
                      colors: [AppThemeInstructor.primaryBlue, AppThemeInstructor.successGreen.withOpacity(0.8)],
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
                    color: AppThemeInstructor.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppThemeInstructor.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppThemeInstructor.instructorGradient,
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

  Future<void> _generateQuizForLesson(int chapterIndex, int lessonIndex) async {
    final lesson = _chapters[chapterIndex].lessons[lessonIndex];
    if (_currentCourseId == null) {
      _showSuccessDialog('Please create and save the course first before generating AI quizzes.');
      return;
    }
    // Require a real DB section id. We don't have section ids in the in-memory model
    // right after creating the course. Prevent calling the backend with the placeholder.
    if (lesson.sectionId == null || lesson.sectionId!.isEmpty) {
      _showSuccessDialog('Section ID is not available yet. Please reopen the saved course or generate quizzes from the course editor where section IDs are persisted.');
      return;
    }
    // Validate UUID format to avoid sending malformed ids to the backend
    final uuidRegExp = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$');
    if (!uuidRegExp.hasMatch(lesson.sectionId!)) {
      _showSuccessDialog('Section ID looks malformed. Please reopen the saved course or edit the course so section IDs can be refreshed before generating an AI quiz.');
      return;
    }
    setState(() {
      lesson.aiStatus = 'Generating questions from PDF...';
    });
    try {
      final res = await _questionAI.generateAndStoreMCQs(
        courseId: _currentCourseId!,
        sectionId: lesson.sectionId!,
        assessmentTitle: '${lesson.titleController.text} Quiz',
        type: 'quiz',
        totalMarks: lesson.aiQuizCount,
        onStatus: (status) {
          setState(() {
            lesson.aiStatus = status;
          });
        },
      );
      setState(() {
        lesson.generatedAssessmentId = res['assessment_id'] as String?;
        lesson.aiStatus = 'Quiz successfully generated.';
      });
      _showSuccessDialog('Quiz generated with ${res['questions_inserted']} questions.');
    } catch (e) {
      setState(() {
        lesson.aiStatus = 'Failed to generate quiz: ${e.toString()}';
      });
      _showSuccessDialog('AI generation failed: ${e.toString()}');
    }
  }

  void _navigateToManualQuizPage(int chapterIndex, int lessonIndex) async {
    final lesson = _chapters[chapterIndex].lessons[lessonIndex];
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ManualQuizCreationPage(
          lessonTitle: lesson.titleController.text.isEmpty 
              ? 'Lesson ${lessonIndex + 1}' 
              : lesson.titleController.text,
          existingQuizzes: lesson.manualQuizzes,
        ),
      ),
    );

    if (result != null && result is List<ManualQuiz>) {
      setState(() {
        lesson.manualQuizzes.clear();
        lesson.manualQuizzes.addAll(result);
      });
    }
  }

  void _showQuizzesReadOnly(int chapterIndex, int lessonIndex) {
    final lesson = _chapters[chapterIndex].lessons[lessonIndex];
    showDialog(
      context: context,
      builder: (context) => QuizViewDialog(
        lessonTitle: lesson.titleController.text.isEmpty 
            ? 'Lesson ${lessonIndex + 1}' 
            : lesson.titleController.text,
        quizzes: lesson.manualQuizzes,
      ),
    );
  }



  Future<void> _handleFinalUpload() async {
    final title = _courseNameController.text.trim();
    final description = _courseDescriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final durationDays = int.tryParse(_durationDaysController.text.trim()) ?? 0;
    final tag = _tagController.text.trim();

    if (title.isEmpty || _chapters.isEmpty) {
      _showSuccessDialog('Course name and at least one chapter are required.');
      return;
    }

    setState(() {
      _isUploading = true;
    });
    _showLoadingDialog();
    
    try {
      // Convert chapters to the format expected by the service
      final allChapters = <Map<String, dynamic>>[];
      
      for (var chapter in _chapters) {
        final chapterName = chapter.nameController.text.trim();
        if (chapterName.isEmpty) continue;
        
        final lessons = <Map<String, dynamic>>[];
        for (var lesson in chapter.lessons) {
          final lessonTitle = lesson.titleController.text.trim();
          final lessonDescription = lesson.descriptionController.text.trim();
          
          Map<String, dynamic> lessonData = {
            'title': lessonTitle,
            'description': lessonDescription,
          };
          
          // Add PDF if exists
          if (lesson.pdfFile != null) {
            lessonData['pdf'] = {
              'fileName': lesson.pdfFile!['name'],
              if (kIsWeb && lesson.pdfFile!['bytes'] != null) 'bytes': lesson.pdfFile!['bytes'],
              if (!kIsWeb && lesson.pdfFile!['path'] != null) 'filePath': lesson.pdfFile!['path'],
            };
          }
          
          // Add Video if exists
          if (lesson.videoFile != null) {
            lessonData['video'] = {
              'fileName': lesson.videoFile!['name'],
              if (kIsWeb && lesson.videoFile!['bytes'] != null) 'bytes': lesson.videoFile!['bytes'],
              if (!kIsWeb && lesson.videoFile!['path'] != null) 'filePath': lesson.videoFile!['path'],
            };
          }
          
          lessons.add(lessonData);
        }
        
        allChapters.add({
          'title': chapterName,
          'lessons': lessons,
        });
      }

      final courseData = {
        'title': title,
        'description': description,
        'price': price,
        'durationDays': durationDays,
  'tag': tag,
  if (_courseBannerInfo != null) 'banner': _courseBannerInfo,
      };
      
      final created = await _courseService.createFullCourse(
        courseData: courseData,
        chapters: allChapters,
      );
      // created is a map: { course_id: <id>, section_ids: [ [sec1, sec2], [sec3] ] }
      if (created == null || created['course_id'] == null) {
        _hideLoadingDialog();
        setState(() {
          _isUploading = false;
        });
        _showSuccessDialog('Failed to create course.');
        return;
      }
      final courseId = created['course_id'] as String;
      _currentCourseId = courseId;
      // Map returned section ids back into local _chapters/lessons
      try {
        final sectionIds = created['section_ids'] as List<dynamic>? ?? [];
        for (int c = 0; c < sectionIds.length && c < _chapters.length; c++) {
          final chapterSectionList = List<String>.from(sectionIds[c] as List<dynamic>);
          final lessons = _chapters[c].lessons;
          for (int l = 0; l < chapterSectionList.length && l < lessons.length; l++) {
            lessons[l].sectionId = chapterSectionList[l];
          }
        }
      } catch (_) {
        // ignore mapping errors; section ids are optional for offline use
      }
      
      _hideLoadingDialog();
      setState(() {
        _isUploading = false;
      });
      
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
  final theme = AppThemeInstructor.lightTheme;
    
    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: AppThemeInstructor.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppThemeInstructor.surfaceWhite,
          elevation: 0,
          titleSpacing: 0,
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
          title: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              'Create New Course',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppThemeInstructor.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          centerTitle: false,
          actions: [
            
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Information Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppThemeInstructor.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppThemeInstructor.borderSubtle),
                    boxShadow: [
                      BoxShadow(
                        color: AppThemeInstructor.shadowLight.withOpacity(0.08),
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
                                colors: [AppThemeInstructor.primaryBlue.withOpacity(0.1), AppThemeInstructor.successGreen.withOpacity(0.1)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.school_outlined,
                              color: AppThemeInstructor.primaryBlue,
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
                                  color: AppThemeInstructor.textPrimary,
                                ),
                              ),
                              Text(
                                'Basic details about your course',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppThemeInstructor.textSecondary,
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
                      
                      _buildModernTextField(
                        controller: _tagController,
                        label: 'Category Tag',
                        hint: 'e.g., Mathematics, Science',
                        icon: Icons.tag_outlined,
                      ),
                      const SizedBox(height: 8),
                      if (_tagSuggestions.isNotEmpty) ...[
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tagSuggestions.map((s) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _tagController.text = s;
                                _tagSuggestions.clear();
                              });
                            },
                            child: Chip(label: Text(s)),
                          )).toList(),
                        ),
                        const SizedBox(height: 8),
                      ] else
                        const SizedBox(height: 8),
                      // Simple input field for course banner image upload
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _handleBannerUpload,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppThemeInstructor.primaryBlue,
                                      AppThemeInstructor.successGreen.withOpacity(0.8),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppThemeInstructor.primaryBlue.withOpacity(0.18),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(
                                      child: Text(
                                        _courseBannerInfo != null
                                            ? 'Banner Selected: ${_courseBannerInfo!['name'] ?? ''}'
                                            : 'Upload Course Banner',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          letterSpacing: 0.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Dynamic Chapters Section
                for (int chapterIndex = 0; chapterIndex < _chapters.length; chapterIndex++) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppThemeInstructor.surfaceWhite,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppThemeInstructor.borderSubtle),
                      boxShadow: [
                        BoxShadow(
                          color: AppThemeInstructor.shadowLight.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Chapter Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppThemeInstructor.primaryBlue.withOpacity(0.1), AppThemeInstructor.successGreen.withOpacity(0.1)],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.book_outlined,
                                color: AppThemeInstructor.primaryBlue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chapter ${chapterIndex + 1}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppThemeInstructor.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Add chapter details and lessons',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppThemeInstructor.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_chapters.length > 1)
                              IconButton(
                                onPressed: () => _removeChapter(chapterIndex),
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red.shade400,
                                  size: 20,
                                ),
                                tooltip: 'Remove Chapter',
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Chapter Name Field
                        _buildModernTextField(
                          controller: _chapters[chapterIndex].nameController,
                          label: 'Chapter Name',
                          hint: 'Enter chapter title',
                          icon: Icons.title_outlined,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Lessons Header
                        Row(
                          children: [
                            Icon(
                              Icons.playlist_play_outlined,
                              color: AppThemeInstructor.primaryBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lessons',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppThemeInstructor.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_chapters[chapterIndex].lessons.length} lesson${_chapters[chapterIndex].lessons.length != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppThemeInstructor.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Dynamic Lessons
                        for (int lessonIndex = 0; lessonIndex < _chapters[chapterIndex].lessons.length; lessonIndex++) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppThemeInstructor.backgroundLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppThemeInstructor.borderSubtle),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Lesson Header
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
                                          '${lessonIndex + 1}',
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
                                        'Lesson ${lessonIndex + 1}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppThemeInstructor.textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (_chapters[chapterIndex].lessons.length > 1)
                                      IconButton(
                                        onPressed: () => _removeLesson(chapterIndex, lessonIndex),
                                        icon: Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.red.shade400,
                                          size: 18,
                                        ),
                                        tooltip: 'Remove Lesson',
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                
                                // Lesson Title
                                _buildCompactTextField(
                                  controller: _chapters[chapterIndex].lessons[lessonIndex].titleController,
                                  hint: 'Lesson title',
                                  icon: Icons.play_lesson_outlined,
                                ),
                                const SizedBox(height: 12),
                                
                                // Lesson Description
                                _buildCompactTextField(
                                  controller: _chapters[chapterIndex].lessons[lessonIndex].descriptionController,
                                  hint: 'Lesson description (optional)',
                                  icon: Icons.notes_outlined,
                                ),
                                const SizedBox(height: 16),
                                
                                // File Upload Section
                                Row(
                                  children: [
                                    // PDF Upload
                                    Expanded(
                                      child: _buildFileUploadCard(
                                        onTap: () => _handlePdfUpload(chapterIndex, lessonIndex),
                                        fileInfo: _chapters[chapterIndex].lessons[lessonIndex].pdfFile,
                                        fileType: 'PDF',
                                        icon: Icons.picture_as_pdf,
                                        color: Colors.red.shade400,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Video Upload
                                    Expanded(
                                      child: _buildFileUploadCard(
                                        onTap: () => _handleVideoUpload(chapterIndex, lessonIndex),
                                        fileInfo: _chapters[chapterIndex].lessons[lessonIndex].videoFile,
                                        fileType: 'Video',
                                        icon: Icons.videocam_outlined,
                                        color: Colors.blue.shade400,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),
                                // Assessment Section (per-lesson)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppThemeInstructor.surfaceWhite,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppThemeInstructor.borderSubtle),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Assessment',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: AppThemeInstructor.textPrimary,
                                            ),
                                          ),
                                          // Toggle AI quiz generator (checkbox)
                                          Row(
                                            children: [
                                              const Text('AI quiz generator', style: TextStyle(fontSize: 12)),
                                              const SizedBox(width: 8),
                                              Checkbox(
                                                value: _chapters[chapterIndex].lessons[lessonIndex].aiAssessmentEnabled,
                                                onChanged: (val) {
                                                  setState(() {
                                                    _chapters[chapterIndex].lessons[lessonIndex].aiAssessmentEnabled = val ?? false;
                                                    // when enabling AI, clear manual questions
                                                    if (_chapters[chapterIndex].lessons[lessonIndex].aiAssessmentEnabled) {
                                                      _chapters[chapterIndex].lessons[lessonIndex].manualQuestions.clear();
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // If AI is enabled, show a short explanation and hide manual options
                                      if (_chapters[chapterIndex].lessons[lessonIndex].aiAssessmentEnabled) ...[
                                        Text(
                                          'AI will generate a short quiz for this lesson.',
                                          style: TextStyle(color: AppThemeInstructor.textSecondary, fontSize: 12),
                                        ),
                                        const SizedBox(height: 8),
                                        // Quick-select options for number of quizzes (5, 10, 15)
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          
                                          children: [
                                            Text(
                                              'Number of quizzes:',
                                              style: TextStyle(
                                                color: AppThemeInstructor.textPrimary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Wrap(
                                              spacing: 8,
                                              children: [5, 10, 15].map((count) {
                                                final selected = _chapters[chapterIndex].lessons[lessonIndex].aiQuizCount == count;
                                                return ChoiceChip(
                                                  label: Text('$count'),
                                                  selected: selected,
                                                  onSelected: (sel) {
                                                    if (sel) {
                                                      setState(() {
                                                        _chapters[chapterIndex].lessons[lessonIndex].aiQuizCount = count;
                                                      });
                                                    }
                                                  },
                                                  selectedColor: AppThemeInstructor.primaryBlue.withOpacity(0.8),
                                                  backgroundColor: AppThemeInstructor.backgroundLight,
                                                  labelStyle: TextStyle(color: selected ? AppThemeInstructor.surfaceWhite : AppThemeInstructor.textPrimary),
                                                );
                                              }).toList(),
                                            ),
                                            const SizedBox(height: 12),
                                            ElevatedButton(
                                              onPressed: () async {
                                                // Trigger AI generation for this lesson
                                                await _generateQuizForLesson(chapterIndex, lessonIndex);
                                              },
                                              child: const Text('Generate Quiz'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Status output
                                        if (_chapters[chapterIndex].lessons[lessonIndex].aiStatus != null) ...[
                                          Text(
                                            _chapters[chapterIndex].lessons[lessonIndex].aiStatus!,
                                            style: TextStyle(color: AppThemeInstructor.primaryBlue),
                                          ),
                                          const SizedBox(height: 6),
                                        ],
                                      ] else ...[
                                        // Manual quiz area
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 12),
                                            // Show existing quizzes status or add button
                                            if (_chapters[chapterIndex].lessons[lessonIndex].hasManualQuizzes()) ...[
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: () => _navigateToManualQuizPage(chapterIndex, lessonIndex),
                                                      icon: const Icon(Icons.edit_outlined, size: 16),
                                                      label: const Text('Edit Quizzes'),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppThemeInstructor.primaryBlue,
                                                        foregroundColor: AppThemeInstructor.surfaceWhite,
                                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: () => _showQuizzesReadOnly(chapterIndex, lessonIndex),
                                                      icon: const Icon(Icons.visibility_outlined, size: 16),
                                                      label: const Text('Show Quizzes'),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: AppThemeInstructor.backgroundLight,
                                                        foregroundColor: AppThemeInstructor.textPrimary,
                                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(8),
                                                          side: BorderSide(color: AppThemeInstructor.borderSubtle),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${_chapters[chapterIndex].lessons[lessonIndex].getQuizCount()} quiz${_chapters[chapterIndex].lessons[lessonIndex].getQuizCount() != 1 ? 'zes' : ''} added',
                                                style: TextStyle(
                                                  color: AppThemeInstructor.successGreen,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ] else ...[
                                              SizedBox(
                                                width: double.infinity,
                                                child: ElevatedButton.icon(
                                                  onPressed: () => _navigateToManualQuizPage(chapterIndex, lessonIndex),
                                                  icon: const Icon(Icons.quiz_outlined, size: 18),
                                                  label: const Text('Add Quizzes Manually'),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: AppThemeInstructor.primaryBlue,
                                                    foregroundColor: AppThemeInstructor.surfaceWhite,
                                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        // Add Lesson Button
                        Container(
                          width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppThemeInstructor.primaryBlue.withOpacity(0.3),
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                          child: InkWell(
                            onTap: () => _addLessonToChapter(chapterIndex),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
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
                                    'Add Lesson',
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
                        ),

                        const SizedBox(height: 16),

                        // Per-chapter Assessment Section
                        // Container(
                        //   padding: const EdgeInsets.all(20),
                        //   margin: const EdgeInsets.only(top: 12),
                        //   decoration: BoxDecoration(
                        //     color: AppThemeInstructor.surfaceWhite,
                        //     borderRadius: BorderRadius.circular(12),
                        //     border: Border.all(color: AppThemeInstructor.borderSubtle),
                        //   ),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Row(
                        //         children: [
                        //           Container(
                        //             padding: const EdgeInsets.all(8),
                        //             decoration: BoxDecoration(
                        //               gradient: LinearGradient(
                        //                 colors: [Colors.orange.withOpacity(0.08), Colors.deepOrange.withOpacity(0.08)],
                        //               ),
                        //               borderRadius: BorderRadius.circular(8),
                        //             ),
                        //             child: Icon(
                        //               Icons.quiz_outlined,
                        //               color: Colors.orange,
                        //               size: 20,
                        //             ),
                        //           ),
                        //           const SizedBox(width: 12),
                        //           Text(
                        //             'Assessment (Chapter ${chapterIndex + 1})',
                        //             style: TextStyle(
                        //               fontSize: 16,
                        //               fontWeight: FontWeight.w600,
                        //               color: AppThemeInstructor.textPrimary,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       const SizedBox(height: 12),
                        //       _buildModernTextField(
                        //         controller: _chapters[chapterIndex].questionTitleController,
                        //         label: 'Question Title',
                        //         hint: 'Enter question for this chapter',
                        //         icon: Icons.help_outline,
                        //       ),
                        //       const SizedBox(height: 12),
                        //       Column(
                        //         crossAxisAlignment: CrossAxisAlignment.start,
                        //         children: [
                        //           Text(
                        //             'Question Type',
                        //             style: TextStyle(
                        //               fontSize: 14,
                        //               fontWeight: FontWeight.w600,
                        //               color: AppThemeInstructor.textPrimary,
                        //             ),
                        //           ),
                        //           const SizedBox(height: 8),
                        //           Container(
                        //             decoration: BoxDecoration(
                        //               color: AppThemeInstructor.backgroundLight,
                        //               borderRadius: BorderRadius.circular(12),
                        //               border: Border.all(color: AppThemeInstructor.borderSubtle),
                        //             ),
                        //             child: DropdownButtonFormField<String>(
                        //               value: _chapters[chapterIndex].selectedQuestionType,
                        //               decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        //               items: const [
                        //                 DropdownMenuItem(value: 'Mcq', child: Text('Multiple Choice')),
                        //                 DropdownMenuItem(value: 'Code', child: Text('Code Challenge')),
                        //                 DropdownMenuItem(value: 'Text', child: Text('Written Answer')),
                        //               ],
                        //               onChanged: (value) {
                        //                 setState(() {
                        //                   _chapters[chapterIndex].selectedQuestionType = value ?? 'Mcq';
                        //                 });
                        //               },
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       const SizedBox(height: 12),
                        //       _buildModernTextField(
                        //         controller: _chapters[chapterIndex].questionMarksController,
                        //         label: 'Total Marks',
                        //         hint: 'Points for this question',
                        //         icon: Icons.star_outline,
                        //         keyboardType: TextInputType.number,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Add Chapter Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppThemeInstructor.primaryBlue.withOpacity(0.1),
                        AppThemeInstructor.successGreen.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppThemeInstructor.primaryBlue.withOpacity(0.3)),
                  ),
                  child: InkWell(
                    onTap: _addNewChapter,
                    borderRadius: BorderRadius.circular(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppThemeInstructor.primaryBlue, AppThemeInstructor.successGreen],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Add New Chapter',
                          style: TextStyle(
                            color: AppThemeInstructor.primaryBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create another chapter for your course',
                          style: TextStyle(
                            color: AppThemeInstructor.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Publish Course Button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppThemeInstructor.primaryBlue, AppThemeInstructor.successGreen.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppThemeInstructor.primaryBlue.withOpacity(0.4),
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
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for file upload cards
  Widget _buildFileUploadCard({
    required VoidCallback onTap,
    required Map<String, dynamic>? fileInfo,
    required String fileType,
    required IconData icon,
    required Color color,
  }) {
    // Simpler, consistent card (matches edit_course_screen.dart)
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              fileInfo != null
                  ? '${fileInfo['name'] ?? 'Selected'}'
                  : 'Upload $fileType',
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
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
            color: AppThemeInstructor.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppThemeInstructor.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppThemeInstructor.borderSubtle),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            style: TextStyle(
              fontSize: 16,
              color: AppThemeInstructor.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppThemeInstructor.textSecondary,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: AppThemeInstructor.textSecondary,
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
        color: AppThemeInstructor.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeInstructor.borderSubtle),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: 14,
          color: AppThemeInstructor.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: AppThemeInstructor.textSecondary,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: AppThemeInstructor.textSecondary,
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

// Data models for dynamic structure
class ChapterData {
  final TextEditingController nameController;
  final List<LessonData> lessons;
  // per-chapter assessment controllers
  final TextEditingController questionTitleController;
  final TextEditingController questionMarksController;
  String selectedQuestionType;

  ChapterData({
    required this.nameController,
    required this.lessons,
    required this.questionTitleController,
    required this.questionMarksController,
    this.selectedQuestionType = 'Mcq',
  });

  void dispose() {
    nameController.dispose();
    for (var lesson in lessons) {
      lesson.dispose();
    }
  questionTitleController.dispose();
  questionMarksController.dispose();
  }
}

class LessonData {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  Map<String, dynamic>? pdfFile;
  Map<String, dynamic>? videoFile;

  // DB section id (nullable) — populated when course/sections are persisted and IDs are known
  String? sectionId;

  // Assessment related
  bool aiAssessmentEnabled;
  List<ManualQuestion> manualQuestions;
  List<ManualQuiz> manualQuizzes; // New quiz system
  // How many quizzes AI should generate for this lesson
  int aiQuizCount;
  // AI generation status and result
  String? aiStatus;
  String? generatedAssessmentId;

  LessonData({
    required this.titleController,
    required this.descriptionController,
    this.pdfFile,
    this.videoFile,
    this.aiAssessmentEnabled = false,
    List<ManualQuestion>? manualQuestions,
    List<ManualQuiz>? manualQuizzes,
    this.aiQuizCount = 5,
  }) : manualQuestions = manualQuestions ?? [],
       manualQuizzes = manualQuizzes ?? [];

  bool hasManualQuizzes() {
    return manualQuizzes.isNotEmpty && manualQuizzes.any((quiz) => quiz.isValid);
  }

  int getQuizCount() {
    return manualQuizzes.where((quiz) => quiz.isValid).length;
  }

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    for (var q in manualQuestions) {
      q.dispose();
    }
    for (var quiz in manualQuizzes) {
      quiz.dispose();
    }
  }
}

class ManualQuestion {
  final TextEditingController questionController = TextEditingController();
  final TextEditingController marksController = TextEditingController();

  void dispose() {
    questionController.dispose();
    marksController.dispose();
  }
}
