// course_provider.dart
// Provides dummy course data and state management for Knowble.
// This file defines the CourseProvider class, which holds a list of sample courses and exposes them to the UI.
// Used by course-related screens to display available courses and details.

import '../models/course_model.dart';
import '../models/user_model.dart';
import 'package:flutter/material.dart';

// CourseProvider manages a list of available courses (dummy data for demo).
class CourseProvider extends ChangeNotifier {
  // List of sample courses for demonstration purposes
  final List<Course> _courses = [
    Course(
      id: '1',
      title: 'Flutter for Beginners',
      description: 'Learn Flutter from scratch.',
      modules: [
        Module(
          id: 'm1',
          title: 'Introduction',
          lessons: [
            Lesson(id: 'l1', title: 'Welcome', content: 'Welcome to Flutter!'),
          ],
        ),
      ],
      instructor: User(name: 'Jane Instructor', email: 'instructor@knowble.com', role: UserRole.instructor),
    ),
    Course(
      id: '2',
      title: 'Advanced Dart',
      description: 'Deep dive into Dart language.',
      modules: [
        Module(
          id: 'm2',
          title: 'Dart Advanced',
          lessons: [
            Lesson(id: 'l2', title: 'Generics', content: 'Learn about generics.'),
          ],
        ),
      ],
      instructor: User(name: 'John Instructor', email: 'instructor2@knowble.com', role: UserRole.instructor),
    ),
  ];

  // Exposes the list of courses to the UI
  List<Course> get courses => _courses;

  // Finds a course by its ID
  Course? getCourseById(String id) => _courses.firstWhere((c) => c.id == id, orElse: () => _courses[0]);
}
