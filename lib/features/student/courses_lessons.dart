import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/theme.dart';
import 'chatbot/chatbotpage.dart';
import 'pdf_viewer_page.dart';
import '../../core/services/student/course_services.dart';
import '../../data/models/content.dart';
import '../../data/models/course.dart';
import 'chat/chat_detail_page.dart';
import '../course/quiz_page.dart';
import 'chatbot/chatbotpage.dart';

class CourseLessonsPage extends StatefulWidget {
  final String courseId;
  const CourseLessonsPage({super.key, required this.courseId});

  @override
  State<CourseLessonsPage> createState() => _CourseLessonsPageState();
}

class _CourseLessonsPageState extends State<CourseLessonsPage>
    with SingleTickerProviderStateMixin {
  final CourseServices _service = CourseServices();
  bool _isLoading = true;
  Course? _course;
  List<Content> _contents = [];
  bool _enrolled = false;
  List<Map<String, dynamic>> _lessons = [];
  bool _showExtendedFAB = true;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
      value: 1.0, // Start at normal position (visible)
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0.0), // Off-screen right
      end: Offset.zero, // Normal position
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _loadCourseLessons();
    
    // Auto-collapse the FAB after 3 seconds with sequential animation
    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        // First slide out extended button (600ms)
        await _animationController.reverse(); // Goes from 1.0 to 0.0 (normal to off-screen)
        // Then switch to collapsed button
        setState(() {
          _showExtendedFAB = false;
        });
        // Then slide in collapsed button (600ms)
        await _animationController.forward(); // Goes from 0.0 to 1.0 (off-screen to normal)
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCourseLessons() async {
    final course = await _service.fetchCourseById(widget.courseId);
    final modules = await _service.fetchModules(widget.courseId);

    List<Content> allContents = [];
    List<Map<String, dynamic>> lessons = [];

    for (final module in modules) {
      final sections = await _service.fetchSections(module.id);
      List<Map<String, dynamic>> sectionList = [];
      for (int i = 0; i < sections.length; i++) {
        final section = sections[i];
        final contents = await _service.fetchContents(section.id);
        allContents.addAll(contents);
        List<Map<String, dynamic>> contentList = contents.map((content) => {
              'title': content.title,
              'type': content.type,
              'url': content.url,
            }).toList();
        sectionList.add({
          'number': (i + 1).toString(),
          'title': section.title,
          'contents': contentList,
        });
      }
      lessons.add({
        'module': module.title,
        'sections': sectionList,
      });
    }

    // Check enrollment
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final enrollments = await _service.fetchUserEnrollments(userId);
    final enrolled = enrollments.any((e) => e.courseId == widget.courseId);

    setState(() {
      _course = course;
      _contents = allContents;
      _lessons = lessons;
      _enrolled = enrolled;
      _isLoading = false;
    });
  }

  Future<void> _startInstructorChat() async {
    try {
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

      final instructorData = await Supabase.instance.client
          .from('users')
          .select('name, profile_pic')
          .eq('id', instructorId)
          .maybeSingle();

      final instructorName = instructorData?['name'] ?? 'Instructor';
      final profileImage = instructorData?['profile_pic'];

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
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primaryTeal),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Course Lessons',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTeal,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ),
                        if (_enrolled)
                          Container(
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryTeal.withOpacity(0.1),
                                  AppTheme.successGreen.withOpacity(0.1),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppTheme.primaryTeal.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  final pdfContents = _contents
                                      .where((content) => content.type == 'pdf')
                                      .map((c) => {'title': c.title, 'url': c.url})
                                      .toList();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ChatBotPage(
                                        courseTitle: _course?.title ?? '',
                                        courseDescription: _course?.description ?? '',
                                        pdfContents: pdfContents,
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        child: Icon(
                                          Icons.smart_toy_outlined,
                                          size: 16,
                                          color: AppTheme.primaryTeal,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'AI Assistant',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryTeal,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      itemCount: _lessons.length + 1, // +1 for the quiz button
                      separatorBuilder: (_, index) => const SizedBox(height: 18),
                      itemBuilder: (_, index) {
                        if (index == _lessons.length) {
                          // Quiz button as the last item
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const QuizPage()),
                                );
                              },
                              icon: const Icon(Icons.quiz, color: Colors.white),
                              label: const Text(
                                'Take Quiz',
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryTeal,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          );
                        }
                        
                        final module = _lessons[index];
                        final sections = module['sections'] as List<dynamic>;
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryTeal.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.menu_book, color: AppTheme.primaryTeal, size: 18),
                                          const SizedBox(width: 6),
                                          Text(
                                            module['module'] as String,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryTeal,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                ...sections.asMap().entries.map((entry) {
                                  final section = entry.value as Map<String, dynamic>;
                                  final contents = section['contents'] as List<dynamic>;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 15,
                                            backgroundColor: AppTheme.accentLight,
                                            child: Text(
                                              section['number'],
                                              style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            section['title'],
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.textPrimary,
                                                ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 40, top: 4, bottom: 10),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: contents.map<Widget>((content) {
                                            IconData icon;
                                            Color iconColor;
                                            VoidCallback? onTap;
                                            if (content['type'] == 'pdf') {
                                              icon = Icons.picture_as_pdf_outlined;
                                              iconColor = AppTheme.errorRed;
                                              onTap = () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) => PDFViewerPage(
                                                      pdfUrl: content['url'],
                                                      title: content['title'],
                                                    ),
                                                  ),
                                                );
                                              };
                                            } else {
                                              icon = Icons.insert_drive_file;
                                              iconColor = AppTheme.primaryTeal;
                                              onTap = null;
                                            }
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 2.5),
                                              child: InkWell(
                                                onTap: onTap,
                                                borderRadius: BorderRadius.circular(6),
                                                child: Row(
                                                  children: [
                                                    Icon(icon, color: iconColor, size: 18),
                                                    const SizedBox(width: 6),
                                                    Flexible(
                                                      child: Text(
                                                        content['title'],
                                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                              color: AppTheme.textSecondary,
                                                            ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      const Divider(height: 18, thickness: 0.7, color: Color(0xFFE0E0E0)),
                                    ],
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: _enrolled
          ? AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: _showExtendedFAB
                      ? FloatingActionButton.extended(
                          key: const ValueKey('extended'),
                          heroTag: 'instructor',
                          onPressed: _startInstructorChat,
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          icon: const Icon(Icons.school_outlined, size: 20),
                          label: const Text(
                            'Ask Instructor',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        )
                      : FloatingActionButton(
                          key: const ValueKey('collapsed'),
                          heroTag: 'instructor',
                          onPressed: _startInstructorChat,
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.school_outlined, size: 24),
                          tooltip: 'Ask Instructor',
                        ),
                );
              },
            )
          : null,
    );
  }
}
