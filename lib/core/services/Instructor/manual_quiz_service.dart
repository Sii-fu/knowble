import 'package:supabase_flutter/supabase_flutter.dart';

class ManualQuizService {
  final SupabaseClient supabase = Supabase.instance.client;

  /// Create an assessment for a given section and insert questions + options.
  ///
  /// quizzes: List of maps with shape: { 'question': String, 'options': [ { 'text': String, 'is_correct': bool }, ... ] }
  /// Returns a map on success: { assessment_id, questions_inserted, options_inserted }
  /// Returns null on failure.
  Future<Map<String, dynamic>?> createAssessmentWithQuizzes({
    required String sectionId,
    required String title,
    required List<Map<String, dynamic>> quizzes,
  }) async {
    if (sectionId.isEmpty || title.isEmpty || quizzes.isEmpty) return null;

    // Validate quizzes shape
    for (final q in quizzes) {
      if (q['question'] == null || (q['options'] as List?) == null) return null;
    }

    String? assessmentId;
    List insertedQuestionRows = [];
    try {
      // Insert assessment
      final assessmentResp = await supabase
          .from('assessments')
          .insert({
            'section_id': sectionId,
            'title': title,
            'type': 'quiz',
            'total_marks': quizzes.length,
          })
          .select()
          .maybeSingle();

      if (assessmentResp == null || assessmentResp['id'] == null) {
        return null;
      }
      assessmentId = assessmentResp['id'].toString();

      // Prepare questions payload
      final questionsPayload = <Map<String, dynamic>>[];
      for (final q in quizzes) {
        questionsPayload.add({
          'assessment_id': assessmentId,
          'question_text': q['question']?.toString() ?? '',
          'type': 'text',
          'marks': 1,
        });
      }

      // Insert questions (multiple)
      final questionsResp = await supabase.from('questions').insert(questionsPayload).select();
      insertedQuestionRows = List.from(questionsResp as List? ?? []);
      if (insertedQuestionRows.isEmpty) {
        // rollback assessment
        await supabase.from('assessments').delete().eq('id', assessmentId);
        return null;
      }

      // Build options payload using returned question ids
      final optionsPayload = <Map<String, dynamic>>[];
      for (int i = 0; i < insertedQuestionRows.length; i++) {
        final qRow = insertedQuestionRows[i] as Map<String, dynamic>;
        final qid = qRow['id']?.toString();
        if (qid == null) continue;
        final origOptions = (quizzes[i]['options'] as List).cast<Map<String, dynamic>>();
        for (int j = 0; j < origOptions.length; j++) {
          final opt = origOptions[j];
          optionsPayload.add({
            'question_id': qid,
            'option_text': opt['text']?.toString() ?? '',
            'is_correct': opt['is_correct'] == true,
            'order': j + 1,
          });
        }
      }

      // Insert options
      final optionsResp = await supabase.from('options').insert(optionsPayload).select();
      final insertedOptions = List.from(optionsResp as List? ?? []);

      return {
        'assessment_id': assessmentId,
        'questions_inserted': insertedQuestionRows.length,
        'options_inserted': insertedOptions.length,
      };
    } catch (e) {
      // Attempt rollback if partially inserted
      try {
        if (insertedQuestionRows.isNotEmpty) {
          final ids = insertedQuestionRows.map((r) => r['id']).where((id) => id != null).toList();
          if (ids.isNotEmpty) {
            await supabase.from('options').delete().filter('question_id', 'in', '(${ids.map((id) => '"$id"').join(',')})');
            await supabase.from('questions').delete().filter('id', 'in', '(${ids.map((id) => '"$id"').join(',')})');
          }
        }
        if (assessmentId != null) {
          await supabase.from('assessments').delete().eq('id', assessmentId);
        }
      } catch (_) {}
      return null;
    }
  }
}
