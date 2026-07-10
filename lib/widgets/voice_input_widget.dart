import 'package:flutter/material.dart';
import 'package:shoppy/services/stt_service.dart';
import 'package:shoppy/services/tts_service.dart';

class VoiceInputWidget extends StatefulWidget {
  final Function(String) onTextReceived;
  final String hintText;
  final VoidCallback? onListeningStart;
  final VoidCallback? onListeningStop;

  const VoiceInputWidget({
    Key? key,
    required this.onTextReceived,
    this.hintText = "Tap microphone to speak",
    this.onListeningStart,
    this.onListeningStop,
  }) : super(key: key);

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget> {
  final STTService _sttService = STTService();
  final TTSService _ttsService = TTSService();
  late TextEditingController _textController;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _statusMessage = "";

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _initializeSpeech();
  }

  Future<void> _initializeSpeech() async {
    bool available = await _sttService.initialize();
    if (!available) {
      setState(() {
        _statusMessage = "Speech-to-text not available";
      });
    }
  }

  void _toggleListening() async {
    if (!_isListening) {
      setState(() {
        _isListening = true;
        _statusMessage = "Listening...";
      });
      widget.onListeningStart?.call();

      await _sttService.startListening(
        onResult: (result) {
          setState(() {
            _textController.text = result;
          });
        },
      );
    } else {
      await _sttService.stopListening();
      setState(() {
        _isListening = false;
        _statusMessage = "Stopped listening";
      });
      widget.onListeningStop?.call();
    }
  }

  void _speakText() async {
    if (_textController.text.isNotEmpty) {
      setState(() {
        _isSpeaking = true;
        _statusMessage = "Speaking...";
      });
      await _ttsService.speak(_textController.text);
      setState(() {
        _isSpeaking = false;
        _statusMessage = "Done speaking";
      });
    }
  }

  void _submitText() {
    if (_textController.text.isNotEmpty) {
      widget.onTextReceived(_textController.text);
      _textController.clear();
      setState(() {
        _statusMessage = "";
      });
    }
  }

  void _clearText() {
    _textController.clear();
    setState(() {
      _statusMessage = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: _isListening ? Colors.red : Colors.grey.shade300,
              width: _isListening ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: _isListening ? Colors.red.shade50 : Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ),
                  // Microphone button
                  IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: _isListening ? Colors.red : Colors.grey,
                      size: 28,
                    ),
                    onPressed: _toggleListening,
                    tooltip: _isListening ? "Stop listening" : "Start listening",
                  ),
                  // Speaker button
                  IconButton(
                    icon: Icon(
                      _isSpeaking ? Icons.volume_up : Icons.volume_up_outlined,
                      color: _isSpeaking ? Colors.blue : Colors.grey,
                      size: 24,
                    ),
                    onPressed: _speakText,
                    tooltip: "Speak text",
                  ),
                  // Clear button
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.orange, size: 24),
                    onPressed: _textController.text.isEmpty ? null : _clearText,
                    tooltip: "Clear text",
                  ),
                  // Send button
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.green, size: 24),
                    onPressed:
                        _textController.text.isEmpty ? null : _submitText,
                    tooltip: "Submit",
                  ),
                ],
              ),
              // Status message
              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 12,
                      color: _isListening ? Colors.red : Colors.blue,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _sttService.stopListening();
    _ttsService.stop();
    super.dispose();
  }
}
