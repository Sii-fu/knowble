// course_model.dart
// Defines the data classes for Course, Module, and Lesson in Knowble.
// These classes represent the structure of course content, including modules and lessons.
// Used by course providers, UI screens, and anywhere course data is needed.

import 'user_model.dart';

// Lesson represents a single lesson within a module.
class Lesson {
  final String id; // Unique lesson ID
  final String title; // Lesson title
  final String content; // Lesson content (text, video, etc.)

  Lesson({required this.id, required this.title, required this.content});
}

// Module represents a group of lessons within a course.
class Module {
  final String id; // Unique module ID
  final String title; // Module title
  final List<Lesson> lessons; // List of lessons in this module

  Module({required this.id, required this.title, required this.lessons});
}

// Course represents a full course, including modules and instructor.
class Course {
  final String id; // Unique course ID
  final String title; // Course title
  final String description; // Course description
  final List<Module> modules; // List of modules in the course
  final User instructor; // Instructor for the course

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.modules,
    required this.instructor,
  });
}
