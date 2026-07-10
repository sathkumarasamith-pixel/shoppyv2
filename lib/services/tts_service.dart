import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  static final TTSService _instance = TTSService._internal();
  final FlutterTts _flutterTts = FlutterTts();

  factory TTSService() {
    return _instance;
  }

  TTSService._internal() {
    _initializeTTS();
  }

  void _initializeTTS() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setPitch(1.0);
    _flutterTts.setSpeechRate(0.5);
  }

  /// Speak the given text using text-to-speech
  Future<void> speak(String text) async {
    try {
      if (text.isNotEmpty) {
        await _flutterTts.speak(text);
      }
    } catch (e) {
      print("Error speaking: $e");
    }
  }

  /// Stop the current speech
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      print("Error stopping speech: $e");
    }
  }

  /// Pause the current speech
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      print("Error pausing speech: $e");
    }
  }

  /// Resume paused speech
  Future<void> resume() async {
    try {
      await _flutterTts.resume();
    } catch (e) {
      print("Error resuming speech: $e");
    }
  }

  /// Set the language for TTS
  void setLanguage(String language) {
    _flutterTts.setLanguage(language);
  }

  /// Set the pitch for TTS (0.5 to 2.0)
  void setPitch(double pitch) {
    _flutterTts.setPitch(pitch);
  }

  /// Set the speech rate for TTS (0.1 to 2.0)
  void setSpeechRate(double rate) {
    _flutterTts.setSpeechRate(rate);
  }

  /// Set the volume for TTS (0.0 to 1.0)
  void setVolume(double volume) {
    _flutterTts.setVolume(volume);
  }
}
