import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
 import '../constants/app_constants.dart';
import '../services/audio_service.dart';

class AudioPlayerWidget extends StatelessWidget {
  final AudioService audioService;
  final String streamingUrl;

  const AudioPlayerWidget({
    Key? key,
    required this.audioService,
    required this.streamingUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppConstants.appAudioTitle,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          Text(
            AppConstants.appAudioDescription,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
           SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: Icon(
                    audioService.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    key: ValueKey(audioService.isPlaying),
                  ),
                ),
                onPressed: () => audioService.togglePlay(),
                iconSize: 60,
                color: AppConstants.primaryColor,
              ),
            ],
          ),
          StreamBuilder<Duration?>(
            stream: audioService.audioPlayer.positionStream,
            builder: (context, snapshot) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: audioService.isPlaying
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LoadingAnimationWidget.staggeredDotsWave(
                                color: AppConstants.primaryColor,
                                size: 40,
                              ),
                              LoadingAnimationWidget.staggeredDotsWave(
                                color: AppConstants.primaryColor,
                                size: 40,
                              ),
                              LoadingAnimationWidget.staggeredDotsWave(
                                color: AppConstants.primaryColor,
                                size: 40,
                              ),LoadingAnimationWidget.staggeredDotsWave(
                                color: AppConstants.primaryColor,
                                size: 40,
                              ),LoadingAnimationWidget.staggeredDotsWave(
                                color: AppConstants.primaryColor,
                                size: 40,
                              ),
                            ],
                          )
                        :           Divider(color: AppConstants.primaryColor, thickness: 2),

                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
