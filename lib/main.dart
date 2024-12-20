import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:mediakitpoc/audio_player.dart';
import 'package:mediakitpoc/audio_player_service.dart';
import 'package:mediakitpoc/video_player.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  // Start the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Player Demo',
      home: AudioPlayerScreen(),
    );
  }
}

class AudioPlayerScreen extends StatefulWidget {
  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            // title: const Text('Player'),
            ),
        body: MyScreenState());
  }
}
