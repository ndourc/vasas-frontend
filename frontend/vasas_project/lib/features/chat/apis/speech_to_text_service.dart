import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<bool> initialize() async {
    return await _speech.initialize();
  }

  Future<String?> listen() async {
    if (!_speech.isAvailable) {
      return null;
    }

    String recognizedText = '';
    await _speech.listen(onResult: (result) {
      if (result.finalResult) {
        recognizedText = result.recognizedWords;
        _speech.stop();
      }
    });

    // Wait for the speech recognition to complete
    await Future.delayed(Duration(seconds: 5));
    return recognizedText.isNotEmpty ? recognizedText : null;
  }

  void stop() {
    _speech.stop();
  }
}
