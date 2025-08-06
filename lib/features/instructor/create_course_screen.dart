
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:knowble_app/core/services/Instructor/course_service.dart';
import 'package:knowble_app/core/services/Instructor/questionai_service.dart';
import 'package:flutter/foundation.dart';

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
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
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
            if (_currentChapterIndex == 0) ...[
              // Only show course meta fields on first page
              const Text('Course Name', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                child: TextField(
                  controller: _courseNameController,
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: 'Enter course name'),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                child: TextField(
                  controller: _courseDescriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: 'Enter description'),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                child: TextField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: 'Enter price'),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Duration (days)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                child: TextField(
                  controller: _durationDaysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: 'Enter duration in days'),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Tag', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                child: TextField(
                  controller: _tagController,
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: 'Enter tag'),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Total Chapters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                child: TextField(
                  controller: _totalChaptersController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: 'Enter total chapters'),
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
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
              const SizedBox(height: 16),
            ],
            // Per-chapter fields
            Text('Chapter ${_currentChapterIndex + 1} Name', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
              child: TextField(
                controller: _chapterNameController,
                decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: 'Enter chapter name'),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                onChanged: (value) {
                  if (_chapterNames.isNotEmpty && _currentChapterIndex < _chapterNames.length) {
                    setState(() {
                      _chapterNames[_currentChapterIndex] = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text('Total Lessons under this Chapter', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
              child: TextField(
                controller: _totalLessonsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: 'Enter total lessons for this chapter'),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
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
            const SizedBox(height: 16),
            for (int i = 0; i < _lessonControllers.length; i++) ...[
              Text('Lesson ${i + 1} Name', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                child: TextField(
                  controller: _lessonControllers[i],
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: 'Enter lesson name'),
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                child: TextField(
                  decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: 'Enter lesson description'),
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 60,
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
                child: InkWell(
                  onTap: () => _handlePdfUpload(i),
                  borderRadius: BorderRadius.circular(8),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red[400]),
                        const SizedBox(width: 8),
                        Text(_lessonPdfInfos[i] != null ? 'PDF Selected' : 'Upload PDF', style: TextStyle(color: _lessonPdfInfos[i] != null ? Colors.red[400] : Colors.grey, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            // Question Section
            const Text('Question', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
              child: TextField(
                controller: _questionTitleController,
                decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: 'Question Title'),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Type:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
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
                    decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
              child: TextField(
                controller: _questionMarksController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16), hintText: 'Total Marks'),
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (_currentChapterIndex < _chapterNames.length - 1)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Save current chapter before moving to next
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
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[600], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                      child: const Text('Next', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                if (_currentChapterIndex == _chapterNames.length - 1)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleFinalUpload,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                      child: const Text('Upload All Chapters', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}