import 'package:supabase_flutter/supabase_flutter.dart';

class QuizService {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchQuizData(String sectionId) async {
    try {
      print('🔍 Fetching quiz for section: "$sectionId"');

      // 1. Find the assessment for this section
      final assessment = await _client
          .from('assessments')
          .select('id, title, section_id, type')
          .eq('section_id', sectionId)  // ← Dynamic: use the section ID
          .eq('type', 'quiz')
          .maybeSingle();

      if (assessment == null) {
        print('❌ No quiz assessment found for section: $sectionId');
        return [];
      }

      print('✅ Found assessment: ${assessment['title']}');
      print('   Assessment ID: ${assessment['id']}');
      print('   Section ID: ${assessment['section_id']}');
      print('   Type: ${assessment['type']}');

      final assessmentId = assessment['id'] as String;

      // 2. Get questions for this assessment
      final questionsRes = await _client
          .from('questions')
          .select('id, question_text')
          .eq('assessment_id', assessmentId);

      print('❓ Questions found: ${questionsRes.length}');

      final quizData = <Map<String, dynamic>>[];
      for (var q in questionsRes) {
        final questionId = q['id'] as String;
        final optsRes = await _client
            .from('options')
            .select('id, option_text, is_correct')
            .eq('question_id', questionId);

        if (optsRes.isNotEmpty) {
          // Build options as List<Map<String, dynamic>>
          final options = optsRes.map<Map<String, dynamic>>((o) => {
            'id': o['id'],
            'text': o['option_text'],
          }).toList();
          final correctOption = optsRes.firstWhere(
            (o) => o['is_correct'] == true,
            orElse: () => {},
          );

          if (correctOption.isNotEmpty) {
            quizData.add({
              'id': questionId,
              'question': q['question_text'],
              'options': options,
              'answer_id': correctOption['id'],
              'answer': correctOption['option_text'],
              'assessment_id': assessmentId,
            });
          }
        }
      }

      print('🎯 Final quiz data: ${quizData.length} questions');
      return quizData;

    } catch (e) {
      print("❌ Error fetching quiz: $e");
      return [];
    }
  }
}