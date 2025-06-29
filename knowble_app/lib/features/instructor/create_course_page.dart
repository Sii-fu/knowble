import 'package:flutter/material.dart';

class CreateCoursePage extends StatelessWidget {
  const CreateCoursePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Course')),
      body: const Center(child: Text('Create Course Page')),
    );
  }
}
