import 'package:flutter/material.dart';
import 'edit_course_screen.dart';
import '../../config/theme.dart';



import '../../core/services/Instructor/course_fetch.dart';



class CourseDetailScreen extends StatefulWidget {
  final String id;
  final String title;
  final String subject;
  final dynamic students;
  final dynamic duration;

  const CourseDetailScreen({
    super.key,
    required this.id,
    required this.title,
    required this.subject,
    required this.students,
    required this.duration,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}


class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final CourseFetchService _fetchService = CourseFetchService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _modules = [];

  @override
  void initState() {
    super.initState();
    _fetchCourseDetails();
  }

  Future<void> _fetchCourseDetails() async {

    // Use courseId to fetch details
    final modules = await _fetchService.fetchCourseModulesWithSectionsAndContents(widget.id);
    setState(() {
      _modules = modules;
      _isLoading = false;
    });

    setState(() => _isLoading = true);
    
    try {
      // Fetch course detail once (includes chapters/modules with sections & contents)
      final courseDetails = await _fetch_service_safeFetchDetail(widget.id);

      // ensure this state is still mounted before updating
      if (!mounted) return;

      setState(() {
        final chapters = courseDetails?['chapters'] as List? ?? [];
        // Normalize chapters into List<Map<String, dynamic>>
        _modules = chapters.map<Map<String, dynamic>>((c) => Map<String, dynamic>.from(c as Map)).toList();
        _courseBanner = courseDetails?['banner'] ?? courseDetails?['banner_url'] ?? courseDetails?['image_url'] ?? courseDetails?['thumbnail'];
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching course details: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }

  }

    // small wrapper to avoid direct long-running calls inside try/await which helps readability
    Future<Map<String, dynamic>?> _fetch_service_safeFetchDetail(String courseId) async {
      try {
        return await _fetchService.fetchCourseDetail(courseId);
      } catch (e) {
        debugPrint('fetch detail error: $e');
        return null;
      }
    }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // ...existing header code...
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: AppTheme.instructorGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Stack(
              children: [
                // ...existing header icons/buttons...
                Positioned(
                  top: 20,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.surfaceWhite,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceWhite.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppTheme.surfaceWhite,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 40,
                  child: Icon(Icons.add, color: AppTheme.surfaceWhite.withOpacity(0.3), size: 20),
                ),
                Positioned(
                  top: 60,
                  right: 60,
                  child: Icon(Icons.close, color: AppTheme.surfaceWhite.withOpacity(0.3), size: 16),
                ),
                Positioned(
                  bottom: 40,
                  left: 30,
                  child: Icon(Icons.percent, color: AppTheme.surfaceWhite.withOpacity(0.3), size: 18),
                ),
                Positioned(
                  bottom: 20,
                  left: 60,
                  right: 60,
                  child: Icon(
                    Icons.person,
                    color: AppTheme.surfaceWhite.withOpacity(0.4),
                    size: 80,
                  ),
                ),
                Positioned(
                  bottom: 30,
                  right: 40,
                  child: Container(
                    width: 60,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(4),
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppTheme.textPrimary.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: Text(
                              '12345',
                              style: TextStyle(
                                color: AppTheme.surfaceWhite,
                                fontSize: 8,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 4,
                            children: List.generate(16, (index) {
                              return Container(
                                margin: const EdgeInsets.all(1),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceWhite.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content section
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course title and info
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.subject,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            Text(
                              '${_modules.length} Chapters',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Description section
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'This course on ${widget.title} (${widget.subject}) is designed for ${widget.students} and has a total duration of ${widget.duration}. Dive into chapters and lessons tailored for your learning journey.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Chapters, Lessons, and Contents
                        const Text(
                          'Course Structure',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._modules.map((module) => ModuleWidget(module: module)),
                      ],
                    ),
                  ),
          ),
          // Edit Course button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditCourseScreen(
                        courseTitle: widget.title,
                        subject: widget.subject,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.instructorPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Edit Course',
                  style: TextStyle(
                    color: AppTheme.surfaceWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ModuleWidget extends StatelessWidget {
  final Map<String, dynamic> module;
  const ModuleWidget({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    final List sections = module['sections'] ?? module['lessons'] ?? [];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          module['title'] ?? 'Chapter',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        children: [
          ...sections.map((section) => SectionWidget(section: section)),
        ],
      ),
    );
  }
}

class SectionWidget extends StatelessWidget {
  final Map<String, dynamic> section;
  const SectionWidget({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final List contents = section['contents'] ?? [];
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    section['title'] ?? 'Lesson',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            if ((section['description'] ?? '').toString().isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                section['description'],
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 6),
            ...contents.map((content) => ContentWidget(content: content)),
          ],
        ),
      ),
    );
  }
}

class ContentWidget extends StatelessWidget {
  final Map<String, dynamic> content;
  const ContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final String type = content['type'] ?? 'pdf';
    final String url = content['url'] ?? '';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        type == 'pdf' ? Icons.picture_as_pdf : Icons.link,
        color: type == 'pdf' ? Colors.red : Colors.blue,
      ),
      title: Text(
        content['title'] ?? 'Content',
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),
      trailing: url.isNotEmpty
          ? IconButton(
              icon: const Icon(Icons.open_in_new, size: 20),
              onPressed: () {
                // Open PDF or link
                // You can use url_launcher or similar package
              },
            )
          : null,
    );
  }
}