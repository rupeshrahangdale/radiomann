import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../constants/app_constants.dart';
import '../models/podcast_model.dart';
import '../models/program_model.dart';
import '../sampleui.dart';
import '../services/api_service.dart';
import '../utils/app_utils.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/podcast_player_dialog.dart';
import './podcast_player_screen.dart';

class AdSampleAndRate extends StatefulWidget {
  const AdSampleAndRate({super.key});

  @override
  State<AdSampleAndRate> createState() => _AdSampleAndRateState();
}

class _AdSampleAndRateState extends State<AdSampleAndRate>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  List<PodcastModel> _hostedPodcast = [];
  bool _isLoadingPodcast = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _loadProgramsAndPodcast();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProgramsAndPodcast() async {
    print("\n loading hosted podcasts and programs");
    _loadHostedPodcast();
  }

  Future<void> _loadHostedPodcast() async {
    setState(() {
      _isLoadingPodcast = true;
    });

    try {
      final podcasts = await _apiService.getPodcasts();
      print("Podcasts: $podcasts");

      setState(() {
        _hostedPodcast = podcasts;
        _isLoadingPodcast = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingPodcast = false;
      });
      print("Error loading hosted podcasts: $e");
      AppUtils.showToast('Error loading hosted programs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Programs'),
      body: Container(child: AdSampleRateScreen()),
    );
  }

  Widget _buildHostedPrdcastTab() {
    return _isLoadingPodcast
        ? Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: AppConstants.primaryColor,
              size: 50,
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadHostedPodcast,
            color: AppConstants.primaryColor,
            child: _hostedPodcast.isEmpty
                ? const Center(
                    child: Text(
                      'No podcasts available',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _hostedPodcast.length,
                    itemBuilder: (context, index) {
                      final podcast = _hostedPodcast[index];
                      return _buildPodcastCard(
                        podcast,
                        onTap: () => {
                          print("Opening podcast: ${podcast.title} \n\n\n"),
                          print(
                            "Podcast URL: ${podcast.podcastAudioUrl} \n\n\n",
                          ),
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  PodcastPlayerScreen(podcast: podcast),
                            ),
                          ),
                        },
                      );
                    },
                  ),
          );
  }

  //===================

  // your_widget.dart
  Widget _buildPodcastCard(
    PodcastModel podcast, {
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            if (podcast.thumbnailUrl != null &&
                podcast.thumbnailUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.defaultBorderRadius),
                  topRight: Radius.circular(AppConstants.defaultBorderRadius),
                ),
                child: CachedNetworkImage(
                  imageUrl: podcast.thumbnailUrl!,
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 170,
                    color: Colors.grey[300],
                    child: Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: AppConstants.primaryColor,
                        size: 30,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 170,
                    color: Colors.grey[300],
                    child: const Icon(Icons.error),
                  ),
                ),
              ),

            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    podcast.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Speaker
                  if (podcast.speaker != null && podcast.speaker!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.person,
                          size: 16,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(podcast.speaker!),
                      ],
                    ),

                  const SizedBox(height: 5),

                  // Duration
                  if (podcast.duration != null && podcast.duration!.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(podcast.duration!),
                      ],
                    ),

                  const SizedBox(height: 8),

                  // Description
                  if (podcast.description != null &&
                      podcast.description!.isNotEmpty)
                    Text(
                      podcast.description!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),

                  const SizedBox(height: 8),

                  // Footer
                  Text(
                    'Tap to listen to podcast',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
