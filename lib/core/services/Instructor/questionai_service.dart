import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:Knowble/core/config/api_config.dart';

class QuestionAIService {
  String _extractJsonArray(String text) {
    text = text.trim();
    if (text.startsWith('```')) {
      final firstNewline = text.indexOf('\n');
      if (firstNewline != -1) {
        text = text.substring(firstNewline + 1);
      }
      if (text.endsWith('```')) {
        text = text.substring(0, text.length - 3);
      }
      text = text.trim();
    }
    final start = text.indexOf('[');
    final end = text.lastIndexOf(']');
    if (start != -1 && end != -1 && end > start) {
      return text.substring(start, end + 1);
    }
    return text;
  }

  final String geminiApiKey = ApiConfig.geminiApiKey;
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> generateAndStoreMCQs({
    required String courseId,
    required String sectionId,
    required String assessmentTitle,
    required String type,
    required int totalMarks,
    void Function(String)? onStatus,
  }) async {
    if (geminiApiKey.trim().isEmpty || geminiApiKey.contains('REPLACE')) {
      throw Exception('Gemini API key is not configured. Please set ApiConfig.geminiApiKey.');
    }

    onStatus?.call('Generating questions from PDF...');

    // Fetch section metadata
    final section = await _supabase
        .from('sections')
        .select('title, description')
        .eq('id', sectionId)
        .maybeSingle();

    final contentsResponse = await _supabase
        .from('contents')
        .select('id, url')
        .eq('type', 'pdf')
        .eq('section_id', sectionId);

    final pdfUrls = List.from(contentsResponse as List? ?? [])
        .map((c) => (c as Map)['url'] as String)
        .toList();

    if (pdfUrls.isEmpty) {
      throw Exception('No PDFs found for this lesson to generate questions from.');
    }

    final lessonTitle = section?['title'] ?? '';
    final lessonDescription = section?['description'] ?? '';

    String combinedPrompt =
        'Lesson title: $lessonTitle\nLesson description: $lessonDescription\n';
    for (final url in pdfUrls) {
      combinedPrompt += 'Reference PDF: $url\n';
    }

    final prompt = """
You are an AI assistant. Using ONLY the provided PDF reference materials listed below, generate exactly $totalMarks multiple-choice questions for this lesson.

$combinedPrompt

Requirements:
- Generate exactly $totalMarks questions.
- Each question must be type 'mcq' with exactly 3 options.
- One option must be correct; the other two must be plausible distractors.
- Each option should be short (phrase/sentence).
- Each question has marks = 1 (don’t include marks in JSON).
- Return ONLY valid JSON array of objects:
  {
    "question": "...",
    "options": ["opt1", "opt2", "opt3"],
    "answer_index": 0
  }
""";

    // ✅ Use Gemini 2.0 Flash first
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiApiKey');

    final requestBody = {
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.9,
        'topK': 10,
        'topP': 0.8,
        'maxOutputTokens': 1500,
      }
    };

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    if (response.statusCode != 200) {
      // Try to parse friendly error message from the Gemini error body
      try {
        final err = json.decode(response.body);
        final msg = err is Map && err['error'] != null
            ? (err['error']['message'] ?? err['error'].toString())
            : (err['message'] ?? response.body);
        throw Exception('Gemini API Error ${response.statusCode}: $msg');
      } catch (_) {
        throw Exception('Gemini API Error ${response.statusCode}: ${response.body}');
      }
    }

    final data = json.decode(response.body);

    if (data['candidates'] == null ||
        data['candidates'].isEmpty ||
        data['candidates'][0]['content'] == null ||
        data['candidates'][0]['content']['parts'] == null ||
        data['candidates'][0]['content']['parts'].isEmpty) {
      throw Exception('No valid response from Gemini API.');
    }

    final text = data['candidates'][0]['content']['parts'][0]['text'] ?? '';
    if (text.isEmpty) throw Exception('AI did not return any text.');

    List<dynamic> questionsJson;
    try {
      final cleanText = _extractJsonArray(text);
      questionsJson = jsonDecode(cleanText) as List<dynamic>;
    } catch (e) {
      throw Exception('AI response was not valid JSON: $text');
    }

    onStatus?.call('Questions are being prepared...');

    final assessmentInsert = await _supabase.from('assessments').insert({
      'course_id': courseId,
      'title': assessmentTitle,
      'type': type,
      'total_marks': totalMarks,
    }).select().single();

    final assessmentId = assessmentInsert['id'];
    int insertedQuestions = 0;

    for (final q in questionsJson) {
      if (q == null || q['question'] == null || q['options'] == null) continue;

      final opts = List.from(q['options'] as List);
      if (opts.length < 3) continue;

      final options = opts.sublist(0, 3);
      final answerIndex =
          (q['answer_index'] is int) ? q['answer_index'] as int : 0;

      final insertedQuestion = await _supabase.from('questions').insert({
        'assessment_id': assessmentId,
        'question_text': q['question'],
        'type': 'mcq',
        'marks': 1,
      }).select().single();
      final questionId = insertedQuestion['id'];

      for (int i = 0; i < 3; i++) {
        await _supabase.from('options').insert({
          'question_id': questionId,
          'option_text': options[i] as String,
          'is_correct': i == answerIndex,
          'order': i + 1,
        });
      }
      insertedQuestions++;
    }

    return {
      'status': 'success',
      'assessment_id': assessmentId,
      'questions_inserted': insertedQuestions,
    };
  }
}
