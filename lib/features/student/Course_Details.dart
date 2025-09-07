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
import 'transaction_page.dart';



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
  final Set<int> _expandedModuleIndexes = {};
  final Set<String> _expandedSectionIds = {};

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.textPrimary.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.textPrimary.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            _course!.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Banner with overlay
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.textPrimary.withOpacity(0.10),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _course!.banner.startsWith('http')
                        ? Image.network(
                            _course!.banner,
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/images/default_course.jpg',
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.textPrimary.withOpacity(0.08),
                            AppTheme.textPrimary.withOpacity(0.70),
                          ],
                        ),
                      ),
                    ),
                    // Course title and meta overlay
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryTeal.withOpacity(0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Text(
                              _enrolled ? 'Enrolled' : 'Course Preview',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppTheme.surfaceWhite,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _course!.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppTheme.surfaceWhite,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _MetaChip(
                                icon: Icons.menu_book_rounded,
                                label: '${_modules.length} Chapters',
                              ),
                              const SizedBox(width: 8),
                              _MetaChip(
                                icon: Icons.article_outlined,
                                label: '${_sections.length} Sections',
                              ),
                              const SizedBox(width: 8),
                              _MetaChip(
                                icon: Icons.picture_as_pdf,
                                label: '${_contents.where((c) => c.type == 'pdf').length} Resources',
                                iconColor: AppTheme.errorRed,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                const SizedBox(height: 16),
                // Chatbot button (prominent, only for enrolled)
                if (_enrolled)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: AppTheme.gradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryTeal.withOpacity(0.28),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        icon: const Icon(Icons.smart_toy_rounded, color: AppTheme.textPrimary, size: 20),
                        label: Text(
                          'Ask AI Assistant',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
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
                  ),
                
                // Chat with instructor button (only for enrolled)
                if (_enrolled)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: AppTheme.instructorGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.instructorPrimary.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        icon: const Icon(Icons.person_outline_rounded, color: AppTheme.textPrimary, size: 20),
                        label: Text(
                          'Chat with Instructor',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        onPressed: () {
                          // Navigate to instructor chat
                          _startInstructorChat();
                        },
                      ),
                    ),
                  ),
                
                // Course Info Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.textPrimary.withOpacity(0.06),
                        blurRadius: 20,
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.description_outlined,
                              color: AppTheme.primaryTeal,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Course Description',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _course!.description,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.6,
                            ),
                      ),
                    ],
                  ),
                ),
                
                // Chapters Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.textPrimary.withOpacity(0.06),
                        blurRadius: 20,
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
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryTeal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.menu_book_rounded,
                              color: AppTheme.primaryTeal,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Course Chapters',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.accentLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_modules.length} Chapters',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Dynamic modules/sections/contents with access logic
                      ..._modules.asMap().entries.map((moduleEntry) {
                        final moduleIndex = moduleEntry.key;
                        final module = moduleEntry.value;
                        final isFirstChapter = moduleIndex == 0;
                        // access control: locked chapters when not enrolled
                        // If not enrolled and not first chapter, show blurred, non-expandable tile
                        if (!_enrolled && moduleIndex > 0) {
                          // Locked preview card for non-enrolled users
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 220),
                              opacity: 0.95,
                              child: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceWhite,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.textPrimary.withOpacity(0.05),
                                          blurRadius: 14,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      leading: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryTeal.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.menu_book_rounded,
                                          color: AppTheme.primaryTeal,
                                          size: 22,
                                        ),
                                      ),
                                      title: Text(
                                        'Chapter ${moduleIndex + 1}: ${module.title}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimary,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                        'Locked — enroll to access',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppTheme.textPrimary,
                                            ),
                                      ),
                                      trailing: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryTeal.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.lock, color: AppTheme.primaryTeal, size: 18),
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          colors: [
                                            AppTheme.surfaceWhite.withOpacity(0.0),
                                            AppTheme.surfaceWhite.withOpacity(0.6),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 12,
                                    top: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.lock, size: 16, color: AppTheme.primaryTeal),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Locked',
                                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                  color: AppTheme.primaryTeal,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                        // Otherwise, show normal ExpansionTile
                        final bool expanded = _expandedModuleIndexes.contains(moduleIndex) || isFirstChapter;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeInOut,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.textPrimary.withOpacity(expanded ? 0.08 : 0.04),
                                blurRadius: expanded ? 16 : 10,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                            onExpansionChanged: (isOpen) {
                              setState(() {
                                if (isOpen) {
                                  _expandedModuleIndexes.add(moduleIndex);
                                } else {
                                  _expandedModuleIndexes.remove(moduleIndex);
                                }
                              });
                            },
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Chapter ${moduleIndex + 1}: ${module.title}',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                if (!_enrolled && moduleIndex == 0 && _modules.length > 1)
                                  const Icon(Icons.lock_open, color: AppTheme.successGreen, size: 18),
                              ],
                            ),
                            initiallyExpanded: isFirstChapter,
                            children: [
                              ..._sections
                                  .where((section) => section.moduleId == module.id)
                                  .toList()
                                  .asMap()
                                  .entries
                                  .map((sectionEntry) {
                                final sectionIndex = sectionEntry.key;
                                final section = sectionEntry.value;
                                final isFirstSection = isFirstChapter && sectionIndex == 0;
                                final sectionLocked = !_enrolled && isFirstChapter && !isFirstSection;
                                if (!_enrolled && !isFirstChapter) {
                                  // Should never reach here, but just in case
                                  return const SizedBox.shrink();
                                }
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut,
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentLight.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: ExpansionTile(
                                    tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    childrenPadding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                                    onExpansionChanged: (open) {
                                      setState(() {
                                        if (open) {
                                          _expandedSectionIds.add(section.id);
                                        } else {
                                          _expandedSectionIds.remove(section.id);
                                        }
                                      });
                                    },
                                    title: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            section.title,
                                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                        ),
                                        if (sectionLocked)
                                          const Icon(Icons.lock, color: AppTheme.errorRed, size: 18),
                                      ],
                                    ),
                                    initiallyExpanded: isFirstSection,
                                    children: [
                                      ..._contents
                                          .where((content) => content.sectionId == section.id && content.type == 'pdf')
                                          .map((content) {
                                        final contentLocked = sectionLocked;
                                        return Container(
                                          margin: const EdgeInsets.symmetric(vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.surfaceWhite,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppTheme.borderSubtle),
                                          ),
                                          child: ListTile(
                                            leading: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: AppTheme.accentLight,
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                contentLocked ? Icons.lock : Icons.picture_as_pdf,
                                                color: contentLocked ? AppTheme.errorRed : AppTheme.errorRed,
                                              ),
                                            ),
                                            title: Text(
                                              content.title,
                                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                    fontWeight: FontWeight.w500,
                                                    color: AppTheme.textPrimary,
                                                  ),
                                            ),
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
                        ? Text(
                          'Locked',
                          style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: AppTheme.errorRed),
                          )
                        : null,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),

                if (!_enrolled) ...[
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransactionPage(courseId: widget.courseId),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.gradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryTeal.withOpacity(0.28),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(28),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 44, vertical: 16),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Start Course',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.surfaceWhite,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward_rounded, color: AppTheme.surfaceWhite),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

}

// Lightweight chip used in header meta row
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;

  const _MetaChip({required this.icon, required this.label, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor ?? AppTheme.primaryTeal),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

