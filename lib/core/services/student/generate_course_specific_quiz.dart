import 'package:supabase_flutter/supabase_flutter.dart';

class QuizService {
  final _client = Supabase.instance.client;

  /// Fetches all MCQ quiz data for a given course.
  /// Returns a list of maps:
  /// [
  ///   {
  ///     'id': 'questionId',
  ///     'question': '...',
  ///     'options': ['opt1','opt2',...],
  ///     'answer': 'correctOption',
  ///   },
  ///   ...
  /// ]
  Future<List<Map<String, dynamic>>> fetchQuizData(String courseId) async {
    try {
      final assRes = await _client
          .from('assessments')
          .select('id')
          .eq('course_id', courseId)
          .eq('type', 'quiz');

      if ((assRes as List).isEmpty) return [];

      final assessmentIds = assRes.map((e) => e['id'] as String).toList();

      final questionsRes = await _client
          .from('questions')
          .select('id, question_text')
          .inFilter('assessment_id', assessmentIds);

      if ((questionsRes as List).isEmpty) return [];

      final quizData = <Map<String, dynamic>>[];

      for (var q in questionsRes) {
        final questionId = q['id'] as String;
        final optsRes = await _client
            .from('options')
            .select('id, option_text, is_correct')
            .eq('question_id', questionId)
            .order('order', ascending: true);

        if ((optsRes as List).isEmpty) continue;

        final opts = (optsRes).map((o) => o['option_text'] as String).toList();
        final correctOptions = (optsRes).where((o) => o['is_correct'] == true);
        if (correctOptions.isEmpty) continue;

        final correct = correctOptions.first['option_text'] as String;

        quizData.add({
          'id': questionId, // ✅ include question id for submissions
          'question': q['question_text'] as String,
          'options': opts,
          'answer': correct,
        });
      }

      return quizData;
    } catch (e) {
      print('Error fetching quiz data: $e');
      return [];
    }
  }
}
