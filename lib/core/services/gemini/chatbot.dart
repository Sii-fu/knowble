import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Knowble/core/config/api_config.dart';

class GeminiService {
  final String apiKey = ApiConfig.geminiApiKey;
  static const String baseURL =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const String fallbackURL =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  GeminiService();

  Future<String> _generateResponse(String userPrompt, String option) async {
  final formattedPrompt = await _promptFactory(userPrompt, option);
    final systemPrompt =
        '''You are StudyBuddy-G, a smart, chill, no-nonsense study assistant who helps the user with learning anything — from breaking down tough concepts to summarizing dense textbooks. You speak in a friendly, engaging tone with a mix of clarity. You always aim to:
- simplify complex stuff without dumbing it down,
- explain using analogies, visuals (if asked), or examples,
- suggest better ways to remember/study a topic,
- NEVER act robotic or overly formal.
You’re not just a tutor — you’re the user’s academic ride-or-die.
''';

  // Keep the option-based instruction separate from the user's text.
  // First include the chosen instruction, then add the user's prompt on its own line.
  final fullPrompt = '$systemPrompt\n\n$formattedPrompt\n\nUser says: $userPrompt';

    return await generateContent(fullPrompt);
  }

  Future<String> _promptFactory(String userPrompt, String option) async {
    switch (option) {
      case 'Solve':
        return 'Provide a clear, step-by-step solution to the problem. Show all intermediate steps, explain each manipulation or assumption, highlight common pitfalls, and finish with a concise final answer. Use numbered steps and simple notation.';
      case 'Concept':
        return 'Define the core concept clearly, list its main properties, show 2 short real-world examples, provide a simple analogy to aid intuition, and note one common misconception to avoid. Keep language plain and concise.';
      case 'Examples':
        return 'Give 3 diverse, worked examples that demonstrate the idea. For each example, state the problem, show the solution step-by-step, and provide a one-sentence takeaway about what the example illustrates.';
      case 'Steps':
        return 'Break the task into a clear, ordered checklist of actionable steps. For each step include how long it should take, any prerequisites, and a short tip to avoid mistakes.';
      case 'Trick':
        return 'Provide a concise trick or shortcut that simplifies solving or understanding the problem, explain why it works, show a short example of it in use, and warn when it should not be applied.';
      case 'Explain':
      case 'Break it down':
      case 'ELI5':
        return 'Explain the idea in very simple terms, using a friendly analogy and plain language suitable for a beginner. Avoid jargon and keep sentences short.';
      case 'Process':
        return 'Provide a start-to-finish tutorial: prerequisites, sequence of steps, expected outcomes at each stage, common errors, and a short checklist to verify success.';
      case 'Compare':
        return 'Compare the two or more items clearly: list similarities, list differences, pros and cons for each, and give a recommendation for which to choose in specific scenarios. Use a short table if it helps clarity.';
      case 'Why?':
        return 'Explain the underlying causes or reasoning behind the phenomenon. Describe cause-and-effect relationships, include any supporting evidence or intuition, and summarize in one sentence.';
      case 'Timeline':
        return 'Create a chronological timeline of the major events or milestones, include dates (if known), short descriptions (1–2 sentences) for each event, and a brief note about the significance of the sequence.';
      case 'Event':
        return 'Summarize the event: give concise background, list the key moments in order, and explain the immediate and long-term impacts. Keep the summary focused and factual.';
      case 'Figure':
        return 'Provide a short bio: key accomplishments, why they matter, one notable quote or contribution, and suggested further reading if available.';
      case 'Impact':
        return 'Analyze the impact on society, technology, or the field: immediate effects, long-term consequences, and who benefited or was disadvantaged. Conclude with a short summary.';
      case 'Analyze':
        return 'Perform a close analysis: identify key themes or components, interpret intent or meaning, examine structure or technique used, and conclude with the main takeaway and evidence supporting it.';
      case 'Theme':
        return 'Identify and explain the central theme or message. Provide 2–3 supporting points or examples that demonstrate the theme, and suggest one question for further thought.';
      case 'Essay Help':
        return 'Provide an essay plan: a concise thesis statement, a 3–5 paragraph outline with topic sentences for each paragraph, key evidence points, and a suggested intro and conclusion paragraph.';
      case 'Grammar':
      case 'Improve Writing':
        return 'Edit the provided text for grammar, clarity, and tone. Return the improved version and a brief list of the main changes and why they help.';
      case 'Figurative':
        return 'Identify figurative language (metaphor, simile, personification, etc.), explain the likely meaning or effect of each, and say how they contribute to the overall message or mood.';
      case 'Debug':
        return 'Locate the bug or logical error, explain why it occurs, provide a corrected version of the code or algorithm, and give a brief test or example showing the fix works.';
      case 'How to':
        return 'Give a concise, practical how-to guide with prerequisites, step-by-step instructions, expected pitfalls, and a short checklist to confirm success.';
      case 'Plan':
        return 'Create a detailed plan: list goals, break tasks into phases with estimated durations, assign simple resource suggestions, and include 2 milestone checkpoints with success criteria.';
      case 'Simplify':
        return 'Rewrite the idea in the simplest possible language for a beginner, define any minimal technical terms, and give one quick example to demonstrate.';
      case 'Summarize':
        return 'Provide a concise summary (about 2–4 sentences) that captures the main points and significance. Keep it short and focused.';
      case 'Write':
        return 'Produce a short creative piece (story, scene, or poem) matching the requested tone and length. Keep it engaging and coherent, and include one vivid detail to ground the scene.';
      case 'Ask Anything':
        return 'Provide a clear, helpful answer that addresses the user’s question, include concise supporting points or examples, and end with one actionable next step the user can take.';
      case 'Translate':
        return 'Translate the provided text into idiomatic English while preserving tone and meaning. If a different target language is specified by the user, translate into that language and note any ambiguous phrases.';
      case 'Tips':
        return 'List 5 actionable tips or best practices, each with a one-sentence explanation and one quick example of application.';
      case 'Pros & Cons':
        return 'List key pros and cons in bullet form, give one-sentence explanations for each point, and provide a brief recommendation for specific scenarios.';
      case 'Use Cases':
        return 'List relevant real-world use cases across industries or settings. For each use case, give a one-line description of why it fits and one expected benefit.';
      case 'Study Help':
        return 'Provide a study guide: a short summary, 5 practice questions (with brief answers), and a mnemonic or tip for remembering the key idea.';
      default:
        return 'Respond directly to the user request.';
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
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.9,
            'topK': 10,
            'topP': 0.8,
            'maxOutputTokens': 1500,
            'stopSequences': [],
          },
        };

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
            return data['candidates'][0]['content']['parts'][0]['text'] ??
                'No response generated';
          } else {
            return 'Sorry, I couldn\'t generate a response. Please try again.';
          }
        } else if (response.statusCode == 503) {
          print(
            'Gemini API Overloaded (Attempt $attempt/$maxRetries): ${response.body}',
          );
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
  Future<String> generateContentWithFallback(
    String prompt,
    String option,
  ) async {
    // First try the primary model
    String response = await _generateResponse(prompt, option);
    return response;
  }

  // Future<String> _promptfactory(String userPrompt, String option) async {
  //     if ()
  // }

  /// Generate educational content with context
}
