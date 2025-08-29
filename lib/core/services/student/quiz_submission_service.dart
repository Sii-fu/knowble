import 'package:supabase_flutter/supabase_flutter.dart';

class QuizSubmissionService {
  final _client = Supabase.instance.client;

  /// Save a student's answer into the submissions table
  Future<void> submitAnswer({
    required String studentId,
    required String questionId,
    required List<String> selectedOptionIds,
    required bool isCorrect,
    required int marksAwarded,
  }) async {
    try {
      await _client.from('submissions').insert({
        'student_id': studentId,
        'question_id': questionId,
        'selected_option_ids': selectedOptionIds,
        'is_correct': isCorrect,
        'marks_awarded': marksAwarded,
      });
    } catch (e) {
      print("❌ Error submitting answer: $e");
      rethrow;
    }
  }

  /// Fetch total score for a student in a course
  Future<int> fetchTotalScore(String studentId, String courseId) async {
    try {
      final data = await _client
          .from('submissions')
          .select('marks_awarded, questions!inner(assessment_id, assessments!inner(course_id))')
          .eq('student_id', studentId)
          .eq('questions.assessments.course_id', courseId);

      final submissions = data as List;

      // Safely cast to int
      final totalScore = submissions.fold<int>(
        0,
        (sum, row) => sum + ((row['marks_awarded'] as num?)?.toInt() ?? 0),
      );

      return totalScore;
    } catch (e) {
      print("❌ Error fetching total score: $e");
      return 0;
    }
  }
}
