import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../services/audio_service.dart';
import '../constants/app_constants.dart';

class AdSampleAudioService extends ChangeNotifier {
  static final AdSampleAudioService _instance = AdSampleAudioService._internal();

  factory AdSampleAudioService() => _instance;

  late final AudioPlayer _player;
  int? _currentAdId;
  bool _isPlaying = false;
  bool _isActive = false; // Track if this service is active (screen is visible)

  AdSampleAudioService._internal() {
    // Use the shared audio player instance instead of creating a new one
    _player = GlobalAudioService.player;

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
    if (!_isActive) {
      // Always stop and reset when leaving the screen, regardless of playing state
      stop(); // Stop playback when screen becomes inactive
      
      // Reset the player state to allow other services to use it
      _player.stop();
      _currentAdId = null;
      _isPlaying = false;
      notifyListeners();
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
          // Make sure we stop any other audio services first
          final audioService = AudioService();
          if (audioService.currentStreamUrl.isNotEmpty) {
            audioService.currentStreamUrl = '';
          }
          
          await _player.play();
        }
      } else {
        // Play new audio
        _currentAdId = adId;
        
        // Make sure we stop any other audio services first
        final audioService = AudioService();
        if (audioService.currentStreamUrl.isNotEmpty) {
          audioService.currentStreamUrl = '';
        }
        
        // Stop any currently playing audio
        await _player.stop();
        
        // Set and play the new audio with MediaItem tag
        await _player.setAudioSource(
          AudioSource.uri(
            Uri.parse(audioUrl),
            tag: MediaItem(
              id: adId.toString(),
              album: "Radio Mann",
              title: "Ad Sample $adId",
              artUri: Uri.parse(AppConstants.appLogo),
            ),
          ),
        );
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

  // Don't dispose the shared player
  @override
  void dispose() {
    // Remove listeners but don't dispose the shared player
    super.dispose();
  }
}
