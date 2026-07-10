import 'package:speech_to_text/speech_to_text.dart';

class STTService {
  static final STTService _instance = STTService._internal();
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  String _lastWords = "";

  factory STTService() {
    return _instance;
  }

  STTService._internal();

  /// Initialize the speech-to-text service
  Future<bool> initialize() async {
    try {
      bool available = await _speechToText.initialize(
        onError: (error) {
          print('Speech-to-Text Error: $error');
        },
        onStatus: (status) {
          print('Speech-to-Text Status: $status');
        },
        debugLogging: false,
      );
      return available;
    } catch (e) {
      print("Error initializing speech: $e");
      return false;
    }
  }

  /// Start listening for speech input
  Future<void> startListening({
    required Function(String) onResult,
    String languageCode = 'en_US',
  }) async {
    try {
      if (!_isListening) {
        bool available = await initialize();
        if (available) {
          _isListening = true;
          _speechToText.listen(
            onResult: (result) {
              _lastWords = result.recognizedWords;
              onResult(_lastWords);
            },
            localeId: languageCode,
            listenFor: const Duration(seconds: 30),
            pauseFor: const Duration(seconds: 5),
            partialResults: true,
            onSoundLevelChange: (level) {
              print('Sound level: $level');
            },
          );
        } else {
          print("Speech-to-text not available");
        }
      }
    } catch (e) {
      print("Error starting listening: $e");
      _isListening = false;
    }
  }

  /// Stop listening for speech
  Future<void> stopListening() async {
    try {
      if (_isListening) {
        _speechToText.stop();
        _isListening = false;
      }
    } catch (e) {
      print("Error stopping listening: $e");
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    try {
      _speechToText.cancel();
      _isListening = false;
    } catch (e) {
      print("Error cancelling listening: $e");
    }
  }

  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  bool get isAvailable => _speechToText.isAvailable;
  bool get isNotListening => !_isListening;
}
