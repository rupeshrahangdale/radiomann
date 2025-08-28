import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../constants/app_constants.dart';
import 'ad_sample_service.dart';

// Global shared audio player instance to be used across the app
class GlobalAudioService {
  // Single shared instance of AudioPlayer to be used by all audio services
  static final AudioPlayer player = AudioPlayer();
}

class AudioService extends ChangeNotifier {
  static final AudioService _instance = AudioService._internal();

  factory AudioService() => _instance;

  AudioService._internal() {
    _init();
  }

  // Use the shared player instance instead of creating a new one
  final AudioPlayer audioPlayer = GlobalAudioService.player;
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
              AppConstants.demoNotifcationAudioImageURL,
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
      // Stop any other audio that might be playing
      await audioPlayer.stop();
      
      // Reset any ad sample audio that might be playing
      final adSampleServices = AdSampleAudioService();
      if (adSampleServices.isPlaying) {
        adSampleServices.stop();
      }
      
      // If we have a URL set, make sure it's loaded
      if (currentStreamUrl.isNotEmpty) {
        await setUrl(currentStreamUrl);
      }
      
      await audioPlayer.play();
    }
    notifyListeners();
  }

  // Don't dispose the shared player
  // @override
  // void dispose() {
  //   audioPlayer.dispose();
  //   super.dispose();
  // }
}
