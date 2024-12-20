import 'dart:async';
import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';

// import 'package:just_audio/just_audio.dart';

import 'package:rxdart/rxdart.dart';

enum ProcessingState {
  idle,
  buffering,
  ready,
  completed,
}

// class AudioPlayerService with Initializer {
//   static final AudioPlayerService _instance = AudioPlayerService._();
//   static AudioPlayerService get instance => _instance;
//   AudioPlayerService._() {
//     waitForInitialization();
//   }

//   AppAudioHandler? _audioHandler;
//   AppAudioHandler get audioHandler => _audioHandler!;

//   @override
//   void dispose() {
//     _audioHandler?.dispose();
//   }

//   @override
//   Future runInitialization_() async {
//     _audioHandler = await AudioService.init<AppAudioHandler>(
//       builder: () => AppAudioHandler(),
//       config: const AudioServiceConfig(
//         //TODO : give a better name
//         androidNotificationChannelId: 'Miracle Notifications',
//         //TODO : give a better name
//         androidNotificationChannelName: 'Miracle Notifications',
//         androidShowNotificationBadge: false,
//       ),
//     );
//     AudioService.asyncError.listen((error) {
//       debugPrint('Audio Service Error : $error');
//     });
//   }
// }

class AppAudioHandler extends BaseAudioHandler with SeekHandler {
  final Player _player = Player();
  // late final controller = VideoController(_player);
  bool _isExternalControlsEnabled = true;
  late final AudioSession _audioSession;
  final List<StreamSubscription> _subscriptions = [];

  final Duration _currentPosition = Duration.zero;
  final Duration _bufferedPosition = Duration.zero;

  bool _isBuffering = false;
  bool _isCompleted = false;
  bool _isPlaying = false;
  Duration _currentDuration = Duration.zero;
  ProcessingState _processingState = ProcessingState.idle;

  void _subscribeToStreams() {
    _subscriptions.addAll([
      _player.stream.buffering.listen((buffering) {
        _isBuffering = buffering;
        _updatePlaybackState();
      }),
      _player.stream.completed.listen((completed) {
        _isCompleted = completed;
        _updatePlaybackState();
      }),
      _player.stream.playing.listen((playing) {
        _isPlaying = playing;
        _updatePlaybackState();
      }),
    ]);
  }

  AudioProcessingState _deriveProcessingState() {
    if (_isBuffering) {
      return AudioProcessingState.buffering;
    } else if (_isCompleted) {
      return AudioProcessingState.completed;
    } else if (_isPlaying) {
      return AudioProcessingState.ready;
    } else if (_currentPosition == Duration.zero) {
      return AudioProcessingState.idle;
    } else {
      return AudioProcessingState.loading;
    }
  }

  void _updatePlaybackState() {
    _broadcastPlaybackEvent(_isPlaying);
  }

  AppAudioHandler() {
    init();
  }

  set setExternalControlsEnabled(bool enabled) {
    _isExternalControlsEnabled = enabled;
  }

  void dispose() {
    for (var element in _subscriptions) {
      element.cancel();
    }
  }

  Future<void> init() async {
    _audioSession = await AudioSession.instance;
    await _audioSession.configure(const AudioSessionConfiguration.music());
    debugPrint('Setting up Audio Session streams');
    // Listen to the playing state stream
    _player.stream.playing.listen((isPlaying) {
      _isPlaying = isPlaying;
    });

    // Listen to the duration stream
    _player.stream.duration.listen((duration) {
      if (duration != null) {
        _currentDuration = duration;
      }
    });

    // Simulate processing states (idle, buffering, etc.)
    _player.stream.completed.listen((isCompleted) {
      _processingState =
          isCompleted ? ProcessingState.completed : ProcessingState.ready;
    });

    _player.stream.buffering.listen((isBuffering) {
      if (isBuffering) {
        _processingState = ProcessingState.buffering;
      } else if (_isPlaying) {
        _processingState = ProcessingState.ready;
      }
    });
    _subscribeToStreams();
  }

  Stream<AudioInterruptionEvent> get audioInterruptionStream =>
      _audioSession.interruptionEventStream;

