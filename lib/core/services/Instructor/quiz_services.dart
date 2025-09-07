import 'package:supabase_flutter/supabase_flutter.dart';

class QuizService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all assessments (quizzes) for a given section
  Future<List<Map<String, dynamic>>> fetchAssessmentsBySection(String sectionId) async {
    try {
      final response = await _supabase
          .from('assessments')
          .select('*')
          .eq('section_id', sectionId)
          .order('title');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch assessments: $e');
    }
  }

  /// Fetch all questions for a given assessment
  Future<List<Map<String, dynamic>>> fetchQuestionsByAssessment(String assessmentId) async {
    try {
      final response = await _supabase
          .from('questions')
          .select('*')
          .eq('assessment_id', assessmentId)
          .order('id');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch questions: $e');
    }
  }

  /// Fetch all options for a given question
  Future<List<Map<String, dynamic>>> fetchOptionsByQuestion(String questionId) async {
    try {
      final response = await _supabase
          .from('options')
          .select('*')
          .eq('question_id', questionId)
          .order('order');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch options: $e');
    }
  }

  /// Fetch complete quiz data for a section (assessments with questions and options)
  Future<List<Map<String, dynamic>>> fetchCompleteQuizData(String sectionId) async {
    try {
      // Fetch assessments
      final assessments = await fetchAssessmentsBySection(sectionId);
      
      // For each assessment, fetch questions and their options
      for (var assessment in assessments) {
        final questions = await fetchQuestionsByAssessment(assessment['id']);
        
        // For each question, fetch options
        for (var question in questions) {
          final options = await fetchOptionsByQuestion(question['id']);
          question['options'] = options;
        }
        
        assessment['questions'] = questions;
      }
      
      return assessments;
    } catch (e) {
      throw Exception('Failed to fetch complete quiz data: $e');
    }
  }

  /// Get submissions count for a specific assessment
  Future<int> getSubmissionCount(String assessmentId) async {
    try {
      final response = await _supabase
          .from('submissions')
          .select('student_id')
          .eq('question_id', assessmentId);

      // Count unique students
      final uniqueStudents = <String>{};
      for (var submission in response) {
        uniqueStudents.add(submission['student_id'].toString());
      }
      
      return uniqueStudents.length;
    } catch (e) {
      throw Exception('Failed to fetch submission count: $e');
    }
  }

  // ========== CRUD Operations ==========

  /// Create a new assessment
  Future<Map<String, dynamic>> createAssessment({
    required String sectionId,
    required String title,
    required String type,
    required int totalMarks,
  }) async {
    try {
      final response = await _supabase
          .from('assessments')
          .insert({
            'section_id': sectionId,
            'title': title,
            'type': type,
            'total_marks': totalMarks,
          })
          .select()
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to create assessment: $e');
    }
  }

  /// Update an existing assessment
  Future<Map<String, dynamic>> updateAssessment({
    required String assessmentId,
    required String title,
    required String type,
    required int totalMarks,
  }) async {
    try {
      final response = await _supabase
          .from('assessments')
          .update({
            'title': title,
            'type': type,
            'total_marks': totalMarks,
          })
          .eq('id', assessmentId)
          .select()
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to update assessment: $e');
    }
  }

  /// Delete an assessment and all its questions/options
  Future<void> deleteAssessment(String assessmentId) async {
    try {
      // First delete all options for questions in this assessment
      final questions = await fetchQuestionsByAssessment(assessmentId);
      for (var question in questions) {
        await _supabase
            .from('options')
            .delete()
            .eq('question_id', question['id']);
      }

      // Then delete all questions in this assessment
      await _supabase
          .from('questions')
          .delete()
          .eq('assessment_id', assessmentId);

      // Finally delete the assessment
      await _supabase
          .from('assessments')
          .delete()
          .eq('id', assessmentId);
    } catch (e) {
      throw Exception('Failed to delete assessment: $e');
    }
  }

  /// Create a new question
  Future<Map<String, dynamic>> createQuestion({
    required String assessmentId,
    required String questionText,
    required String type,
    required int marks,
  }) async {
    try {
      final response = await _supabase
          .from('questions')
          .insert({
            'assessment_id': assessmentId,
            'question_text': questionText,
            'type': type,
            'marks': marks,
          })
          .select()
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to create question: $e');
    }
  }

  /// Update an existing question
  Future<Map<String, dynamic>> updateQuestion({
    required String questionId,
    required String questionText,
    required String type,
    required int marks,
  }) async {
    try {
      final response = await _supabase
          .from('questions')
          .update({
            'question_text': questionText,
            'type': type,
            'marks': marks,
          })
          .eq('id', questionId)
          .select()
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to update question: $e');
    }
  }

  /// Delete a question and all its options
  Future<void> deleteQuestion(String questionId) async {
    try {
      // First delete all options for this question
      await _supabase
          .from('options')
          .delete()
          .eq('question_id', questionId);

      // Then delete the question
      await _supabase
          .from('questions')
          .delete()
          .eq('id', questionId);
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }

  /// Create a new option
  Future<Map<String, dynamic>> createOption({
    required String questionId,
    required String optionText,
    required bool isCorrect,
    required int order,
  }) async {
    try {
      final response = await _supabase
          .from('options')
          .insert({
            'question_id': questionId,
            'option_text': optionText,
            'is_correct': isCorrect,
            'order': order,
          })
          .select()
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to create option: $e');
    }
  }

  /// Update an existing option
  Future<Map<String, dynamic>> updateOption({
    required String optionId,
    required String optionText,
    required bool isCorrect,
    required int order,
  }) async {
    try {
      final response = await _supabase
          .from('options')
          .update({
            'option_text': optionText,
            'is_correct': isCorrect,
            'order': order,
          })
          .eq('id', optionId)
          .select()
          .single();

      return Map<String, dynamic>.from(response);
    } catch (e) {
      throw Exception('Failed to update option: $e');
    }
  }

  /// Delete an option
  Future<void> deleteOption(String optionId) async {
    try {
      await _supabase
          .from('options')
          .delete()
          .eq('id', optionId);
    } catch (e) {
      throw Exception('Failed to delete option: $e');
    }
  }

  /// Bulk update options for a question (used when reordering or changing correct answers)
  Future<void> updateQuestionOptions({
    required String questionId,
    required List<Map<String, dynamic>> options,
  }) async {
    try {
      // Delete all existing options for this question
      await _supabase
          .from('options')
          .delete()
          .eq('question_id', questionId);

      // Insert new options
      for (int i = 0; i < options.length; i++) {
        await createOption(
          questionId: questionId,
          optionText: options[i]['option_text'] ?? '',
          isCorrect: options[i]['is_correct'] ?? false,
          order: i + 1,
        );
      }
    } catch (e) {
      throw Exception('Failed to update question options: $e');
    }
  }
}
