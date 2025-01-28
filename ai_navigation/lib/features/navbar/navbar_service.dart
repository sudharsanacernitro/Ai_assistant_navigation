// Listening service
import 'package:speech_to_text/speech_to_text.dart';

//speech service
import 'package:flutter_tts/flutter_tts.dart';

//DB service
import 'navbar_repo.dart';
import 'model.dart';

class VoiceTypingService {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;

  bool get isSpeechEnabled => _speechEnabled;
  bool get isListening => _isListening;

  String? voiceMessage;

 Future<void> initSpeech() async {
  try {
    _speechEnabled = await _speechToText.initialize(
      onError: (val) => print("Error: $val"),
      onStatus: (val) => print("Status: $val"),
    );
    if (!_speechEnabled) {
      print('Speech not enabled');
    }
  } catch (e) {
    print('Error initializing speech: $e');
  }
}


  Future<void> startListening({
    required Function(String recognizedWords) onResult,
    required String localeId,
  }) async {
    if (_speechEnabled) {
      _isListening = true;
      await _speechToText.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
          voiceMessage = result.recognizedWords;
        },
        localeId: localeId,
      );
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      _isListening = false;
    }
  }
}


class TextToSpeechService  {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> speak(String text) async {
    
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

}


class QueryService {
  final QueryRepository _repository = QueryRepository();

  Future<Query?> store({required String query, required String language}) async {
    if (query.isEmpty || language.isEmpty) {
      throw Exception("Query and language can't be empty");
    }

    final user = await _repository.store(query: query, language: language);

    if (user.response != null && user.language != null) {
      return user;
    } else {
      print("Invalid response or language in the repository result.");
      return null; // Return null if validation fails
    }
  }
}
