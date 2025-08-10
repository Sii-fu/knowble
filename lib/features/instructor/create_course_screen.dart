
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:knowble_app/core/services/Instructor/course_service.dart';
import 'package:knowble_app/core/services/Instructor/questionai_service.dart';
import 'package:flutter/foundation.dart';
import '../../config/theme.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  bool _isUploading = false;

  // Course basic info controllers
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseDescriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationDaysController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  // Dynamic chapters and lessons structure
  List<ChapterData> _chapters = [];

  // Question section controllers
  final TextEditingController _questionTitleController = TextEditingController();
  final TextEditingController _questionMarksController = TextEditingController();
  String _selectedQuestionType = 'Mcq';

  // Course service and other services
  final CourseService _courseService = CourseService();
  final String _geminiApiKey = 'AIzaSyAUoA_MGBSzZHSIQsMRZ4BgM6vQcKhM9pI';
  late final QuestionAIService _questionAIService;
  String? _createdCourseId;

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

  @override
  void initState() {
    super.initState();
    _questionAIService = QuestionAIService(geminiApiKey: _geminiApiKey);
    
    // Initialize with one chapter and one lesson
    _addNewChapter();
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseDescriptionController.dispose();
    _priceController.dispose();
    _durationDaysController.dispose();
    _tagController.dispose();
    _questionTitleController.dispose();
    _questionMarksController.dispose();
    
    // Dispose all chapters and lessons
    for (var chapter in _chapters) {
      chapter.dispose();
    }
    
    super.dispose();
  }

  // Dynamic chapter and lesson management
  void _addNewChapter() {
    setState(() {
      _chapters.add(ChapterData(
        nameController: TextEditingController(),
        lessons: [_createNewLesson()],
      ));
    });
  }

  LessonData _createNewLesson() {
    return LessonData(
      titleController: TextEditingController(),
      descriptionController: TextEditingController(),
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
      };
      
      final courseId = await _courseService.createFullCourse(
        courseData: courseData,
        chapters: allChapters,
      );
      
      _hideLoadingDialog();
      setState(() {
        _isUploading = false;
        _createdCourseId = courseId;
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
          titleSpacing: 0,
          leading: Container(
            margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 18),
              onPressed: () => Navigator.pop(context),
              padding: const EdgeInsets.only(left: 4),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              'Create New Course',
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          centerTitle: false,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryTeal.withOpacity(0.1), AppTheme.successGreen.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.save_outlined, color: AppTheme.primaryTeal, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Draft',
                    style: TextStyle(
                      color: AppTheme.primaryTeal,
                      fontSize: 13,
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
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      
                      _buildModernTextField(
                        controller: _tagController,
                        label: 'Category Tag',
                        hint: 'e.g., Mathematics, Science',
                        icon: Icons.tag_outlined,
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
                        // Chapter Header
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
                                    'Chapter ${chapterIndex + 1}',
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
                              color: AppTheme.successGreen,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lessons',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_chapters[chapterIndex].lessons.length} lesson${_chapters[chapterIndex].lessons.length != 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
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
                              color: AppTheme.backgroundLight,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.borderSubtle),
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
                                        color: AppTheme.primaryTeal,
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
                                          color: AppTheme.textPrimary,
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
                              ],
                            ),
                          ),
                        ],
                        
                        // Add Lesson Button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppTheme.primaryTeal.withOpacity(0.3),
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
                                    color: AppTheme.primaryTeal,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Add Lesson',
                                    style: TextStyle(
                                      color: AppTheme.primaryTeal,
                                      fontSize: 14,
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
                  const SizedBox(height: 16),
                ],
                
                // Add Chapter Button
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryTeal.withOpacity(0.1),
                        AppTheme.successGreen.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.3)),
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
                              colors: [AppTheme.primaryTeal, AppTheme.successGreen],
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
                            color: AppTheme.primaryTeal,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create another chapter for your course',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                                'Add questions for the course assessment',
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
                
                // Publish Course Button
                Container(
                  width: double.infinity,
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
    final bool hasFile = fileInfo != null;
    
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasFile ? color.withOpacity(0.5) : AppTheme.borderSubtle,
          width: hasFile ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: hasFile ? color.withOpacity(0.1) : AppTheme.textSecondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      hasFile ? Icons.check_circle_outline : icon,
                      color: hasFile ? color : AppTheme.textSecondary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasFile ? '$fileType Added' : 'Add $fileType',
                      style: TextStyle(
                        color: hasFile ? color : AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (hasFile) ...[
                const SizedBox(height: 4),
                Text(
                  fileInfo['name'] ?? 'Unknown file',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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

// Data models for dynamic structure
class ChapterData {
  final TextEditingController nameController;
  final List<LessonData> lessons;

  ChapterData({
    required this.nameController,
    required this.lessons,
  });

  void dispose() {
    nameController.dispose();
    for (var lesson in lessons) {
      lesson.dispose();
    }
  }
}

class LessonData {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  Map<String, dynamic>? pdfFile;
  Map<String, dynamic>? videoFile;

  LessonData({
    required this.titleController,
    required this.descriptionController,
    this.pdfFile,
    this.videoFile,
  });

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
  }
}