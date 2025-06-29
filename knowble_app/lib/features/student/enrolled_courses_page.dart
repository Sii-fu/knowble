import 'package:flutter/material.dart';

class EnrolledCoursesPage extends StatelessWidget {
  const EnrolledCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enrolled Courses')),
      body: const Center(child: Text('Enrolled Courses Page')),
    );
  }
}
