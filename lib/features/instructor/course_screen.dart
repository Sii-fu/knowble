

import 'package:flutter/material.dart';

import 'create_course_screen.dart';
import 'course_detail_screen.dart';


class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  final CourseFetchService _fetchService = CourseFetchService();
  List<Map<String, dynamic>> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    setState(() => _isLoading = true);
    final courses = await _fetchService.fetchInstructorCoursesFull();
    setState(() {
      _courses = courses;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What do you want to teach today?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search courses...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _courses.isEmpty
                      ? const Center(child: Text('No courses found.'))
                      : ListView.separated(
                          itemCount: _courses.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, idx) {
                            final course = _courses[idx];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Thumbnail with title and duration
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.menu_book, color: Colors.blue[700], size: 28),
                                            const SizedBox(height: 4),
                                            Text(
                                              course['duration_days']?.toString() ?? '-',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.blue[900],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              'days',
                                              style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    // Course title
                                    Expanded(
                                      child: Text(
                                        course['title'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // View button
                                    TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => CourseDetailScreen(
                                              title: course['title'] ?? '',
                                              subject: course['subject'] ?? '',
                                              students: course['students'] ?? 0,
                                              duration: course['duration_days'] ?? 0,
                                            ),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        backgroundColor: Colors.blue[50],
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      child: const Text(
                                        'View',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateCourseScreen(),
            ),
          ).then((_) => _loadCourses());
        },
        backgroundColor: Colors.blue[600],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Course',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

