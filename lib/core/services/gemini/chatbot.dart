import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:knowble_app/core/config/api_config.dart';

class GeminiService {
  final String apiKey = ApiConfig.geminiApiKey;
  static const String baseURL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const String fallbackURL = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  GeminiService();

  Future<String> _generateResponse(String userPrompt, String option) async {

    final formattedPrompt = await _promptFactory(userPrompt, option);
    final systemPrompt = '''You are StudyBuddy-G, a smart, chill, no-nonsense study assistant who helps the user with learning anything — from breaking down tough concepts to summarizing dense textbooks. You speak in a friendly, engaging tone with a mix of clarity. You always aim to:
- simplify complex stuff without dumbing it down,
- explain using analogies, visuals (if asked), or examples,
- suggest better ways to remember/study a topic,
- NEVER act robotic or overly formal.
You’re not just a tutor — you’re the user’s academic ride-or-die.
''';

    final fullPrompt = '$systemPrompt\n\nUser says: $formattedPrompt';

    return await generateContent(fullPrompt);
  }

  Future<String> _promptFactory(String userPrompt, String option) async {
    switch (option) {
      case 'Solve':
        return 'Solve this problem step-by-step with reasoning: $userPrompt';
      case 'Concept':
        return 'Explain the core concept of "$userPrompt" with simple analogies and real-world examples. Avoid jargon.';
      case 'Examples':
        return 'Give 3 clear and diverse examples that illustrate: $userPrompt';
      case 'Steps':
        return 'Break down how to do "$userPrompt" into clear, ordered steps. Include tips if helpful.';
      case 'Trick':
        return 'Share a clever trick or shortcut to understand or solve: $userPrompt';
      case 'Explain':
      case 'Break it down':
      case 'ELI5':
        return 'Explain "$userPrompt" like I\'m 5 years old, but don’t be condescending. Use analogies.';
      case 'Process':
        return 'Describe the entire process of "$userPrompt" from start to finish, like a tutorial.';
      case 'Compare':
        return 'Compare and contrast: $userPrompt. Focus on differences, pros and cons, and use a table if needed.';
      case 'Why?':
        return 'Explain why "$userPrompt" happens or exists. Dive into cause-effect.';
      case 'Timeline':
        return 'Create a timeline showing major events or milestones related to: $userPrompt';
      case 'Event':
        return 'What happened in "$userPrompt"? Describe the background, key moments, and its impact.';
      case 'Figure':
        return 'Who is "$userPrompt"? Summarize their contributions and why they matter.';
      case 'Impact':
        return 'What impact did "$userPrompt" have on society, technology, or history? Include long-term effects.';
      case 'Analyze':
        return 'Analyze "$userPrompt" like a lit teacher with a magnifying glass. Go deep—language, intent, message, impact.';
      case 'Theme':
        return 'What is the underlying theme or message behind "$userPrompt"? Give a thoughtful explanation.';
      case 'Essay Help':
        return 'Help me structure and write an essay about: "$userPrompt". Include outline + thesis suggestion.';
      case 'Grammar':
      case 'Improve Writing':
        return 'Correct grammar, fix clarity, and improve the tone of this writing: "$userPrompt"';
      case 'Figurative':
        return 'Find and explain the figurative language and hidden meanings in: "$userPrompt"';
      case 'Debug':
        return 'Find and fix the error in this code or logic: "$userPrompt". Explain why it was wrong.';
      case 'How to':
        return 'Teach me how to: $userPrompt. Make it clear, practical, and beginner-friendly.';
      case 'Plan':
        return 'Create a detailed plan for: "$userPrompt" including steps, timeline, and resources needed.';
      case 'Simplify':
        return 'Simplify "$userPrompt" into basic terms for someone just starting out.';
      case 'Summarize':
        return 'Give a short, sharp summary of: "$userPrompt". Keep it under 100 words if possible.';
      case 'Write':
        return 'Write something creative based on "$userPrompt" — story, poem, or scene.';
      case 'Ask Anything':
        return 'Answer this thoughtfully and helpfully: "$userPrompt"';
      case 'Translate':
        return 'Translate the following text into English or another language: "$userPrompt"';
      case 'Tips':
        return 'Give actionable tips and advice about: "$userPrompt"';
      case 'Pros & Cons':
        return 'List the pros and cons of "$userPrompt" with explanations for each.';
      case 'Use Cases':
        return 'What are some real-world use cases of "$userPrompt"? Include industries or scenarios.';
      case 'Study Help':
        return 'Help me study and understand this topic: "$userPrompt". Use summaries, questions, and mnemonics if useful.';
      default:
        return userPrompt;
    }
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
            'topK': 10,
            'topP': 0.8,
            'maxOutputTokens': 1500,
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
  Future<String> generateContentWithFallback(String prompt, String option) async {
    // First try the primary model
    String response = await _generateResponse(prompt, option);
    return response;
  }

  // Future<String> _promptfactory(String userPrompt, String option) async {
  //     if ()
  // }

  /// Generate educational content with context
  
}