  void _broadcastPlaybackEvent(bool isPlaying) {
    debugPrint('New Audio Player isPlaying: $isPlaying');
    playbackState.add(playbackState.value.copyWith(
      // Which buttons should appear in the notification now
      controls: _isExternalControlsEnabled
          ? [
              // MediaControl.skipToPrevious,
              if (isPlaying) MediaControl.pause else MediaControl.play,
              MediaControl.stop,
              // MediaControl.skipToNext,
            ]
          : [],
      // Which other actions should be enabled in the notification
      systemActions: _isExternalControlsEnabled
          ? const {
              MediaAction.play,
              MediaAction.pause,
              MediaAction.stop,
            }
          : {},
      // Which controls to show in Android's compact view.
      androidCompactActionIndices:
          _isExternalControlsEnabled ? const [0, 1, 3] : [],
      processingState: _deriveProcessingState(),
      playing: isPlaying,
      updatePosition: _currentPosition,
      bufferedPosition: _bufferedPosition,
      // repeatMode: _player.loopMode == LoopMode.one
      //     ? AudioServiceRepeatMode.one
      //     : _player.loopMode == LoopMode.all
      //         ? AudioServiceRepeatMode.all
      //         : AudioServiceRepeatMode.none,
      // speed: _player.speed,
      queueIndex: 0,
    ));
  }

  /// NOTE : The [Future] returned by this method completes when the playback completes
  /// or is paused or stopped. If the player is already playing, this method
  /// completes immediately.
  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await seek(Duration.zero);
    await _player.stop();
    await _audioSession.setActive(false);

    /// This is needed to be called at the last which will update
    /// [playbackState] by setting the processing state to
    /// [AudioProcessingState.idle] which disables the system notification.
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  /// @param [seconds] accepts positive or negative values
  Future<void> seekBy(int seconds) async {
    final currentPosition = await _player.stream.position.first;
    final newPosition = currentPosition.inSeconds + seconds;
    final duration = (await _player.stream.duration.first).inSeconds;
    if (duration == null) {
      debugPrint('seekBy($seconds) : Failed. Duration is null');
      return;
    }
    return seek(
      Duration(
        seconds: min(max(newPosition, 0), duration),
      ),
    );
  }

  // @override
  // Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) {
  //   switch (repeatMode) {
  //     case AudioServiceRepeatMode.none:
  //       return _player.setLoopMode(LoopMode.off);
  //     case AudioServiceRepeatMode.one:
  //       return _player.setLoopMode(LoopMode.one);
  //     case AudioServiceRepeatMode.all:
  //       return _player.setLoopMode(LoopMode.all);
  //     case AudioServiceRepeatMode.group:
  //       return _player.setLoopMode(LoopMode.all);
  //   }
  // }

  Future<void> setVolume(double volume) => _player.setVolume(volume);

  Stream<Duration> get positionStream => _player.stream.position;
  Stream<bool> get playingStream => _player.stream.playing;

  Future<Duration?> setAudioSource(
      {required String url, String? title, bool playOnLoad = true}) async {
    final audioSessionActivated = await _audioSession.setActive(true);
    if (!audioSessionActivated) {
      debugPrint('Audio Session was not activated!');
    }
    // final duration = await _player.setAudioSource(
    //   url.contains('.m3u8')
    //       ? HlsAudioSource(Uri.parse(url))
    //       : ProgressiveAudioSource(Uri.parse(url)),
    // );
    await _player.open(Media(
        'https://user-images.githubusercontent.com/28951144/229373695-22f88f13-d18f-4288-9bf1-c3e078d83722.mp4'));
    // await _player.open(Media(Uri.parse(url).toString()));
    mediaItem.add(MediaItem(id: url, title: title ?? ''));
    final durationCompleter = Completer<Duration?>();
    final subscription = _player.stream.duration.listen((duration) {
      if (duration != null && !durationCompleter.isCompleted) {
        durationCompleter.complete(duration);
      }
    });
    if (playOnLoad) {
      unawaited(play());
    }

    try {
      final duration = await durationCompleter.future
          .timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint('Timeout waiting for duration.');
        return null;
      });

      return duration;
    } finally {
      // Ensure the subscription is canceled to avoid memory leaks.
      await subscription.cancel();
    }
  }

  bool get isPaused => !_isPlaying && _processingState == ProcessingState.ready;

  bool get isPlaying => _isPlaying;

  bool get isLoading => _processingState == ProcessingState.buffering;

  bool get isAudioCompleted => _processingState == ProcessingState.completed;

  Duration get currentAudioDuration => _currentDuration;

  Future<void> togglePausePlay({bool ignoreIfLoading = true}) async {
    if (isLoading && ignoreIfLoading) {
      return;
    }
    if (isPlaying) {
      await pause();
    } else {
      unawaited(play());
    }
  }
}
