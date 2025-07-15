import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:knowble_app/core/config/api_config.dart';

class GeminiService {
  final String apiKey = ApiConfig.geminiApiKey;
  static const String baseURL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const String fallbackURL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  GeminiService();

  // Future<String> _generateResponse(String userPrompt, String option) async {
    

  //   final finalPrompt = await _promptfactory(userPrompt, option);
  // }

  Future<String> _promptfactory(String userPrompt, String option) async {
    // This method can be implemented to create a prompt based on user input and options



    // For now, it returns the user prompt directly
    return userPrompt;
  }

  /// Generate content using Gemini API with retry mechanism
  Future<String> generateContent(String prompt, {int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final url = Uri.parse('$baseURL?key=$apiKey');
        
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

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode(requestBody),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          
          if (data['candidates'] != null && 
              data['candidates'].isNotEmpty &&
              data['candidates'][0]['content'] != null &&
              data['candidates'][0]['content']['parts'] != null &&
              data['candidates'][0]['content']['parts'].isNotEmpty) {
            
            return data['candidates'][0]['content']['parts'][0]['text'] ?? 'No response generated';
          } else {
            return 'Sorry, I couldn\'t generate a response. Please try again.';
          }
        } else if (response.statusCode == 503) {
          print('Gemini API Overloaded (Attempt $attempt/$maxRetries): ${response.body}');
          if (attempt < maxRetries) {
            // Wait with exponential backoff: 1s, 2s, 4s
            final delay = Duration(seconds: attempt * attempt);
            print('Retrying in ${delay.inSeconds} seconds...');
            await Future.delayed(delay);
            continue;
          } else {
            return 'Sorry, the AI service is currently busy. Please try again in a few moments.';
          }
        } else {
          print('Gemini API Error: ${response.statusCode} - ${response.body}');
          return 'Sorry, I\'m having trouble connecting. Please try again later.';
        }
      } catch (e) {
        print('Error calling Gemini API (Attempt $attempt/$maxRetries): $e');
        if (attempt < maxRetries) {
          await Future.delayed(Duration(seconds: attempt));
          continue;
        } else {
          return 'Sorry, something went wrong. Please try again.';
        }
      }
    }
    
    return 'Sorry, I\'m unable to respond right now. Please try again later.';
  }


  /// Try with fallback model if primary model fails
  Future<String> generateContentWithFallback(String prompt) async {
    // First try the primary model
    String response = await generateContent(prompt, maxRetries: 2);
    return response;
  }

  // Future<String> _promptfactory(String userPrompt, String option) async {
  //     if ()
  // }

  /// Generate educational content with context
  Future<String> generateEducationalResponse(String subject, String question) async {
    final educationalPrompt = '''
You are an AI study assistant helping students learn. Please provide a helpful, educational response to this question.

Subject: $subject
Question: $question

Guidelines:
- Provide clear, accurate information
- Use examples when helpful
- Break down complex concepts into simple terms
- Be encouraging and supportive
- Use markdown formatting for better readability
- Include step-by-step explanations when appropriate

Response:''';

    return await generateContent(educationalPrompt);
  }

  /// Generate study tips and explanations
  Future<String> generateStudyHelp(String topic, String difficulty) async {
    final studyPrompt = '''
As an educational AI assistant, help a student understand this topic:

Topic: $topic
Difficulty Level: $difficulty

Please provide:
1. A clear explanation of the concept
2. Key points to remember
3. Common mistakes to avoid
4. Study tips specific to this topic
5. Practice suggestions

Format your response using markdown for better readability.''';

    return await generateContent(studyPrompt);
  }
}