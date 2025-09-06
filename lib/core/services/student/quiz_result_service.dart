import 'package:supabase_flutter/supabase_flutter.dart';

class QuizResultService {
  final _client = Supabase.instance.client;

  Future<void> saveQuizResult({
    required String studentId,
    required String assessmentId,
    required String sectionId,
    required String status, // 'pass' or 'fail'
    required int score,
  }) async {
    if (studentId.isEmpty || assessmentId.isEmpty || sectionId.isEmpty) {
      print('⚠️ QuizResultService: One or more required UUIDs are empty.');
      print('studentId: $studentId');
      print('assessmentId: $assessmentId');
      print('sectionId: $sectionId');
      return;
    }
    try {
      final payload = {
        'student_id': studentId,
        'assessment_id': assessmentId,
        'section_id': sectionId,
        'status': status,
        'score': score,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      };
      print('🔎 Attempting to upsert quiz result with payload:');
      print(payload);
      final response = await _client.from('quiz_results').upsert(
        payload,
        onConflict: 'student_id,assessment_id,section_id',
      ).select();
      print('🟢 Supabase upsert response: $response');
      print('✅ Quiz result saved: $status, score: $score');
    } catch (e) {
      print('❌ Error saving quiz result: $e');
    }
  }
}
