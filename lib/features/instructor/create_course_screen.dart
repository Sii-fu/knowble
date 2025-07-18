
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:knowble_app/core/services/Instructor/course_service.dart';
import 'package:knowble_app/core/services/Instructor/questionai_service.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  String? _createdCourseId;
  // Question section controllers
  final TextEditingController _questionTitleController = TextEditingController();
  final TextEditingController _questionMarksController = TextEditingController();

  // Helper to get the current courseId (you may want to store this after course creation)
  Future<String?> _getCurrentCourseId() async {
    return _createdCourseId;
  }
  // Gemini API key (replace with your actual key or load from secure storage)
  final String _geminiApiKey = 'AIzaSyAUoA_MGBSzZHSIQsMRZ4BgM6vQcKhM9pI';
  late final QuestionAIService _questionAIService;


  final CourseService _courseService = CourseService();
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseDescriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _durationDaysController = TextEditingController();
  final TextEditingController _chapterController = TextEditingController();
  final TextEditingController _chapterNameController = TextEditingController();
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
    _chapterController.text = '';
    _chapterNameController.text = '';
    _lesson1Controller.text = '';
    _lessonCountController.text = '';
    _updateLessonControllers();

    _questionAIService = QuestionAIService(geminiApiKey: _geminiApiKey);
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
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.green[600],
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Saved Successfully',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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

  void _handleQuestionUpload() {
    _showSuccessDialog('Question uploaded successfully!');
  }

  Future<void> _handleFinalUpload() async {
    final title = _courseNameController.text.trim();
    final description = _courseDescriptionController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final durationDays = int.tryParse(_durationDaysController.text.trim()) ?? 0;
    final chapterOrder = int.tryParse(_chapterController.text.trim()) ?? 1;
    final chapterName = _chapterNameController.text.trim();
    final lessonCount = _lessonControllers.length;

    if (title.isEmpty || chapterName.isEmpty) {
      _showSuccessDialog('Course name and chapter name are required.');
      return;
    }

    try {
      // 1. Insert course
      final courseId = await _courseService.createCourse(
        title: title,
        description: description,
        price: price,
        durationDays: durationDays,
      );
      if (courseId == null) {
        _showSuccessDialog('Failed to create course.');
        return;
      }
      setState(() {
        _createdCourseId = courseId;
      });

      // 2. Insert module (chapter)
      final moduleId = await _courseService.createModule(
        courseId: courseId,
        title: chapterName,
        order: chapterOrder,
      );
      if (moduleId == null) {
        _showSuccessDialog('Failed to create module.');
        return;
      }

      // 3. Insert sections (lessons)
      List<String?> sectionIds = [];
      for (int i = 0; i < lessonCount; i++) {
        final lessonTitle = _lessonControllers[i].text.trim();
        if (lessonTitle.isEmpty) {
          sectionIds.add(null);
          continue;
        }
        final sectionId = await _courseService.createSection(
          moduleId: moduleId,
          title: lessonTitle,
          order: i + 1,
        );
        sectionIds.add(sectionId);
      }

      // 4. Insert PDF content for each lesson if selected
      for (int i = 0; i < lessonCount; i++) {
        final pdfInfo = i < _lessonPdfInfos.length ? _lessonPdfInfos[i] : null;
        final sectionId = sectionIds[i];
        if (pdfInfo != null && sectionId != null) {
          String? publicUrl;
          if (kIsWeb && pdfInfo['bytes'] != null) {
            publicUrl = await _courseService.uploadPdfToStorage(
              bytes: pdfInfo['bytes'],
              fileName: pdfInfo['name'],
            );
          } else if (!kIsWeb && pdfInfo['path'] != null) {
            publicUrl = await _courseService.uploadPdfToStorage(
              filePath: pdfInfo['path'],
              fileName: pdfInfo['name'],
            );
          }
          if (publicUrl == null) {
            print('PDF upload failed for lesson $i');
            _showSuccessDialog('PDF upload failed for lesson ${i + 1}');
            continue;
          }
          final contentId = await _courseService.createContent(
            sectionId: sectionId,
            type: 'pdf',
            url: publicUrl,
            order: 1,
          );
          if (contentId == null) {
            print('Failed to insert content for lesson $i');
            _showSuccessDialog('Failed to insert content for lesson ${i + 1}');
          }
        }
      }

      _showSuccessDialog('Course created and uploaded successfully!');
    } catch (e) {
      _showSuccessDialog('Error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create New Course',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Name
            const Text(
              'Course Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _courseNameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Course Description
            const Text(
              'Course Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _courseDescriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Price
            const Text(
              'Price',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  hintText: 'Enter price',
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Duration (days)
            const Text(
              'Duration (days)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _durationDaysController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  hintText: 'Enter duration in days',
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Chapter and Lesson Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Chapter Section
                SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Chapter',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          controller: _chapterController,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            hintText: 'Chapter 1',
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  padding: const EdgeInsets.only(left: 0, right: 4, bottom: 8),
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateCourseScreen()),
                    );
                  },
                ),
                const SizedBox(width: 8),
                // Lesson Section
                SizedBox(
                  width: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lesson',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: TextField(
                          controller: _lessonCountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            hintText: 'Number',
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Chapter Name
            const Text(
              'Chapter Name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _chapterNameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Dynamic Lesson Fields
            for (int i = 0; i < _lessonControllers.length; i++) ...[
              Text(
                'Lesson ${i + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _lessonControllers[i],
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintText: 'Lesson Title',
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: InkWell(
                  onTap: () => _handlePdfUpload(i),
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red[400]),
                        const SizedBox(width: 8),
                        Text(
                          _lessonPdfInfos[i] != null ? 'PDF Selected' : 'Upload PDF',
                          style: TextStyle(
                            color: _lessonPdfInfos[i] != null ? Colors.red[400] : Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            
            // Question Section
            const Text(
              'Question',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            // Title Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _questionTitleController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  hintText: 'Question Title',
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Type Dropdown
            Row(
              children: [
                const Text(
                  'Type:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedQuestionType,
                    items: const [
                      DropdownMenuItem(value: 'Mcq', child: Text('Mcq')),
                      DropdownMenuItem(value: 'Code', child: Text('Code')),
                      DropdownMenuItem(value: 'Text', child: Text('Text')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedQuestionType = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Total Marks Field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: _questionMarksController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  hintText: 'Total Marks',
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Example: Use course name as assessment title, type as selected, total marks from field
                      final courseId = await _getCurrentCourseId();
                      if (courseId == null) {
                        _showSuccessDialog('Please create the course first.');
                        return;
                      }
                      try {
                        await _questionAIService.generateAndStoreMCQs(
                          courseId: courseId,
                          assessmentTitle: _questionTitleController.text.trim(),
                          type: _selectedQuestionType.toLowerCase(),
                          totalMarks: int.tryParse(_questionMarksController.text.trim()) ?? 0,
                        );
                        _showSuccessDialog('AI-generated questions uploaded!');
                      } catch (e) {
                        _showSuccessDialog('AI generation failed: ${e.toString()}');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Generate Question Using AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleQuestionUpload,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Upload your Question',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Upload Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _handleFinalUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Upload',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}