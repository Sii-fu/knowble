import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/student/course_services.dart';
import '../../data/models/course.dart';
import '../../data/models/module.dart';
import '../../data/models/section.dart';
import '../../data/models/content.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_course == null) {
      return const Scaffold(body: Center(child: Text('Course not found')));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
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
                Text(_course!.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                // Removed progress bar and 5/12
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
                  final isSecondChapter = moduleIndex == 1;
                  final isLocked = !_enrolled && moduleIndex > 1;
                  final isBlurred = !_enrolled && isSecondChapter;
                  return Opacity(
                    opacity: isBlurred ? 0.5 : 1.0,
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Text('Chapter ${moduleIndex + 1}: ${module.title}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
                          if (!_enrolled && (isLocked || isBlurred))
                            const Icon(Icons.lock, color: Colors.red, size: 18),
                        ],
                      ),
                      initiallyExpanded: isFirstChapter || (_enrolled && !isLocked),
                      children: [
                        ..._sections.where((section) => section.moduleId == module.id).toList().asMap().entries.map((sectionEntry) {
                          final sectionIndex = sectionEntry.key;
                          final section = sectionEntry.value;
                          final isFirstSection = isFirstChapter && sectionIndex == 0;
                          final sectionLocked = !_enrolled && isFirstChapter && !isFirstSection;
                          final showSection = _enrolled || isFirstChapter || isSecondChapter;
                          if (!showSection) {
                            return ListTile(
                              leading: const Icon(Icons.lock, color: Colors.red),
                              title: Text(section.title, style: const TextStyle(color: Colors.grey)),
                              enabled: false,
                            );
                          }
                          return ExpansionTile(
                            title: Row(
                              children: [
                                Text(section.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
                                if (sectionLocked || (isBlurred && !_enrolled))
                                  const Icon(Icons.lock, color: Colors.red, size: 18),
                              ],
                            ),
                            initiallyExpanded: isFirstSection,
                            children: [
                              ..._contents.where((content) => content.sectionId == section.id && content.type == 'pdf').map((content) {
                                final contentLocked = sectionLocked || (isBlurred && !_enrolled);
                                return ListTile(
                                  leading: contentLocked
                                      ? const Icon(Icons.lock, color: Colors.red)
                                      : const Icon(Icons.picture_as_pdf, color: Colors.red),
                                  title: Text(content.title),
                                  enabled: _enrolled || isFirstSection,
                                  onTap: (_enrolled || isFirstSection)
                                      ? () {
                                          // Open PDF URL
                                          // launch(content.url);
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
                    ),
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


