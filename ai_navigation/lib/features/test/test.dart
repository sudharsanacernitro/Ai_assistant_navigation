import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:dio/dio.dart';

class ChatPage extends StatefulWidget {
  
  String ip;
   ChatPage({
    Key? key,
    required this.ip
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _selectedLanguage = 'en_US';
  final TextEditingController _textController = TextEditingController();
  String? voice_msg;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onError: (val) => print("Error: $val"),
      onStatus: (val) => print("Status: $val"),
    );
    setState(() {});
  }

  void _toggleListening() async {
    if (_isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    await _speechToText.listen(
      onResult: (result) {
        setState(() {
          _textController.text = result.recognizedWords;
        });
        voice_msg=(result.recognizedWords); // Send message immediately after listening
      },
      localeId: _selectedLanguage,
    );
    setState(() {
      _isListening = true;
    });
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });

    _sendMessage(voice_msg!);
  }

  void _sendMessage(String userMessage) async {
    try {
      print(0);
      Response response = await Dio().post(
        'http://${widget.ip}:5000/api/change_page',
        data: {
          'query': userMessage,
          'language': _selectedLanguage,
        },
      );

      if (response.statusCode == 200) {
        print('Response: ${response.data["message"]}');
      } else {
        print("Error: Failed to get a response.");
      }
    } catch (e) {
      print("Error: Could not send message.");
    }

    print(userMessage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech to Text', style: TextStyle(fontFamily: 'crisp', color: Color.fromARGB(255, 119, 206, 121))),
        backgroundColor: Color.fromARGB(255, 26, 27, 26),
        toolbarHeight: 30,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DropdownButton<String>(
                value: _selectedLanguage,
                items: const [
                  DropdownMenuItem(value: 'en_US', child: Text('English')),
                  DropdownMenuItem(value: 'hi_IN', child: Text('Hindi')),
                  DropdownMenuItem(value: 'ta_IN', child: Text('Tamil')),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLanguage = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              IconButton(
                icon: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.red : Colors.blue,
                ),
                iconSize: 80,
                onPressed: _speechEnabled ? _toggleListening : null,
              ),
              const SizedBox(height: 20),
              if (_textController.text.isNotEmpty)
                Text(
                  'Recognized Text: ${_textController.text}',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
