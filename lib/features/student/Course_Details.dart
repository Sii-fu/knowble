import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/student/course_services.dart';
import '../../data/models/course.dart';
import '../../data/models/module.dart';
import '../../data/models/section.dart';
import '../../data/models/content.dart';
import '../../config/theme.dart';
import 'chatbot/chatbotpage.dart';
import 'chat/chat_detail_page.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseId;

  const CourseDetailPage({Key? key, required this.courseId}) : super(key: key);

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  final CourseServices _courseServices = CourseServices();
  
  bool _isLoading = true;
  bool _enrolled = false;
  Course? _course;
  List<Module> _modules = [];
  List<Section> _sections = [];
  List<Content> _contents = [];
  
  // Enhanced state for modern UI
  List<Map<String, dynamic>> _relatedCourses = [];
  bool _isLoadingRelated = false;
  String _instructorName = '';
  String _instructorProfilePic = '';
  List<String> _courseTags = [];
  int _enrollmentCount = 0;
  
  // UI state
  final Set<int> _expandedModuleIndexes = {};
  final Set<String> _expandedSectionIds = {};

  @override
  void initState() {
    super.initState();
    _loadCourseDetails();
  }

  Future<void> _loadCourseDetails() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Load basic course details
      final course = await _courseServices.fetchCourseById(widget.courseId);
      if (course == null) throw Exception('Course not found');
      
      final modules = await _courseServices.fetchModules(widget.courseId);
      List<Section> allSections = [];
      List<Content> allContents = [];
      
      // Fetch sections for each module
      for (Module module in modules) {
        final sections = await _courseServices.fetchSections(module.id);
        allSections.addAll(sections);
        
        // Fetch contents for each section
        for (Section section in sections) {
          final contents = await _courseServices.fetchContents(section.id);
          allContents.addAll(contents);
        }
      }
      
      // Check enrollment status
      final enrollments = await _courseServices.fetchUserEnrollments(user.id);
      final enrolled = enrollments.any((e) => e.courseId == widget.courseId);

      // Enhanced data fetching for modern UI
      // Fetch instructor information
      String instructorName = '';
      String instructorProfilePic = '';
      try {
        final response = await Supabase.instance.client
            .from('users')
            .select('name, profile_pic')
            .eq('id', course.instructorId)
            .single();
        instructorName = response['name'] ?? '';
        instructorProfilePic = response['profile_pic'] ?? '';
      } catch (e) {
        print('Error fetching instructor: $e');
      }

      // Fetch course tags
      List<String> courseTags = [];
      try {
        final response = await Supabase.instance.client
            .from('course_tags')
            .select('tags(name)')
            .eq('course_id', widget.courseId);
        courseTags = response.map((item) => item['tags']['name'] as String).toList();
      } catch (e) {
        print('Error fetching course tags: $e');
      }

      // Fetch enrollment count
      int enrollmentCount = 0;
      try {
        final response = await Supabase.instance.client
            .from('enrollments')
            .select('id')
            .eq('course_id', widget.courseId);
        enrollmentCount = response.length;
      } catch (e) {
        print('Error fetching enrollment count: $e');
      }

      setState(() {
        _course = course;
        _modules = modules;
        _sections = allSections;
        _contents = allContents;
        _enrolled = enrolled;
        _instructorName = instructorName;
        _instructorProfilePic = instructorProfilePic;
        _courseTags = courseTags;
        _enrollmentCount = enrollmentCount;
        _isLoading = false;
      });

      // Load related courses asynchronously
      _loadRelatedCourses();
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading course: $error'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _loadRelatedCourses() async {
    try {
      setState(() {
        _isLoadingRelated = true;
      });

      final relatedCourses = await _courseServices.fetchRelatedCourses(widget.courseId, limit: 4);
      
      setState(() {
        _relatedCourses = relatedCourses;
        _isLoadingRelated = false;
      });
    } catch (e) {
      print('Error loading related courses: $e');
      setState(() {
        _isLoadingRelated = false;
      });
    }
  }

  Future<void> _handleEnrollment() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please log in to enroll'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return;
      }

      await _courseServices.enrollCourse(user.id, widget.courseId);
      setState(() {
        _enrolled = true;
        _enrollmentCount++;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Successfully enrolled!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Enrollment failed: $error'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _startInstructorChat() {
    if (_course != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailPage(
            courseId: widget.courseId,
            receiverId: _course!.instructorId,
            instructorName: _instructorName.isNotEmpty ? _instructorName : 'Instructor',
            courseCode: _course!.title,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryTeal,
            strokeWidth: 3,
          ),
        ),
      );
    }
    if (_course == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Course not found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Modern App Bar with course banner
          _buildSliverAppBar(),
          
          // Course content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course meta information
                  _buildCourseMetaInfo(),
                  const SizedBox(height: 24),
                  
                  // Action buttons (only for enrolled)
                  if (_enrolled) ...[
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                  ],
                  
                  // Course description
                  _buildCourseDescription(),
                  const SizedBox(height: 24),
                  
                  // Course curriculum
                  _buildCourseCurriculum(),
                  const SizedBox(height: 24),
                  
                  // Enrollment button (only for non-enrolled)
                  if (!_enrolled) ...[
                    _buildEnrollmentSection(),
                    const SizedBox(height: 32),
                  ],
                  
                  // Related courses section
                  _buildRelatedCoursesSection(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build the sliver app bar with course banner
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      stretch: true,
      backgroundColor: AppTheme.primaryTeal,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Course banner image
            _course!.banner.startsWith('http')
                ? Image.network(
                    _course!.banner,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: BoxDecoration(gradient: AppTheme.gradient),
                      child: Icon(
                        Icons.school,
                        size: 64,
                        color: AppTheme.surfaceWhite.withOpacity(0.7),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(gradient: AppTheme.gradient),
                    child: Icon(
                      Icons.school,
                      size: 64,
                      color: AppTheme.surfaceWhite.withOpacity(0.7),
                    ),
                  ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.textPrimary.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Course title and status overlay
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enrollment status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _enrolled ? AppTheme.successGreen : AppTheme.primaryTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _enrolled ? 'Enrolled' : 'Course Preview',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.surfaceWhite,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Course title
                  Text(
                    _course!.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.surfaceWhite,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build course meta information
  Widget _buildCourseMetaInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course stats row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(Icons.menu_book, '${_modules.length} Chapters'),
              ),
              Expanded(
                child: _buildStatItem(Icons.article, '${_sections.length} Sections'),
              ),
              Expanded(
                child: _buildStatItem(Icons.people, '$_enrollmentCount Students'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Instructor info
          if (_instructorName.isNotEmpty) ...[
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: _instructorProfilePic.isNotEmpty
                      ? NetworkImage(_instructorProfilePic)
                      : null,
                  backgroundColor: AppTheme.primaryTeal.withOpacity(0.1),
                  child: _instructorProfilePic.isEmpty
                      ? Icon(Icons.person, color: AppTheme.primaryTeal, size: 18)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(
                  'Instructor: $_instructorName',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          // Course tags
          if (_courseTags.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _courseTags.take(5).map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryTeal.withOpacity(0.2)),
                ),
                child: Text(
                  tag,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.primaryTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryTeal),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Helper method to build action buttons for enrolled students
  Widget _buildActionButtons() {
    return Column(
      children: [
        // AI Assistant button
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: AppTheme.gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryTeal.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.smart_toy, color: AppTheme.surfaceWhite),
            label: Text(
              'Ask AI Assistant',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.surfaceWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: () {
              List<Map<String, dynamic>> pdfContents = _contents
                  .where((content) => content.type == 'pdf')
                  .map((content) => {
                    'id': content.id,
                    'title': content.title,
                    'url': content.url,
                  })
                  .toList();
              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatBotPage(
                    courseTitle: _course!.title,
                    courseDescription: _course!.description,
                    pdfContents: pdfContents,
                    courseId: widget.courseId,
                  ),
                ),
              );
            },
          ),
        ),
        // Instructor chat button
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: AppTheme.instructorGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.instructorPrimary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.chat, color: AppTheme.surfaceWhite),
            label: Text(
              'Chat with Instructor',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.surfaceWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: _startInstructorChat,
          ),
        ),
      ],
    );
  }

  // Helper method to build course description section
  Widget _buildCourseDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.description,
                  color: AppTheme.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'About This Course',
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
    );
  }

  // Helper method to build course curriculum section
  Widget _buildCourseCurriculum() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.list_alt,
                  color: AppTheme.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Course Curriculum',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_modules.length} Chapters',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Module expansion tiles with access control
          ..._modules.asMap().entries.map((entry) {
            final index = entry.key;
            final module = entry.value;
            final isLocked = !_enrolled && index > 0;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: isLocked ? AppTheme.accentLight.withOpacity(0.3) : AppTheme.accentLight,
                borderRadius: BorderRadius.circular(12),
                border: isLocked ? Border.all(color: AppTheme.borderSubtle) : null,
              ),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                leading: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isLocked ? AppTheme.textSecondary : AppTheme.primaryTeal,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    isLocked ? Icons.lock : Icons.play_arrow,
                    color: AppTheme.surfaceWhite,
                    size: 16,
                  ),
                ),
                title: Text(
                  'Chapter ${index + 1}: ${module.title}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isLocked ? AppTheme.textSecondary : AppTheme.textPrimary,
                  ),
                ),
                subtitle: isLocked
                    ? Text(
                        'Enroll to unlock',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      )
                    : null,
                onExpansionChanged: isLocked ? null : (expanded) {
                  setState(() {
                    if (expanded) {
                      _expandedModuleIndexes.add(index);
                    } else {
                      _expandedModuleIndexes.remove(index);
                    }
                  });
                },
                children: isLocked ? [] : [
                  ..._sections.where((s) => s.moduleId == module.id).map((section) {
                    return ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      childrenPadding: const EdgeInsets.only(left: 12, right: 12, bottom: 4),
                      title: Text(
                        section.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      onExpansionChanged: (expanded) {
                        setState(() {
                          if (expanded) {
                            _expandedSectionIds.add(section.id);
                          } else {
                            _expandedSectionIds.remove(section.id);
                          }
                        });
                      },
                      children: [
                        ..._contents.where((c) => c.sectionId == section.id && c.type == 'pdf').map((content) {
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              Icons.picture_as_pdf,
                              color: AppTheme.errorRed,
                              size: 20,
                            ),
                            title: Text(
                              content.title,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Helper method to build enrollment section for non-enrolled users
  Widget _buildEnrollmentSection() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          icon: const Icon(Icons.school, color: AppTheme.surfaceWhite),
          label: Text(
            'Enroll Now',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.surfaceWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
          onPressed: _handleEnrollment,
        ),
      ),
    );
  }

  // Helper method to build related courses section
  Widget _buildRelatedCoursesSection() {
    if (_relatedCourses.isEmpty && !_isLoadingRelated) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textPrimary.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.recommend,
                  color: AppTheme.primaryTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Related Courses',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingRelated) ...[
            Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryTeal,
                strokeWidth: 2,
              ),
            ),
          ] else ...[
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: crossAxisCount == 2 ? 1.2 : 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _relatedCourses.length,
                  itemBuilder: (context, index) {
                    final relatedData = _relatedCourses[index];
                    return _buildRelatedCourseCard(
                      relatedData['course'],
                      relatedData['instructorName'] ?? '',
                      relatedData['enrollmentCount'] ?? 0,
                      List<String>.from(relatedData['tags'] ?? []),
                    );
                  },
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  // Helper method to build individual related course cards
  Widget _buildRelatedCourseCard(Course course, String instructorName, int enrollmentCount, List<String> tags) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => CourseDetailPage(courseId: course.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: AppTheme.textPrimary.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course banner
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: AppTheme.gradient,
                  ),
                  child: course.banner.startsWith('http')
                      ? Image.network(
                          course.banner,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(gradient: AppTheme.gradient),
                            child: Icon(
                              Icons.school,
                              color: AppTheme.surfaceWhite.withOpacity(0.7),
                              size: 32,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.school,
                          color: AppTheme.surfaceWhite.withOpacity(0.7),
                          size: 32,
                        ),
                ),
              ),
            ),
            // Course info
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (instructorName.isNotEmpty) ...[
                      Text(
                        'by $instructorName',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                    ],
                    Text(
                      '$enrollmentCount students',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.primaryTeal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (tags.isNotEmpty)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: tags.take(2).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            tag,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.primaryTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )).toList(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
