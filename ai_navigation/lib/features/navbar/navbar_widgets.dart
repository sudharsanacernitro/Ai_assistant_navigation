import 'package:flutter/material.dart';
import 'dart:developer' as devtools;
import 'dart:io';

import './navbar_service.dart';
import './model.dart';

class BottomNavigationBarExample extends StatefulWidget {
  final String ip, lang;
  const BottomNavigationBarExample({Key? key, required this.ip, required this.lang}) : super(key: key);

  @override
  State<BottomNavigationBarExample> createState() =>
      _BottomNavigationBarExampleState();
}

class _BottomNavigationBarExampleState extends State<BottomNavigationBarExample> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;
 
 final VoiceTypingService _voiceTyping = VoiceTypingService(); //voice detection
  final QueryService Queryservice=QueryService(); //to send the queries to the backend
  final TextToSpeechService Tts=TextToSpeechService();
   final TextEditingController _textController = TextEditingController();

 String? _selectedLanguage;

  @override
    void initState() {
      super.initState();
      _voiceTyping.initSpeech().then((_) {
        setState(() {});
      });
      _widgetOptions = <Widget>[
        HomePage(ip: widget.ip),
        ProfilePage(ip: widget.ip),
        SettingsPage(ip: widget.ip),
        CameraPage(ip: widget.ip, lang: widget.lang),
      ];
      _selectedLanguage = widget.lang.isNotEmpty ? widget.lang : 'en-US'; // Fallback
    }



  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onFloatingIconPressed() {
    // Action for the floating icon
   
  }

 void _toggleListening() async {
  try {
    if (_voiceTyping.isListening) {
      // Stop listening
      await _voiceTyping.stopListening();
      print('Stopped Listening');
      if (_voiceTyping.voiceMessage != null) {
        await change_page();
      }
    } else {
      // Start listening
      await _voiceTyping.startListening(
        onResult: (recognizedWords) {
          setState(() {
            _textController.text = recognizedWords;
          });
        },
        localeId: _selectedLanguage!,
      );
      print('Started Listening');
    }
  } catch (e) {
    print('Error toggling listening: $e');
  }

  // Ensure the UI is updated
  setState(() {});
}

Future<void> change_page() async {
  Query? query_model=  await Queryservice.store(
          query: _voiceTyping.voiceMessage!,
          language: _selectedLanguage!,
        );

  dynamic data=query_model!.toJson();

  int index=0;
  switch(data['response'])
{
  case 'HomePage':
      index=0;
      break;
  case 'ProfilePage':
      index=1;
      break;
  case 'SettingsPage':
      index=2;
      break;
  case 'CameraPage':
      index=3;
      break;
}
  Tts.speak('Moving to '+data['response']);
  setState(() {
    _selectedIndex=index;
  });
        
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iris - NextGen',style: TextStyle(color: Colors.white),),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        leadingWidth: 8,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // IndexedStack to manage page navigation
          IndexedStack(
            index: _selectedIndex,
            children: _widgetOptions,
          ),

          // Floating Icon
            Positioned(
              bottom: 50,
              right: 20,
              child: FloatingActionButton(
                onPressed: _voiceTyping.isSpeechEnabled
                    ? () {
                        _toggleListening();
                      }
                    : null,
                backgroundColor: _voiceTyping.isListening ? Colors.red : Colors.green,
                child: Icon(
                  _voiceTyping.isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.black,
                ),
              ),
            ),

        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Subtle, soft shadow
                    blurRadius: 10, // Soft edges
                    offset: const Offset(0, 4), // Slightly raised shadow
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05), // Extra subtle layer for depth
                    blurRadius: 20,
                    offset: const Offset(0, 8), // Slightly deeper shadow for a layered effect
                  ),
                ],
              ),
              child: Center(
                child: 
                (_textController.text.isNotEmpty)?
                Text(
                  'Voice : ${_textController.text}',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ):Text(
                  "Voice Data",
                  style: TextStyle(color: Colors.white,fontSize: 17),
                ),

              ),
            ),

      ),
    );
  }
}

// Dummy screens for navigation
class HomePage extends StatelessWidget {
  final String ip;
  const HomePage({Key? key, required this.ip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(margin: EdgeInsets.all(20),  child: Image.asset('assets/home.jpg')));
  }
}

class CameraPage extends StatelessWidget {
  final String ip, lang;
  const CameraPage({Key? key, required this.ip, required this.lang}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(margin: EdgeInsets.all(20),  child: Image.asset('assets/camera.jpg')));
  }
}

class ProfilePage extends StatelessWidget {
  final String ip;
  const ProfilePage({Key? key, required this.ip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(margin: EdgeInsets.all(20),child:Image.asset('assets/profile.jpg')));
  }
}

class SettingsPage extends StatelessWidget {
  final String ip;
  const SettingsPage({Key? key, required this.ip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Container(margin: EdgeInsets.all(20),child: Image.asset('assets/settings.jpg')));
  }
}
