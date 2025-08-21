import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
 import '../constants/app_constants.dart';
import 'podcast_audio_service.dart';

class GlobalAudioService {
  static final AudioPlayer player = AudioPlayer();
}

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();

  factory AudioService() => _instance;

  AudioService._internal() {
    _init();
  }

  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String currentStreamUrl = '';

  void _init() {
    audioPlayer.playerStateStream.listen((playerState) {
      isPlaying = playerState.playing;
      notifyListeners();
    });
  }

  Future<void> setUrl(String url, {String title = "Live Radio", String? thumbnailUrl}) async {
    if (url.isEmpty) return;

    if (currentStreamUrl != url) {
      currentStreamUrl = url;

      // Always attach MediaItem tag
      await audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: url,
            album: "Radio Mann",
            title: title,
            artUri: Uri.parse(
              thumbnailUrl ?? AppConstants.demoNotifcationAudioImageURL,
            ),
          ),
        ),
      );
    }
  }

  void togglePlay() async {
    if (isPlaying) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play();
    }
    notifyListeners();
  }

  // @override
  // void dispose() {
  //   audioPlayer.dispose();
  //   super.dispose();
  // }
}
