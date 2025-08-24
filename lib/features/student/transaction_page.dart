import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../core/services/student/course_services.dart';
import 'courses_lessons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionPage extends StatelessWidget {
  final String courseId;
  const TransactionPage({super.key, required this.courseId});

  Future<void> _handlePayment(BuildContext context) async {
    // Simulate payment success
    await Future.delayed(const Duration(seconds: 2));

    // Enroll user after payment success
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    await CourseServices().enrollCourse(userId, courseId);

    // Show success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Payment Successful! You are enrolled."),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to lessons page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CourseLessonsPage(courseId: courseId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceWhite,
        title: const Text("Transaction", style: TextStyle(color: AppTheme.textPrimary)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.payment, size: 80, color: AppTheme.primaryTeal),
            const SizedBox(height: 20),
            const Text(
              "Complete Your Payment",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "This is a dummy payment page.\nClick Pay Now to simulate a successful transaction.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryTeal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 14),
              ),
              onPressed: () => _handlePayment(context),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Pay Now", style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
