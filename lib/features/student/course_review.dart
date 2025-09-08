import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseReviewPage extends StatefulWidget {
  final String courseId;
  final String courseName;

  const CourseReviewPage({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<CourseReviewPage> createState() => _CourseReviewPageState();
}

class _CourseReviewPageState extends State<CourseReviewPage> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 0;
  final int _maxChars = 250;

  Widget _buildStar(int index) {
    return IconButton(
      onPressed: () {
        setState(() {
          _rating = index;
        });
      },
      icon: Icon(
        index <= _rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 32,
      ),
    );
  }

  Future<void> _submitReview() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to submit a review.")),
      );
      return;
    }

    final review = _reviewController.text.trim();
    if (_rating == 0 || review.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please give a rating and write a review.")),
      );
      return;
    }

    try {
      // Insert review
      await client.from('course_reviews').insert({
        'course_id': widget.courseId,
        'student_id': user.id,
        'rating': _rating,
        'review_text': review,
        'created_at': DateTime.now().toIso8601String(),
      });

// Fetch instructor_id from courses table
final courseData = await client
    .from('courses')
    .select('instructor_id')
    .eq('id', widget.courseId)
    .single(); // no .execute()

if (courseData == null || courseData['instructor_id'] == null) {
  print("Error fetching instructor");
} else {
  final instructorId = courseData['instructor_id'] as String;

  // Insert notification for instructor
  await client.from('notification').insert({
    'user_id': instructorId,
    'title': 'New Course Review',
    'description':
        '${user.userMetadata?['name'] ?? "A student"} reviewed ${widget.courseName}',
    'priority': 'normal',
    'type': 'course_review',
    'is_read': false,
    'created_at': DateTime.now().toIso8601String(),
    'navigate': widget.courseId,
  });
}


      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review submitted successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting review: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Review ${widget.courseName}",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 60,
                    width: 60,
                    color: Colors.teal,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.courseName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ⭐ Star rating
            const Text(
              "Give a Rating",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) => _buildStar(index + 1)),
            ),

            const SizedBox(height: 24),

            // Review box
            const Text(
              "Write your Review",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              maxLines: 5,
              maxLength: _maxChars,
              decoration: InputDecoration(
                hintText: "What did you think about this course?",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const Spacer(),

            // Submit button
            GestureDetector(
              onTap: _submitReview,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0EA5E9), Color(0xFF0D9488)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Submit Review",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
