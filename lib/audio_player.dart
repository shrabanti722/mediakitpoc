// // Make sure to add following packages to pubspec.yaml:
// // * media_kit
// // * media_kit_video
// // * media_kit_libs_video
// import 'package:flutter/material.dart';

// import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.
// import 'package:media_kit_libs_audio/media_kit_libs_audio.dart';
// // import 'package:media_kit_video/media_kit_video.dart'; // Provides [VideoController] & [Video] etc.

// class AudioScreen extends StatefulWidget {
//   const AudioScreen({super.key});
//   @override
//   State<AudioScreen> createState() => AudioScreenState();
// }

// class AudioScreenState extends State<AudioScreen> {
//   // Create a [Player] to control playback.
//   late final Player player;
//   // late final VideoController controller;
//   List<VideoTrack> videoTracks = [];
//   List<AudioTrack> audioTracks = [];
//   List<SubtitleTrack> subtitleTracks = [];

//   int selectedAudioTrackIndex = 0;

//   List<AudioDevice> audioDevices = [];

//   @override
//   void initState() {
//     super.initState();
//     player = Player();
//     // controller = VideoController(player);
//     // Play a [Media] or [Playlist].
//     player.open(
//       Media(
//           'https://d1v1gqjht5uu1.cloudfront.net/h6/i0Czoxxkj2tjX/14ab75e1/stream.m3u8'),
//     );

//     // Listen to the available tracks
//     player.stream.tracks.listen((event) {
//       setState(() {
//         videoTracks = event.video;
//         audioTracks = event.audio;
//         subtitleTracks = event.subtitle;
//       });
//       debugPrint('Video Tracks: ${videoTracks.map((e) => e.id).toList()}');
//       debugPrint('Audio Tracks: ${audioTracks.map((e) => e.id).toList()}');
//       debugPrint(
//           'Subtitle Tracks: ${subtitleTracks.map((e) => e.id).toList()}');

//       // player.setAudioTrack(audioTracks[3]);
//       debugPrint('Audio Track 2 Selected: ${audioTracks[2].language}');
//     });

//     player.stream.audioDevices.listen((devices) {
//       setState(() {
//         audioDevices = devices;
//       });

//       debugPrint('devices === $devices');

//       // Print audio devices to the console
//       for (var device in devices) {
//         debugPrint('Audio Device: ${device.name}, ID: ${device.description}');
//       }
//     });
//   }

//   @override
//   void dispose() {
//     player.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//         child: Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Play button
//         ElevatedButton(
//           onPressed: () async {
//             await player.play();
//           },
//           child: const Text('Play'),
//         ),
//         const SizedBox(height: 10),
//         // Pause button
//         ElevatedButton(
//           onPressed: () async {
//             await player.pause();
//           },
//           child: const Text('Pause'),
//         ),
//         const SizedBox(height: 10),
//         // if (audioTracks.isNotEmpty)
//         //   DropdownButton<int>(
//         //     value: selectedAudioTrackIndex,
//         //     items: audioTracks.asMap().entries.map((entry) {
//         //       final index = entry.key;
//         //       final track = entry.value;
//         //       return DropdownMenuItem<int>(
//         //         value: index,
//         //         child: Text(track.language ?? 'Unknown Language'),
//         //       );
//         //     }).toList(),
//         //     onChanged: (value) async {
//         //       if (value != null) {
//         //         setState(() {
//         //           selectedAudioTrackIndex = value;
//         //         });
//         //         await player.setAudioTrack(audioTracks[value]);
//         //         debugPrint(
//         //             'Selected Audio Track: ${audioTracks[value].language}');
//         //       }
//         //     },
//         //   )
//         // else
//         //   const Text('No audio tracks available'),
//         // Stop button
//         ElevatedButton(
//           onPressed: () async {
//             await player.stop();
//           },
//           child: const Text('Stop'),
//         ),
//       ],
//     ));

//     // Center(
//     //   child: SizedBox(
//     //     width: MediaQuery.of(context).size.width,
//     //     height: MediaQuery.of(context).size.width * 9.0 / 16.0,
//     //     // Use [Video] widget to display video output.
//     //     child: Video(controller: controller),
//     //   ),
//     // );
//   }
// }
