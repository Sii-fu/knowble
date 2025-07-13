
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:knowble_app/core/services/Instructor/course_service.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
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
  List<TextEditingController> _lessonDescriptionControllers = [];

  String selectedLessonCount = '4 Lesson';
  
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
  }

  void _updateLessonControllers() {
    int lessonCount = int.tryParse(selectedLessonCount.split(' ')[0]) ?? 4;
    // Add lesson title controllers
    if (_lessonControllers.length < lessonCount) {
      for (int i = _lessonControllers.length; i < lessonCount; i++) {
        _lessonControllers.add(TextEditingController());
      }
    } else if (_lessonControllers.length > lessonCount) {
      _lessonControllers = _lessonControllers.sublist(0, lessonCount);
    }
    // Add lesson description controllers
    if (_lessonDescriptionControllers.length < lessonCount) {
      for (int i = _lessonDescriptionControllers.length; i < lessonCount; i++) {
        _lessonDescriptionControllers.add(TextEditingController());
      }
    } else if (_lessonDescriptionControllers.length > lessonCount) {
      _lessonDescriptionControllers = _lessonDescriptionControllers.sublist(0, lessonCount);
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


  Future<void> _handleMediaUpload(String lessonName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.isNotEmpty) {
      // You can access the selected file using result.files.first
      // For now, just show a success dialog with the file name
      String fileName = result.files.first.name;
      _showSuccessDialog('$lessonName: "$fileName" selected successfully!');
    } else {
      // User canceled the picker
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
      for (int i = 0; i < lessonCount; i++) {
        final lessonTitle = _lessonControllers[i].text.trim();
        final lessonDescription = _lessonDescriptionControllers[i].text.trim();
        if (lessonTitle.isEmpty) continue;
        await _courseService.createSection(
          moduleId: moduleId,
          title: lessonTitle,
          order: i + 1,
          description: lessonDescription,
        );
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
          'Create New Chapter',
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
              const SizedBox(height: 8),
              // Lesson Description Field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: TextField(
                  controller: _lessonDescriptionControllers[i],
                  maxLines: 2,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                    hintText: 'Lesson Description',
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
                  onTap: () => _handleMediaUpload('Lesson ${i + 1}'),
                  borderRadius: BorderRadius.circular(8),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Add Media',
                          style: TextStyle(
                            color: Colors.grey,
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
            
            // Question Section (Additional as requested)
            const Text(
              'Question',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: InkWell(
                onTap: _handleQuestionUpload,
                borderRadius: BorderRadius.circular(8),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Upload Question',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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