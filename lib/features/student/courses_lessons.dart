import 'package:flutter/material.dart';
import '../../config/theme.dart';
import 'chatbot/chatbotpage.dart';
import 'pdf_viewer_page.dart';
import '../../core/services/student/course_services.dart';
import '../course/quiz_page.dart';


class CourseLessonsPage extends StatelessWidget {
  final String courseId;
  CourseLessonsPage({super.key, required this.courseId});

  Future<List<Map<String, dynamic>>> _fetchLessons() async {
    final courseServices = CourseServices();
    final modules = await courseServices.fetchModules(courseId);
    List<Map<String, dynamic>> lessons = [];
    for (final module in modules) {
      final sections = await courseServices.fetchSections(module.id);
      List<Map<String, dynamic>> sectionList = [];
      for (int i = 0; i < sections.length; i++) {
        final section = sections[i];
        final contents = await courseServices.fetchContents(section.id);
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
    return lessons;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: AppTheme.primaryTeal,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Course Lessons',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTeal,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            // Removed search bar for a cleaner look
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchLessons(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading lessons'));
                  }
                  final lessons = snapshot.data ?? [];
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    itemCount: lessons.length,
                    separatorBuilder: (context, idx) => const SizedBox(height: 18),
                    itemBuilder: (context, moduleIndex) {
                      final module = lessons[moduleIndex];
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
                                                  builder: (context) => PDFViewerPage(
                                                    pdfUrl: content['url'],
                                                    title: content['title'],
                                                  ),
                                                ),
                                              );
                                            };
                                          } else if (content['type'] == 'video') {
                                            icon = Icons.play_circle_fill;
                                            iconColor = AppTheme.primaryTeal;
                                            onTap = null;
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
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuizPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.quiz, color: Colors.white),
                  label: const Text(
                    'Take Quiz',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.gradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryTeal.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatBotPage(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(
            Icons.chat_bubble_outline,
            color: AppTheme.surfaceWhite,
            size: 28,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
