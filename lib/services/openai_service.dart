import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class OpenAIService {
  static const String apiKey = String.fromEnvironment('OPENAI_API_KEY', defaultValue: '');
  static const String apiUrl = 'https://api.openai.com/v1/chat/completions';

  Future<Question> getAPCSQuestion() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content': 'You are an AP Computer Science teacher. Generate a multiple choice question about Java programming concepts. Format the response as JSON with fields: question, options (array of 4 strings), correct_answer, and explanation.'
          },
          {
            'role': 'user',
            'content': 'Generate an APCS multiple choice question'
          }
        ],
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return Question.fromJson(jsonDecode(content));
    } else {
      throw Exception('Failed to load question');
    }
  }
} 