import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/podcast_model.dart';
import '../services/podcast_audio_service.dart';
import '../constants/app_constants.dart';

class PodcastPlayerScreen extends StatefulWidget {
  final PodcastModel podcast;

  const PodcastPlayerScreen({super.key, required this.podcast});

  @override
  State<PodcastPlayerScreen> createState() => _PodcastPlayerScreenState();
}

class _PodcastPlayerScreenState extends State<PodcastPlayerScreen> {
  late PodcastAudioService _audioService;
  
  @override
  void initState() {
    super.initState();
    _audioService = PodcastAudioService();
    // Set podcast audio service as active
    _audioService.isActive = true;
    _loadPodcast();
  }

  Future<void> _loadPodcast() async {
    await _audioService.loadPodcast(widget.podcast);
  }

  @override
  void dispose() {
    // Set podcast audio service as inactive when leaving screen
    _audioService.isActive = false;
    // We don't dispose the audio service here since it's a singleton
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _audioService,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Podcast Player'),
          backgroundColor: AppConstants.primaryColor,
          elevation: 0,
        ),
        body: Consumer<PodcastAudioService>(
          builder: (context, audioService, child) {
            return Column(
              children: [
                // Podcast Image and Info
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppConstants.primaryColor,
                          AppConstants.primaryColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Podcast Image
                        Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: widget.podcast.thumbnailUrl != null &&
                                    widget.podcast.thumbnailUrl!.isNotEmpty
                                ? Image.network(
                                    widget.podcast.thumbnailUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.podcasts,
                                          size: 80,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.podcasts,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Podcast Title
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            widget.podcast.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Podcast Speaker
                        if (widget.podcast.speaker != null)
                          Text(
                            widget.podcast.speaker!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                // Player Controls
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Progress Bar
                        Column(
                          children: [
                            Slider(
                              value: audioService.position.inSeconds.toDouble(),
                              min: 0,
                              max: audioService.duration.inSeconds.toDouble() > 0
                                  ? audioService.duration.inSeconds.toDouble()
                                  : 1,
                              activeColor: AppConstants.primaryColor,
                              inactiveColor: Colors.grey[300],
                              onChanged: (value) {
                                audioService.seek(Duration(seconds: value.toInt()));
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_formatDuration(audioService.position)),
                                  Text(_formatDuration(audioService.duration)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Control Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.replay_10),
                              iconSize: 40,
                              onPressed: () {
                                audioService.seek(audioService.position - const Duration(seconds: 10));
                              },
                            ),
                            const SizedBox(width: 20),
                            Container(
                              decoration: BoxDecoration(
                                color: AppConstants.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                iconSize: 50,
                                onPressed: () {
                                  audioService.togglePlay();
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            IconButton(
                              icon: const Icon(Icons.forward_30),
                              iconSize: 40,
                              onPressed: () {
                                audioService.seek(audioService.position + const Duration(seconds: 30));
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Description
                if (widget.podcast.description != null && widget.podcast.description!.isNotEmpty)
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              widget.podcast.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}