import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../config/theme.dart';
import 'chatbot/chatbotpage.dart';
import 'pdf_viewer_page.dart';
import 'video_player_page.dart';
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
  bool _allQuizzesPassed = false;
  String? _nextLessonId;
  double _progressPercentage = 0.0;
  int _totalSections = 0;
  int _completedSections = 0;
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

  Future<int?> _fetchProgress(String courseId) async {
    final client = Supabase.instance.client;
    final userId = client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await client
        .from('enrollments')
        .select('progress')
        .eq('student_id', userId)
        .eq('course_id', courseId)
        .maybeSingle(); // gets single row or null

    if (response == null || response['progress'] == null) return null;
    return response['progress'] as int?;
  }

  Future<void> _loadCourseLessons() async {
    final course = await _service.fetchCourseById(widget.courseId);
    final modules = await _service.fetchModules(widget.courseId);

    List<Content> allContents = [];
    List<Map<String, dynamic>> lessons = [];
    // Use a counter to track total sections accurately across modules
    int totalSectionsCount = 0;
    // Track section IDs for this course to filter quiz results
    Set<String> courseSectionIds = {};
    String? nextLessonId;

    for (final module in modules) {
      final sections = await _service.fetchSections(module.id);
      List<Map<String, dynamic>> sectionList = [];
      for (int i = 0; i < sections.length; i++) {
        final section = sections[i];
        final contents = await _service.fetchContents(section.id);
        allContents.addAll(contents);
        // Count each section to compute total sections correctly
        totalSectionsCount++;
        // Track section IDs for this course
        courseSectionIds.add(section.id);

        sectionList.add({
          'id': section.id, 
          'number': (i + 1).toString(),
          'title': section.title,
          'contents': contents.map((content) => {
                'id': content.id,
                'title': content.title,
                'type': content.type,
                'url': content.url,
                'section_id': content.sectionId,
              }).toList(),
        });
      }
      lessons.add({
        'chapter': module.title,
        'lessons': sectionList,
      });
    }

    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final enrollments = await _service.fetchUserEnrollments(userId);
    final enrolled = enrollments.any((e) => e.courseId == widget.courseId);

    // Get quiz results for completion tracking
    final quizResultsRes = await Supabase.instance.client
        .from('quiz_results')
        .select('section_id, status')
        .eq('student_id', userId);
    
    final passedSections = <String>{};
    for (final r in quizResultsRes) {
      if (r['status'] == 'pass') {
        final sectionId = r['section_id'] as String;
        // Only count sections that belong to this course
        if (courseSectionIds.contains(sectionId)) {
          passedSections.add(sectionId);
        }
      }
    }

    // Find next lesson (first section that's not passed)
    for (final module in lessons) {
      final sections = module['lessons'] as List<dynamic>;
      for (final section in sections) {
        if (!passedSections.contains(section['id'])) {
          nextLessonId = section['id'] as String;
          break;
        }
      }
      if (nextLessonId != null) break;
    }

    // Get progress from enrollments table
    final progress = await _fetchProgress(widget.courseId);
    final progressPercentage = progress != null ? (progress / 100.0) : 0.0;
    
    final totalSections = totalSectionsCount;
    final completedSections = passedSections.length;

    // Check if all sections are passed (all quizzes completed)
    bool allPassed = completedSections == totalSections && totalSections > 0;

    setState(() {
      _course = course;
      _contents = allContents;
      _lessons = lessons;
      _enrolled = enrolled;
      _passedSectionIds = passedSections;
      _isLoading = false;
      _allQuizzesPassed = allPassed;
      _nextLessonId = nextLessonId;
      _progressPercentage = progressPercentage;
      _totalSections = totalSections;
      _completedSections = completedSections;
    });
  }

  Future<void> _generateCertificate() async {
    if (_course == null) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Fetch user name from Supabase
    final userData = await Supabase.instance.client
        .from('users')
        .select('name')
        .eq('id', user.id)
        .maybeSingle();

    final userName = userData?['name'] ?? 'Student';

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
                pw.Text(userName, style: pw.TextStyle(fontSize: 24)),
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
        upsert: true,
      ),
    );

    final publicUrl = Supabase.instance.client.storage.from('certificates').getPublicUrl(fileName);

    await Supabase.instance.client.from('certificates').upsert({
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
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryTeal))
          : SafeArea(
              child: Column(
                children: [
                  // Header with back button and title
                  _buildHeader(),
                  
                  // Progress section
                  if (_enrolled) _buildProgressSection(),
                  
                  // Main content area
                  Expanded(
                    child: _buildLessonsContent(),
                  ),

                  // Certificate and review buttons (when all quizzes passed)
                  if (_allQuizzesPassed) _buildCompletionActions(),
                ],
              ),
            ),
      floatingActionButton: _enrolled ? _buildInstructorFAB() : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 24, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppTheme.primaryTeal),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _course?.title ?? 'Course Lessons',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryTeal,
                letterSpacing: 0.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_enrolled) _buildAIAssistantButton(),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                '${(_progressPercentage * 100).round()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryTeal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _progressPercentage,
              backgroundColor: AppTheme.borderSubtle,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryTeal),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$_completedSections of $_totalSections lessons completed',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          if (_nextLessonId != null && _completedSections < _totalSections) ...[
            const SizedBox(height: 12),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //   decoration: BoxDecoration(
            //     color: AppTheme.primaryTeal.withOpacity(0.1),
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   // child: Row(
            //   //   mainAxisSize: MainAxisSize.min,
            //   //   children: [
            //   //     const Icon(Icons.play_arrow, size: 16, color: AppTheme.primaryTeal),
            //   //     const SizedBox(width: 6),
            //   //     Text(
            //   //       'Continue Learning',
            //   //       style: Theme.of(context).textTheme.bodySmall?.copyWith(
            //   //         color: AppTheme.primaryTeal,
            //   //         fontWeight: FontWeight.w600,
            //   //       ),
            //   //     ),
            //   //   ],
            //   // ),
            // ),
          ],
        ],
      ),
    );
  }

  Widget _buildLessonsContent() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _lessons.length,
      separatorBuilder: (_, index) => const SizedBox(height: 16),
      itemBuilder: (context, moduleIndex) {
        final module = _lessons[moduleIndex];
        final lessons = module['lessons'] as List<dynamic>;
        
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Module header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Module ${moduleIndex + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Chapter: ${module['chapter'] as String}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Lessons list
              ...lessons.asMap().entries.map((entry) {
                final sectionIndex = entry.key;
                final section = entry.value as Map<String, dynamic>;
                return _buildLessonTile(section, moduleIndex, sectionIndex);
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLessonTile(Map<String, dynamic> section, int moduleIndex, int sectionIndex) {
    final sectionId = section['id'] as String;
    final isCompleted = _passedSectionIds.contains(sectionId);
    final isNext = sectionId == _nextLessonId;
    final contents = section['contents'] as List<dynamic>;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: isNext ? AppTheme.primaryTeal.withOpacity(0.3) : AppTheme.borderSubtle,
          width: isNext ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isNext ? AppTheme.primaryTeal.withOpacity(0.02) : Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status indicator
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted 
                        ? AppTheme.successGreen 
                        : isNext 
                            ? AppTheme.primaryTeal 
                            : AppTheme.borderSubtle,
                  ),
                  child: Icon(
                    isCompleted 
                        ? Icons.check 
                        : isNext 
                            ? Icons.play_arrow 
                            : Icons.circle_outlined,
                    size: 16,
                    color: isCompleted || isNext ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Section title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section['title'] as String,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Lesson ${section['number']} • ${contents.length} ${contents.length == 1 ? 'item' : 'items'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Quiz button
                if (_enrolled)
                  ElevatedButton.icon(
                    onPressed: isCompleted ? null : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizPage(sectionId: sectionId),
                        ),
                      );
                    },
                    icon: Icon(
                      isCompleted ? Icons.check_circle : Icons.quiz,
                      size: 16,
                    ),
                    label: Text(
                      isCompleted ? 'Passed' : 'Quiz',
                      style: const TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted 
                          ? AppTheme.successGreen 
                          : isNext 
                              ? AppTheme.primaryTeal 
                              : AppTheme.textSecondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Content list
          if (contents.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 52, right: 16, bottom: 16),
              child: Column(
                children: contents.map<Widget>((content) {
                  return _buildContentItem(content);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentItem(Map<String, dynamic> content) {
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
              contentId: content['id'],
              courseId: widget.courseId,
            ),
          ),
        );
      };
    } else if (content['type'] == 'video' || content['type'] == 'youtube') {
      icon = Icons.play_circle_outline;
      iconColor = AppTheme.primaryTeal;
      onTap = () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerPage(
              videoUrl: content['url'],
              title: content['title'],
              contentId: content['id'],
              courseId: widget.courseId,
              sectionId: content['section_id'],
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
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  content['title'],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionActions() {
    return Container(
      padding: const EdgeInsets.all(16),
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
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
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
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIAssistantButton() {
    final pdfContents = _contents
        .where((content) => content.type == 'pdf')
        .map((c) => {'id': c.id, 'title': c.title, 'url': c.url})
        .toList();
    return Container(
      margin: const EdgeInsets.only(right: 8),
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
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.smart_toy_outlined,
                    size: 16, color: AppTheme.primaryTeal),
                SizedBox(width: 6),
                Text(
                  'AI',
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