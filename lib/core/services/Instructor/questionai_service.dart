import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class QuestionAIService {
  // Helper to extract JSON array from AI response
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
  final String geminiApiKey;
  final SupabaseClient _supabase = Supabase.instance.client;

  QuestionAIService({required this.geminiApiKey});

  Future<void> generateAndStoreMCQs({
    required String courseId,
    required String assessmentTitle,
    required String type,
    required int totalMarks,
  }) async {
    // 1. Get all sections (lessons) of this course
    final modulesResponse = await _supabase
        .from('modules')
        .select('id')
        .eq('course_id', courseId);
    final moduleIds = modulesResponse.map((m) => m['id'] as String).toList();
    final sectionsResponse = await _supabase
        .from('sections')
        .select('id')
        .inFilter('module_id', moduleIds);
    final sectionIds = sectionsResponse.map((s) => s['id'] as String).toList();
    final contentsResponse = await _supabase
        .from('contents')
        .select('id, url')
        .eq('type', 'pdf')
        .inFilter('section_id', sectionIds);
    final pdfUrls = contentsResponse.map((c) => c['url'] as String).toList();
    if (pdfUrls.isEmpty) {
      throw Exception('No PDFs found to generate questions from.');
    }
    // 2. Extract text from PDFs (we assume they are public URLs and Gemini can access)
    String combinedPrompt = '';
    for (final url in pdfUrls) {
      combinedPrompt += 'Content from: $url\n';
    }
    final prompt = """
You are an AI assistant. Generate 5 MCQs (with 4 options each) from the following PDF course materials:
$combinedPrompt

Each question should follow this JSON format:
{
  "question": "...",
  "options": ["...", "...", "...", "..."],
  "answer_index": 0 // index of the correct option
}
Return only the JSON array.
""";
    // Use direct HTTP POST to Gemini API (like chatbot.dart)
    const String baseURL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
    final url = Uri.parse('$baseURL?key=$geminiApiKey');
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
        'topK': 1,
        'topP': 0.8,
        'maxOutputTokens': 512,
        'stopSequences': []
      }
    };
    String text = '';
    int maxRetries = 3;
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(requestBody),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['candidates'] != null &&
              data['candidates'].isNotEmpty &&
              data['candidates'][0]['content'] != null &&
              data['candidates'][0]['content']['parts'] != null &&
              data['candidates'][0]['content']['parts'].isNotEmpty) {
            text = data['candidates'][0]['content']['parts'][0]['text'] ?? '';
            break;
          } else {
            throw Exception("No valid response from Gemini API");
          }
        } else if (response.statusCode == 503) {
          if (attempt < maxRetries) {
            await Future.delayed(Duration(seconds: attempt * attempt));
            continue;
          } else {
            throw Exception('Gemini API overloaded. Please try again later.');
          }
        } else {
          throw Exception('Gemini API Error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt));
          continue;
        } else {
          throw Exception('Failed to generate questions: $e');
        }
      }
    }
    if (text.isEmpty) {
      throw Exception('AI did not return any text.');
    }
    List<dynamic> questionsJson;
    try {
      final cleanText = _extractJsonArray(text);
      questionsJson = jsonDecode(cleanText);
    } catch (e) {
      throw Exception('AI response was not valid JSON: $text');
    }
    // 3. Store assessment
    final assessmentInsert = await _supabase.from('assessments').insert({
      'course_id': courseId,
      'title': assessmentTitle,
      'type': type,
      'total_marks': totalMarks,
    }).select().single();
    final assessmentId = assessmentInsert['id'];
    for (final question in questionsJson) {
      final insertedQuestion = await _supabase.from('questions').insert({
        'assessment_id': assessmentId,
        'question_text': question['question'],
        'type': type,
      }).select().single();
      final questionId = insertedQuestion['id'];
      for (int i = 0; i < question['options'].length; i++) {
        await _supabase.from('options').insert({
          'question_id': questionId,
          'option_text': question['options'][i],
          'is_correct': i == question['answer_index'],
        });
      }
    }
  }
}