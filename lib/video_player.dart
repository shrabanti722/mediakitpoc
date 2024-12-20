import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.
import 'package:media_kit_video/media_kit_video.dart'; // Provides [VideoController] & [Video] etc.
import 'package:flutter_hooks/flutter_hooks.dart';

class MyScreenState extends HookConsumerWidget {
  const MyScreenState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late final Player player;
    late final VideoController controller;
    final audioTracks = useRef<List<AudioTrack>>([]);

    useEffect(() {
      player = Player();
      controller = VideoController(player);
      player.open(
        Media(
            'https://cdn02.vdocipher.com/custom-samples/multi-lang-audio-sample/master.m3u8'),
      );

      player.stream.tracks.listen((event) async {
        debugPrint('selected Language === ${event.audio}');

        final List<AudioTrack> audioswithLanguage = event.audio.where((audio) {
          return audio.language != null && audio.language!.isNotEmpty;
        }).toList();
        audioTracks.value = audioswithLanguage;
        debugPrint(
            'Audio Tracks: ${event.audio.map((e) => e.language).toList()}');
      });
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player with Language Control'),
      ),
      body: Column(
        children: [
          Center(
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                child: MaterialVideoControlsTheme(
                  normal: MaterialVideoControlsThemeData(
                    buttonBarButtonSize: 24.0,
                    buttonBarButtonColor: Colors.white,
                    topButtonBar: [
                      const Spacer(),
                      MaterialDesktopCustomButton(
                        onPressed: () {
                          debugPrint('Custom "Settings" button pressed.');
                        },
                        icon: const Icon(Icons.settings),
                      ),
                      MaterialDesktopCustomButton(
                        onPressed: () {
                          _showAudioLanguageDialog(
                              context, player, audioTracks.value);
                        },
                        icon: const Icon(Icons.language),
                      ),
                    ],
                  ),
                  fullscreen: const MaterialVideoControlsThemeData(
                    displaySeekBar: false,
                    automaticallyImplySkipNextButton: false,
                    automaticallyImplySkipPreviousButton: false,
                  ),
                  child: Scaffold(
                    body: Video(
                      controller: controller,
                      controls: MaterialVideoControls,
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }

  void _showAudioLanguageDialog(
      BuildContext context, Player player, List<AudioTrack> audioTracks) {
    if (audioTracks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No audio tracks available.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Audio Language'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: audioTracks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(audioTracks[index].language ?? 'null'),
                  onTap: () async {
                    // List<AudioTrack> audios = player.state.tracks.audio;

                    await player.setAudioTrack(audioTracks[index]);
                    // await player.setAudioTrack(audios[index]);

                    AudioTrack audio = player.state.track.audio;

                    debugPrint(
                        'audio now == ${audioTracks[index].language} ${audio.language}');

                    // List<AudioDevice> devices = player.state.audioDevices;

                    // await player.setAudioDevice(devices[0]);

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Audio changed to ${audioTracks[index].language?.toUpperCase()}'),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
