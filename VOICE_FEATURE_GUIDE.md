# Voice Features Implementation Guide

## Overview
This document describes the newly implemented speech-to-text and text-to-speech features for the Shoppy app.

## Features Added

### 1. **Text-to-Speech (TTS)**
- Convert product descriptions, prices, and other information to speech
- Adjustable pitch, speech rate, and volume
- Support for multiple languages
- Service: `lib/services/tts_service.dart`

### 2. **Speech-to-Text (STT)**
- Voice input for product searches
- Real-time transcription feedback
- Support for multiple languages
- Service: `lib/services/stt_service.dart`

### 3. **Voice Input Widget**
- Complete UI component for voice interaction
- Manual text input fallback
- Status indicators for listening/speaking
- Widget: `lib/widgets/voice_input_widget.dart`

## Files Created/Modified

### New Files:
```
lib/
├── services/
│   ├── tts_service.dart          # Text-to-Speech service
│   └── stt_service.dart          # Speech-to-Text service
├── widgets/
│   └── voice_input_widget.dart   # Voice input UI component
└── screens/
    └── voice_assistant_screen.dart # Example implementation screen

android/
└── app/src/main/
    └── AndroidManifest.xml        # Updated with audio permissions
```

### Modified Files:
```
pubspec.yaml                       # Updated dependencies
.github/workflows/build.yml        # Enhanced build workflow
```

## Dependencies Added

```yaml
flutter_tts: ^0.14.0              # Text-to-Speech
speech_to_text: ^6.6.0            # Speech-to-Text (upgraded)
```

## Setup Instructions

### 1. Update Dependencies
```bash
flutter pub get
```

### 2. Android Setup
The `AndroidManifest.xml` has been updated with required permissions:
- `android.permission.RECORD_AUDIO` - For speech input
- `android.permission.INTERNET` - For TTS engine data
- `android.permission.ACCESS_NETWORK_STATE` - For network access

### 3. iOS Setup (if applicable)
Add to `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to listen to your voice</string>
```

## Usage Examples

### Using Voice Input Widget
```dart
import 'package:shoppy/widgets/voice_input_widget.dart';

VoiceInputWidget(
  onTextReceived: (text) {
    print("User input: $text");
    // Process the voice input
  },
  hintText: "Search products by voice",
  onListeningStart: () {
    print("User started speaking");
  },
  onListeningStop: () {
    print("User stopped speaking");
  },
)
```

### Using TTS Service Directly
```dart
import 'package:shoppy/services/tts_service.dart';

final ttsService = TTSService();

// Speak text
await ttsService.speak("Welcome to Shoppy");

// Adjust settings
ttsService.setPitch(1.2);
ttsService.setSpeechRate(0.8);
ttsService.setLanguage("en-US");

// Stop speaking
await ttsService.stop();
```

### Using STT Service Directly
```dart
import 'package:shoppy/services/stt_service.dart';

final sttService = STTService();

// Initialize
bool available = await sttService.initialize();

// Start listening
await sttService.startListening(
  onResult: (result) {
    print("Recognized: $result");
  },
  languageCode: 'en_US',
);

// Stop listening
await sttService.stopListening();
```

### Integration with Search Screen
```dart
import 'package:shoppy/widgets/voice_input_widget.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  void _searchProducts(String query) {
    // Perform product search with voice input
    print("Searching for: $query");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        VoiceInputWidget(
          onTextReceived: _searchProducts,
          hintText: "Search products by voice or type",
        ),
        // Search results UI
      ],
    );
  }
}
```

## Permissions

### Android
Permissions are already added to `AndroidManifest.xml`. Runtime permissions should be requested in your app:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestAudioPermission() async {
  final status = await Permission.microphone.request();
  return status.isGranted;
}
```

### iOS
Update `ios/Runner/Info.plist` with microphone usage description.

## Troubleshooting

### Issue: "Speech-to-text not available"
- **Solution**: Check if microphone permissions are granted
- Ensure the device has audio capabilities
- Test on a real device (emulator might not support STT)

### Issue: TTS not working
- **Solution**: Check internet connection (needed for TTS engine data)
- Verify audio volume is not muted
- Test on a real device

### Issue: Build fails with speech_to_text
- **Solution**: Run `flutter clean` and `flutter pub get`
- Update to speech_to_text version 6.6.0+
- Check Android SDK version (min 21)

## Configuration Options

### TTS Settings
```dart
ttsService.setPitch(0.5);           // Range: 0.5 to 2.0
ttsService.setSpeechRate(0.5);      // Range: 0.1 to 2.0
ttsService.setVolume(0.5);          // Range: 0.0 to 1.0
ttsService.setLanguage("en-US");    // Language code
```

### STT Settings
```dart
sttService.startListening(
  onResult: (result) {},
  languageCode: 'en_US',  // Language code
);
```

## Performance Considerations

1. **Memory**: Services use singleton pattern to minimize memory usage
2. **Battery**: Listening sessions timeout after 30 seconds by default
3. **Network**: TTS requires internet for engine data
4. **Permissions**: Always request permissions before first use

## Future Enhancements

- [ ] Support for multiple languages
- [ ] Voice commands for common actions
- [ ] Offline TTS support
- [ ] Custom voice profiles
- [ ] Voice history/favorites
- [ ] Accessibility improvements

## Support

For issues or feature requests related to voice features, please refer to:
- Flutter TTS: https://pub.dev/packages/flutter_tts
- Speech-to-Text: https://pub.dev/packages/speech_to_text

