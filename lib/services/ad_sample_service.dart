import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import '../services/audio_service.dart';

class AdSampleAudioService extends ChangeNotifier {
  static final AdSampleAudioService _instance = AdSampleAudioService._internal();

  factory AdSampleAudioService() => _instance;

  late final AudioPlayer _player;
  int? _currentAdId;
  bool _isPlaying = false;
  bool _isActive = false; // Track if this service is active (screen is visible)

  AdSampleAudioService._internal() {
    _player = AudioPlayer();

    // Listen to player state changes
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _currentAdId = null;
        _isPlaying = false;
        notifyListeners();
      }
    });

    // Listen to playing state changes
    _player.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });
  }

  AudioPlayer get player => _player;
  int? get currentAdId => _currentAdId;
  bool get isPlaying => _isPlaying;
  
  // Set active state when screen is visible/invisible
  set isActive(bool value) {
    _isActive = value;
    if (!_isActive && _isPlaying) {
      stop(); // Stop playback when screen becomes inactive
    }
  }
  
  bool get isActive => _isActive;

  Future<void> togglePlay(int adId, String audioUrl) async {
    try {
      if (_currentAdId == adId) {
        // Toggle play/pause for current audio
        if (_player.playing) {
          await _player.pause();
        } else {
          await _player.play();
        }
      } else {
        // Play new audio
        _currentAdId = adId;
        
        // Stop any currently playing audio
        await _player.stop();
        
        // Set and play the new audio
        await _player.setUrl(audioUrl);
        await _player.play();
      }
      
      notifyListeners();
    } catch (e) {
      print('Error playing audio: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    _currentAdId = null;
    await _player.stop();
    notifyListeners();
  }

  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
