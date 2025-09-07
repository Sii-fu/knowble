import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../config/theme.dart';
import 'chatbot/chatbotpage.dart';
import 'pdf_viewer_page.dart';
import '../../core/services/student/course_services.dart';
import '../../data/models/content.dart';
import '../../data/models/course.dart';
import 'chat/chat_detail_page.dart';
import '../course/quiz_page.dart';
import 'course_review.dart';

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
  Set<String> _passedSectionIds = {};
  bool _showExtendedFAB = true;
  bool _allQuizzesPassed = false; // New flag
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
      value: 1.0,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _loadCourseLessons();

    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        await _animationController.reverse();
        setState(() {
          _showExtendedFAB = false;
        });
        await _animationController.forward();
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

        sectionList.add({
          'id': section.id, 
          'number': (i + 1).toString(),
          'title': section.title,
          'contents': contents.map((content) => {
                'id': content.id,
                'title': content.title,
                'type': content.type,
                'url': content.url,
              }).toList(),
        });
      }
      lessons.add({
        'module': module.title,
        'sections': sectionList,
      });
    }

    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final enrollments = await _service.fetchUserEnrollments(userId);
    final enrolled = enrollments.any((e) => e.courseId == widget.courseId);

    final quizResultsRes = await Supabase.instance.client
        .from('quiz_results')
        .select('section_id, status')
        .eq('student_id', userId);
    final passedSections = <String>{};
    if (quizResultsRes is List) {
      for (final r in quizResultsRes) {
        if (r['status'] == 'pass') {
          passedSections.add(r['section_id'] as String);
        }
      }
    }

    // Check if all sections are passed
    bool allPassed = lessons.every((module) {
      final sections = module['sections'] as List<dynamic>;
      return sections.every((s) => passedSections.contains(s['id']));
    });

    setState(() {
      _course = course;
      _contents = allContents;
      _lessons = lessons;
      _enrolled = enrolled;
      _passedSectionIds = passedSections;
      _isLoading = false;
      _allQuizzesPassed = allPassed;
    });
  }

  Future<void> _generateCertificate() async {
    if (_course == null) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('Certificate of Completion',
                    style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text(user.email ?? 'Student',
                    style: pw.TextStyle(fontSize: 24)),
                pw.Text('has completed the course', style: pw.TextStyle(fontSize: 18)),
                pw.Text(_course!.title,
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          );
        },
      ),
    );

    final pdfBytes = await pdf.save();

    final fileName = '${user.id}_${widget.courseId}.pdf';
    await Supabase.instance.client.storage.from('certificates').uploadBinary(
  fileName,
  pdfBytes,
  fileOptions: const FileOptions(
    cacheControl: '3600',
    upsert: true, // 👈 this allows overwriting if file exists
  ),
);


    final publicUrl = Supabase.instance.client.storage.from('certificates').getPublicUrl(fileName);

    await Supabase.instance.client.from('certificates').upsert({
  'id': '${user.id}_${widget.courseId}',
  'student_id': user.id,
  'course_id': widget.courseId,
  'issued_at': DateTime.now().toIso8601String(),
  'certificate_url': publicUrl,
  'cert_number': fileName,
  'status': 'issued',
});


    // Open PDF
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PDFViewerPage(
          pdfUrl: publicUrl,
          title: 'Your Certificate',
          contentId: '', 
          courseId: widget.courseId,
        ),
      ),
    );
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
                            icon: const Icon(Icons.arrow_back_ios,
                                color: AppTheme.primaryTeal),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Course Lessons',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryTeal,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ),
                        if (_enrolled)
                          _buildAIAssistantButton(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      itemCount: _lessons.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 18),
                      itemBuilder: (_, index) {
                        final module = _lessons[index];
                        final sections = module['sections'] as List<dynamic>;
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryTeal
                                            .withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.menu_book,
                                              color: AppTheme.primaryTeal,
                                              size: 18),
                                          const SizedBox(width: 6),
                                          Text(
                                            module['module'] as String,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
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
                                  final section =
                                      entry.value as Map<String, dynamic>;
                                  final contents =
                                      section['contents'] as List<dynamic>;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 15,
                                                backgroundColor:
                                                    AppTheme.accentLight,
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
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: AppTheme.textPrimary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                          if (_enrolled)
                                            Builder(builder: (context) {
                                              final isPassed = _passedSectionIds.contains(section['id']);
                                              return AbsorbPointer(
                                                absorbing: isPassed,
                                                child: ElevatedButton(
                                                  onPressed: isPassed
                                                      ? null
                                                      : () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (_) => QuizPage(
                                                                  sectionId: section['id']),
                                                            ),
                                                          );
                                                        },
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: isPassed
                                                        ? Colors.grey.shade400
                                                        : AppTheme.primaryTeal,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    isPassed ? 'Quiz Passed' : 'Quiz',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 40, top: 4, bottom: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                    builder: (_) =>
                                                        PDFViewerPage(
                                                      pdfUrl: content['url'],
                                                      title: content['title'],
                                                      contentId: content['id'],
                                                      courseId:
                                                          widget.courseId,
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
                                              padding: const EdgeInsets.only(
                                                  bottom: 2.5),
                                              child: InkWell(
                                                onTap: onTap,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: Row(
                                                  children: [
                                                    Icon(icon,
                                                        color: iconColor,
                                                        size: 18),
                                                    const SizedBox(width: 6),
                                                    Flexible(
                                                      child: Text(
                                                        content['title'],
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              color: AppTheme
                                                                  .textSecondary,
                                                            ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      const Divider(
                                          height: 18,
                                          thickness: 0.7,
                                          color: Color(0xFFE0E0E0)),
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
if (_allQuizzesPassed)
  Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _generateCertificate,
          icon: const Icon(Icons.badge),
          label: const Text('Generate Certificate'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.successGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12), // space between buttons
        ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CourseReviewPage(
                  courseId: widget.courseId,
                  courseName: _course?.title ?? '',
                ),
              ),
            );
          },
          icon: const Icon(Icons.rate_review),
          label: const Text('Review Course'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    ),
  ),

                ],
              ),
            ),
      floatingActionButton: _enrolled ? _buildInstructorFAB() : null,
    );
  }

  Widget _buildAIAssistantButton() {
    final pdfContents = _contents
        .where((content) => content.type == 'pdf')
        .map((c) => {'id': c.id, 'title': c.title, 'url': c.url})
        .toList();
    return Container(
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
                const Icon(Icons.smart_toy_outlined,
                    size: 16, color: AppTheme.primaryTeal),
                const SizedBox(width: 8),
                Text(
                  'AI Assistant',
                  style: const TextStyle(
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
    );
  }

  Widget _buildInstructorFAB() {
    return AnimatedBuilder(
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
                  tooltip: 'Ask Instructor',
                  child: const Icon(Icons.school_outlined, size: 24),
                ),
        );
      },
    );
  }
}
