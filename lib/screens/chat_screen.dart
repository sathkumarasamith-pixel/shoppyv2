import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../config.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  bool _loading = false;
  late GenerativeModel _model;

  @override
  void initState() {
    super.initState();

    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: Config.geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
      ),
    );
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty || _loading) return;

    setState(() {
      _messages.add({
        'text': text,
        'sender': 'user',
      });

      _controller.clear();
      _loading = true;
    });

    try {
      final prompt =
          '''
You are Shoppy AI, a smart shopping assistant.

Help users with:
- Product recommendations
- Price comparisons
- Shopping advice
- Product features
- Buying decisions

User question:
$text
''';

      final response = await _model.generateContent(
        [
          Content.text(prompt),
        ],
      );

      setState(() {
        _messages.add({
          'text': response.text ?? 'No response received.',
          'sender': 'ai',
        });
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'text': 'Error: $e',
          'sender': 'ai',
        });
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 28,
            ),
            const SizedBox(width: 8),
            const Text('Shoppy AI'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['sender'] == 'user';

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(14),
                          constraints: const BoxConstraints(
                            maxWidth: 320,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            message['text'] ?? '',
                            style: TextStyle(
                              color: isUser
                                  ? Colors.white
                                  : Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          if (_loading)
            const LinearProgressIndicator(),

          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Ask Shoppy...',
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primary,
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo.png',
            height: 60,
          ),
          const SizedBox(height: 16),
          Text(
            'Ask Shoppy Anything!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get shopping advice, recommendations, and more',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}