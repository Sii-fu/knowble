import 'package:flutter/material.dart';
import 'edit_course_screen.dart';
import '../../config/theme_instructor.dart';
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
  String? _courseBanner;

  @override
  void initState() {
    super.initState();
    _fetchCourseDetails();
  }

  Future<void> _fetchCourseDetails() async {
    setState(() => _isLoading = true);
    
    try {
      // Fetch course modules with sections and contents
      final modules = await _fetchService.fetchCourseModulesWithSectionsAndContents(widget.id);
      
      // Fetch course details including banner
      final courseDetails = await _fetchService.fetchCourseDetail(widget.id);
      
      setState(() {
        _modules = modules;
        _courseBanner = courseDetails?['banner'];
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching course details: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppThemeInstructor.lightTheme,
      child: Scaffold(
        backgroundColor: AppThemeInstructor.backgroundLight,
        body: CustomScrollView(
          slivers: [
            // Modern App Bar with gradient
            SliverAppBar(
              expandedHeight: 280,
              floating: false,
              pinned: true,
              backgroundColor: AppThemeInstructor.primaryBlue,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppThemeInstructor.primaryBlue,
                        AppThemeInstructor.primaryBlue.withOpacity(0.8),
                        AppThemeInstructor.successGreen.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Course Banner Image
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            image: _courseBanner != null && _courseBanner!.isNotEmpty
                                ? DecorationImage(
                                    image: NetworkImage(_courseBanner!),
                                    fit: BoxFit.cover,
                                    onError: (error, stackTrace) {
                                      print('Error loading banner image: $error');
                                    },
                                  )
                                : const DecorationImage(
                                    image: AssetImage('assets/images/bg.jpg'), // Fallback image
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                      // Overlay gradient for better text readability
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.3),
                                Colors.black.withOpacity(1),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Course info at bottom
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                (widget.subject.toString().trim().isNotEmpty)
                                  ? widget.subject.toString().toUpperCase()
                                  : 'GENERAL',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            SliverToBoxAdapter(
              child: _isLoading
                  ? Container(
                      height: 400,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  : Column(
                      children: [
                        // Stats Cards
                        Container(
                          margin: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              _buildStatCard(
                                icon: Icons.people_outline,
                                title: 'Students',
                                value: '${widget.students}',
                                color: AppThemeInstructor.primaryBlue,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                icon: Icons.access_time,
                                title: 'Duration',
                                value: '${widget.duration} days',
                                color: AppThemeInstructor.successGreen,
                              ),
                              const SizedBox(width: 12),
                              _buildStatCard(
                                icon: Icons.book_outlined,
                                title: 'Chapters',
                                value: '${_modules.length}',
                                color: AppThemeInstructor.errorRed,
                              ),
                            ],
                          ),
                        ),
                        // Description Section
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppThemeInstructor.surfaceWhite,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppThemeInstructor.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppThemeInstructor.primaryBlue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.description_outlined,
                                      color: AppThemeInstructor.primaryBlue,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Course Description',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppThemeInstructor.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'This comprehensive course on ${widget.title} (${widget.subject}) is designed for ${widget.students} students and spans ${widget.duration} days. Dive into structured chapters and interactive lessons tailored for your learning journey.',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: AppThemeInstructor.textSecondary,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Course Structure
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppThemeInstructor.successGreen.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.menu_book,
                                      color: AppThemeInstructor.successGreen,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Course Structure',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppThemeInstructor.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ..._modules.asMap().entries.map((entry) {
                                int index = entry.key;
                                Map<String, dynamic> module = entry.value;
                                return ModernModuleWidget(
                                  module: module,
                                  index: index + 1,
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 100), // Space for FAB
                      ],
                    ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
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
          backgroundColor: AppThemeInstructor.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(Icons.edit_outlined, color: Colors.white),
          label: const Text(
            'Edit Course',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppThemeInstructor.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppThemeInstructor.borderSubtle),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppThemeInstructor.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppThemeInstructor.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModernModuleWidget extends StatelessWidget {
  final Map<String, dynamic> module;
  final int index;

  const ModernModuleWidget({
    super.key,
    required this.module,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final List sections = module['sections'] ?? module['lessons'] ?? [];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppThemeInstructor.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppThemeInstructor.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: AppThemeInstructor.shadowLight.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          expansionTileTheme: ExpansionTileThemeData(
            backgroundColor: Colors.transparent,
            collapsedBackgroundColor: Colors.transparent,
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            expandedAlignment: Alignment.centerLeft,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(20),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppThemeInstructor.primaryBlue,
                  AppThemeInstructor.primaryBlue.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          title: Text(
            module['title'] ?? 'Chapter $index',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppThemeInstructor.textPrimary,
            ),
          ),
          subtitle: Text(
            '${sections.length} ${sections.length == 1 ? 'lesson' : 'lessons'}',
            style: TextStyle(
              fontSize: 12,
              color: AppThemeInstructor.textSecondary,
            ),
          ),
          children: [
            ...sections.asMap().entries.map((entry) {
              int sectionIndex = entry.key;
              Map<String, dynamic> section = entry.value;
              return ModernSectionWidget(
                section: section,
                index: sectionIndex + 1,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class ModernSectionWidget extends StatelessWidget {
  final Map<String, dynamic> section;
  final int index;

  const ModernSectionWidget({
    super.key,
    required this.section,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final List contents = section['contents'] ?? [];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppThemeInstructor.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppThemeInstructor.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppThemeInstructor.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$index',
                    style: TextStyle(
                      color: AppThemeInstructor.successGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section['title'] ?? 'Lesson $index',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppThemeInstructor.textPrimary,
                      ),
                    ),
                    if ((section['description'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        section['description'],
                        style: TextStyle(
                          fontSize: 13,
                          color: AppThemeInstructor.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppThemeInstructor.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${contents.length} items',
                  style: TextStyle(
                    color: AppThemeInstructor.primaryBlue,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (contents.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...contents.map((content) => ModernContentWidget(content: content)),
          ],
        ],
      ),
    );
  }
}

class ModernContentWidget extends StatelessWidget {
  final Map<String, dynamic> content;

  const ModernContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final String type = content['type'] ?? 'pdf';
    final String url = content['url'] ?? '';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppThemeInstructor.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppThemeInstructor.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: type == 'pdf' 
                  ? AppThemeInstructor.errorRed.withOpacity(0.1)
                  : AppThemeInstructor.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              type == 'pdf' ? Icons.picture_as_pdf : Icons.link,
              color: type == 'pdf' 
                  ? AppThemeInstructor.errorRed
                  : AppThemeInstructor.primaryBlue,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content['title'] ?? 'Content',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppThemeInstructor.textPrimary,
              ),
            ),
          ),
          if (url.isNotEmpty)
            Container(
              decoration: BoxDecoration(
                color: AppThemeInstructor.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.open_in_new,
                  size: 18,
                  color: AppThemeInstructor.primaryBlue,
                ),
                onPressed: () {
                  // Open PDF or link
                  // You can use url_launcher or similar package
                },
              ),
            ),
        ],
      ),
    );
  }
}