import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/student/course_services.dart';
import '../../data/models/course.dart';
import '../../data/models/module.dart';
import '../../data/models/section.dart';
import '../../data/models/content.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chatbot/chatbotpage.dart';
import 'pdf_viewer_page.dart';
import 'chat/chat_detail_page.dart';
import 'courses_lessons.dart';



class CourseDetailPage extends StatefulWidget {
  final String courseId;
  const CourseDetailPage({required this.courseId, super.key});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  bool _enrolled = false;
  final CourseServices _service = CourseServices();
  Course? _course;
  List<Module> _modules = [];
  List<Section> _sections = [];
  List<Content> _contents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourseDetails();
  }

  Future<void> _loadCourseDetails() async {
    final course = await _service.fetchCourseById(widget.courseId);
    List<Module> modules = [];
    List<Section> allSections = [];
    List<Content> allContents = [];
    if (course != null) {
      modules = await _service.fetchModules(course.id);
      for (final module in modules) {
        final sections = await _service.fetchSections(module.id);
        allSections.addAll(sections);
        for (final section in sections) {
          final contents = await _service.fetchContents(section.id);
          allContents.addAll(contents);
        }
      }
      // Check enrollment
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final enrollments = await _service.fetchUserEnrollments(userId);
      final enrolled = enrollments.any((e) => e.courseId == widget.courseId);
      _enrolled = enrolled;
    }
    setState(() {
      _course = course;
      _modules = modules;
      _sections = allSections;
      _contents = allContents;
      _isLoading = false;
    });
  }

  Future<void> _startInstructorChat() async {
    try {
      // Get course instructor information
      final instructorId = _course?.instructorId;
      if (instructorId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Instructor information not available'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get current user
      final currentUserId = Supabase.instance.client.auth.currentUser?.id;
      if (currentUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to chat with instructor'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Get instructor details from database
      final instructorData = await Supabase.instance.client
          .from('users')
          .select('name, profile_pic')
          .eq('id', instructorId)
          .maybeSingle();

      final instructorName = instructorData?['name'] ?? 'Instructor';
      final profileImage = instructorData?['profile_pic'];

      // Navigate to chat detail page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailPage(
            courseId: widget.courseId,
            receiverId: instructorId,
            instructorName: instructorName,
            courseCode: _course!.title,
            profileImage: profileImage,
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error starting chat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_course == null) {
      return const Scaffold(body: Center(child: Text('Course not found')));
    }
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_course!.title, style: const TextStyle(color: AppTheme.textPrimary)),
        
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Banner image
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _course!.banner.startsWith('http')
                      ? Image.network(_course!.banner, width: double.infinity, height: 180, fit: BoxFit.cover)
                      : Image.asset('assets/images/default_course.jpg', width: double.infinity, height: 180, fit: BoxFit.cover),
                ),
                const SizedBox(height: 16),
                // Chatbot button (prominent, only for enrolled)
                if (_enrolled)
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                      label: const Text('Ask AI Assistant', style: TextStyle(fontSize: 16, color: Colors.white)),
                      onPressed: () {
                        // Prepare PDF contents for context
                        List<Map<String, dynamic>> pdfContents = _contents
                            .where((content) => content.type == 'pdf')
                            .map((content) => {
                              'id': content.id,
                              'title': content.title,
                              'url': content.url,
                              // Note: Text content will be extracted on-demand in the chatbot
                            })
                            .toList();
                        
                        // DEBUG: Print actual parameters being sent to ChatBot
                        print('🏫 COURSE DETAILS → CHATBOT PARAMETERS:');
                        print('courseTitle parameter: "${_course!.title}"');
                        print('courseDescription parameter: "${_course!.description}"');
                        print('pdfContents parameter: $pdfContents');
                        print('════════════════════════════════════════');
                        
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatBotPage(
                              courseTitle: _course!.title,
                              courseDescription: _course!.description,
                              pdfContents: pdfContents,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                
                // Chat with instructor button (only for enrolled)
                if (_enrolled)
                  const SizedBox(height: 12),
                if (_enrolled)
                  Center(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      icon: const Icon(Icons.person_outline, color: Colors.white),
                      label: const Text('Chat with Instructor', style: TextStyle(fontSize: 16, color: Colors.white)),
                      onPressed: () {
                        // Navigate to instructor chat
                        _startInstructorChat();
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Text(_course!.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                const SizedBox(height: 16),
                const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(
                  _course!.description,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                const Text('Chapters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),

                // Dynamic modules/sections/contents with access logic
                ..._modules.asMap().entries.map((moduleEntry) {
                  final moduleIndex = moduleEntry.key;
                  final module = moduleEntry.value;
                  final isFirstChapter = moduleIndex == 0;
                  // access control: locked chapters when not enrolled
                  // If not enrolled and not first chapter, show blurred, non-expandable tile
                  if (!_enrolled && moduleIndex > 0) {
                    return Opacity(
                      opacity: 0.5,
                      child: ListTile(
                        title: Text(
                          'Chapter ${moduleIndex + 1}: ${module.title}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: const Icon(Icons.lock, color: Colors.red, size: 18),
                        enabled: false,
                      ),
                    );
                  }
                  // Otherwise, show normal ExpansionTile
                  return ExpansionTile(
                    title: Row(
                      children: [
                        Text('Chapter ${moduleIndex + 1}: ${module.title}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                        if (!_enrolled && moduleIndex == 0 && _modules.length > 1)
                          const Icon(Icons.lock_open, color: Colors.green, size: 18),
                      ],
                    ),
                    initiallyExpanded: isFirstChapter,
                    children: [
                      ..._sections.where((section) => section.moduleId == module.id).toList().asMap().entries.map((sectionEntry) {
                        final sectionIndex = sectionEntry.key;
                        final section = sectionEntry.value;
                        final isFirstSection = isFirstChapter && sectionIndex == 0;
                        final sectionLocked = !_enrolled && isFirstChapter && !isFirstSection;
                        if (!_enrolled && !isFirstChapter) {
                          // Should never reach here, but just in case
                          return const SizedBox.shrink();
                        }
                        return ExpansionTile(
                          title: Row(
                            children: [
                              Text(section.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                              if (sectionLocked)
                                const Icon(Icons.lock, color: Colors.red, size: 18),
                            ],
                          ),
                          initiallyExpanded: isFirstSection,
                          children: [
                            ..._contents.where((content) => content.sectionId == section.id && content.type == 'pdf').map((content) {
                              final contentLocked = sectionLocked;
                              return ListTile(
                                leading: contentLocked
                                    ? const Icon(Icons.lock, color: Colors.red)
                                    : const Icon(Icons.picture_as_pdf, color: Colors.red),
                                title: Text(content.title),
                                enabled: _enrolled,
                                onTap: _enrolled
                                    ? () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PDFViewerPage(
                                              pdfUrl: content.url,
                                              title: content.title,
                                              contentId: content.id,
                                              courseId: widget.courseId,
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                subtitle: contentLocked
                                    ? const Text('Locked', style: TextStyle(color: Colors.red))
                                    : null,
                              );
                            }),
                          ],
                        );
                      }),
                    ],
                  );
                }),

                if (!_enrolled) ...[
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryTeal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
                      ),
                      onPressed: () async {
                        if (!_enrolled) {
                          final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
                          await _service.enrollCourse(userId, widget.courseId);
                          setState(() {
                            _enrolled = true;
                          });
                          // Show success dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text('Successfully Enrolled!', style: TextStyle(fontWeight: FontWeight.bold)),
                              content: const Text('You have been enrolled in this course.'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CourseLessonsPage(courseId: widget.courseId),
                                      ),
                                    );
                                  },
                                  child: const Text('Continue'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Start Course', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

