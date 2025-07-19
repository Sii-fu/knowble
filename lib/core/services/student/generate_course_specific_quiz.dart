import 'package:supabase_flutter/supabase_flutter.dart';

class QuizService {
  final _client = Supabase.instance.client;

  /// Fetches all MCQ quiz data for a given course.
  /// Returns a list of maps:
  /// [
  ///   {
  ///     'question': '...',
  ///     'options': ['opt1','opt2',...],
  ///     'answer': 'correctOption',
  ///   },
  ///   ...
  /// ]
  Future<List<Map<String, dynamic>>> fetchQuizData(String courseId) async {
    try {
      // 1️⃣ Get all quiz-type assessments for this course
      // print('Fetching quiz data for course: $courseId');
      final assRes = await _client
          .from('assessments')
          .select('id')
          .eq('course_id', courseId)  
          .eq('type', 'quiz'); 

      if ((assRes as List).isEmpty) {
        // print('No quiz assessments found for course: $courseId');
        return []; // No quiz assessments found
      } else {
        print('Fetched ${assRes.length} quiz assessments for course: $courseId');
      }

      final assessmentIds = (assRes as List).map((e) => e['id'] as String).toList();

      // 2️⃣ Get all questions for those assessments
      try {
        final questionsRes = await _client
            .from('questions')
            .select('id, question_text')
            .inFilter('assessment_id', assessmentIds);

        if ((questionsRes as List).isEmpty) {
          print('No questions found for course: $courseId');
          return []; // No questions found
        } else {
          // print('Fetched ${questionsRes.length} questions for course: $courseId');
        }

        final questions = (questionsRes as List)
            .map((q) => {
                  'id': q['id'] as String,
                  'question': q['question_text'] as String,
                })
            .toList();

        // 3️⃣ For each question, fetch its options
        final quizData = <Map<String, dynamic>>[];

        for (var q in questions) {
          final questionId = q['id'] as String;
          try {
            final optsRes = await _client
                .from('options')
                .select('option_text, is_correct')
                .eq('question_id', questionId)
                .order('order', ascending: true);

            if ((optsRes as List).isEmpty) continue;

            final opts = (optsRes as List).map((o) => o['option_text'] as String).toList();
            
            // Find correct answer safely
            final correctOptions = (optsRes as List).where((o) => o['is_correct'] == true);
            if (correctOptions.isEmpty) continue; // Skip questions without correct answers
            
            final correct = correctOptions.first['option_text'] as String;

            quizData.add({
              'question': q['question'],
              'options': opts,
              'answer': correct,
            });
          } catch (optionError) {
            print('Error fetching options for question $questionId: $optionError');
            continue; // Skip this question and continue with others
          }
        }
        
        print('Fetched ${quizData.length} quiz questions for course: $courseId');
        return quizData;
      } catch (questionError) {
        print('Error fetching questions: $questionError');
        print('Assessment IDs: $assessmentIds');
        return [];
      }
    } catch (e) {
      print('Error fetching quiz data: $e');
      return [];
    }
  }
}
