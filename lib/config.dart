import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get serperApiKey => dotenv.env['SERPER_API_KEY'] ?? '';
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get deepseekApiKey => dotenv.env['DEEPSEEK_API_KEY'] ?? '';
  static String get placesApiKey => dotenv.env['PLACES_API_KEY'] ?? '';
}