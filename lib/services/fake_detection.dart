import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class FakeDetection {
  static final String _apiKey = Config.deepseekApiKey;
  static const String _apiUrl = 'https://api.deepseek.com/v1/chat/completions';

  static Future<Map<String, dynamic>> analyzeProduct(
      String name, String description, double price) async {
    final prompt = '''
You are a product authenticity expert. Analyze this product listing:
Product Name: $name
Description: $description
Price: \$$price

Return a JSON object with exactly these two fields:
- "fakeProbability": a number between 0 and 1
- "reasons": a list of strings (max 3)

Output ONLY valid JSON.
''';

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'deepseek-chat',
        'messages': [
          {'role': 'system', 'content': 'You are an expert assistant.'},
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.3,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'];
      return jsonDecode(content);
    } else {
      throw Exception('DeepSeek API error: ${response.statusCode}');
    }
  }
}