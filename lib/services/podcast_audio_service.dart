import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/podcast_model.dart';
import 'audio_service.dart';

class PodcastAudioService extends ChangeNotifier {
  static final PodcastAudioService _instance = PodcastAudioService._internal();

  factory PodcastAudioService() => _instance;

  PodcastAudioService._internal() {
    _init();
  }

  bool isPlaying = false;
  PodcastModel? currentPodcast;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool _isActive = false; // Track if this service is active (screen is visible)

  void _init() {
    final radioService = AudioService();
    
    radioService.audioPlayer.playerStateStream.listen((playerState) {
      isPlaying = playerState.playing;
      notifyListeners();
    });

    radioService.audioPlayer.durationStream.listen((newDuration) {
      if (newDuration != null) {
        duration = newDuration;
        notifyListeners();
      }
    });

    radioService.audioPlayer.positionStream.listen((newPosition) {
      position = newPosition;
      notifyListeners();
    });
  }
  
  // Set active state when screen is visible/invisible
  set isActive(bool value) {
    _isActive = value;
    if (!_isActive && isPlaying) {
      // Stop playback when screen becomes inactive
      final radioService = AudioService();
      radioService.audioPlayer.pause();
      isPlaying = false;
      notifyListeners();
    }
  }
  
  bool get isActive => _isActive;

  Future<void> loadPodcast(PodcastModel podcast) async {
    if (podcast.audioUrl == null || podcast.audioUrl!.isEmpty) {
      return;
    }

    currentPodcast = podcast;

    try {
      // Use the shared AudioService to play podcasts
      final radioService = AudioService();
      await radioService.setUrl(
        podcast.audioUrl!,
        title: podcast.title,
        thumbnailUrl: podcast.thumbnailUrl,
      );
      // Update our state to match AudioService
      isPlaying = radioService.isPlaying;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading podcast audio: $e');
    }
  }

  void togglePlay() async {
    final radioService = AudioService();
    
    // Toggle play/pause using the shared AudioService
    radioService.togglePlay();
    
    // Update our state to match AudioService
    isPlaying = radioService.isPlaying;
    notifyListeners();
  }

  void seek(Duration position) {
    final radioService = AudioService();
    radioService.audioPlayer.seek(position);
  }

  @override
  void dispose() {
    // We don't need to dispose anything since we're using the shared AudioService
    super.dispose();
  }
}