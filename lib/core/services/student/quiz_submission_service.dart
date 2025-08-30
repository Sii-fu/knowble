import 'package:supabase_flutter/supabase_flutter.dart';

class QuizSubmissionService {
  final _client = Supabase.instance.client;

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
      print("Error inserting submission: $e");
      rethrow;
    }
  }

  Future<int> fetchTotalScore(String studentId, String sectionId) async {
    try {
      // ✅ get all assessments in this section
      final assRes = await _client
          .from('assessments')
          .select('id')
          .eq('section_id', sectionId)
          .eq('type', 'quiz');

      if ((assRes as List).isEmpty) return 0;

      final assessmentIds = assRes.map((e) => e['id']).toList();

      // ✅ get all question IDs from those assessments - FIXED: use inFilter
      final qRes = await _client
          .from('questions')
          .select('id')
          .inFilter('assessment_id', assessmentIds); // ✅ Corrected

      if ((qRes as List).isEmpty) return 0;

      final questionIds = qRes.map((e) => e['id']).toList();

      // ✅ sum marks awarded from submissions for those questions - FIXED: use inFilter
      final subRes = await _client
          .from('submissions')
          .select('marks_awarded')
          .eq('student_id', studentId)
          .inFilter('question_id', questionIds); // ✅ Corrected

      if ((subRes as List).isEmpty) return 0;

      final total = (subRes as List)
          .map((s) => (s['marks_awarded'] as num?) ?? 0)
          .fold<int>(0, (a, b) => a + b.toInt());

      return total;
    } catch (e) {
      print("Error fetching total score: $e");
      return 0;
    }
  }
}