import 'package:flutter/material.dart';

class CourseContentPage extends StatelessWidget {
  const CourseContentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Course Content')),
      body: const Center(child: Text('Course Content Page')),
    );
  }
}
