import 'package:flutter/material.dart';

class InstructorDashboardPage extends StatelessWidget {
  const InstructorDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instructor Dashboard')),
      body: const Center(child: Text('Instructor Dashboard Page')),
    );
  }
}
