import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/podcast_model.dart';

class PodcastPlayerDialog extends StatefulWidget {
  final PodcastModel podcast;

  const PodcastPlayerDialog({super.key, required this.podcast});

  @override
  State<PodcastPlayerDialog> createState() => _PodcastPlayerDialogState();
}

class _PodcastPlayerDialogState extends State<PodcastPlayerDialog> {
  late final AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _loadAudio();
  }

  Future<void> _loadAudio() async {
    if (widget.podcast.audioUrl != null && widget.podcast.audioUrl!.isNotEmpty) {
      try {
        await _player.setUrl(widget.podcast.audioUrl!);
      } catch (e) {
        debugPrint('Error loading audio: $e');
      }
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.podcast.thumbnailUrl;
    final title = widget.podcast.title;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(imageUrl, height: 150, width: 150, fit: BoxFit.cover)
                  : Container(
                height: 150,
                width: 150,
                color: Colors.grey[300],
                child: const Icon(Icons.podcasts, size: 50),
              ),
            ),
            const SizedBox(height: 16),

            // Play / Pause Button
            StreamBuilder<PlayerState>(
              stream: _player.playerStateStream,
              builder: (context, snapshot) {
                final state = snapshot.data;
                final playing = state?.playing ?? false;

                if (playing) {
                  return IconButton(
                    icon: const Icon(Icons.pause, size: 40),
                    onPressed: () => _player.pause(),
                  );
                } else {
                  return IconButton(
                    icon: const Icon(Icons.play_arrow, size: 40),
                    onPressed: () => _player.play(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
