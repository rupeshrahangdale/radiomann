import 'package:audio_service/audio_service.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../constants/app_constants.dart';
import '../models/podcast_model.dart';
import '../models/program_model.dart';
import '../services/api_service.dart';
import '../utils/app_utils.dart';
import '../widgets/custom_app_bar.dart';
 import './podcast_player_screen.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  List<PodcastModel> _hostedPodcast = [];
  List<ProgramModel> _hostedPrograms = [];
  bool _isLoadingPodcast = true;
  bool _isLoadingProgram = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProgramsAndPodcast();
  }

  // void _showAudioPlayer(BuildContext context, String url) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AudioPopup(audioUrl: url),
  //   );
  // }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadProgramsAndPodcast() async {
    print("\n loading hosted podcasts and programs");
    _loadHostedPodcast();
    _loadHostedPrograms();
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

  Future<void> _loadHostedPrograms() async {
    setState(() {
      _isLoadingProgram = true;
    });

    try {
      final programs = await _apiService.getJointPrograms();
      print("programs: $programs \n\n\n\n\n");

      // Sort programs by date (newest first)
      programs.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _hostedPrograms = programs;
        _isLoadingProgram = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProgram = false;
      });
      AppUtils.showToast('Error loading joint programs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Programs'),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppConstants.primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppConstants.primaryColor,
              tabs: const [
                Tab(text: 'Podcasts'),
                Tab(text: 'Hosted Programs'),
              ],
            ),
          ),

          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Hosted Programs Tab
                _buildHostedPrdcastTab(),

                // Joint Programs Tab
                _buildHostedPrograms(),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildHostedPrograms() {
    return _isLoadingProgram
        ? Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: AppConstants.primaryColor,
              size: 50,
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadHostedPrograms,
            color: AppConstants.primaryColor,
            child: _hostedPrograms.isEmpty
                ? const Center(
                    child: Text(
                      'No programs available',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _hostedPrograms.length,
                    itemBuilder: (context, index) {
                      final program = _hostedPrograms[index];
                      return _buildProgramCard(
                        program,
                        onTap: () => _openVideoPlayer(program),
                      );
                    },
                  ),
          );
  }

  Widget _buildProgramCard(
    ProgramModel program, {
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
            // Program Poster
            if (program.posterUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.defaultBorderRadius),
                  topRight: Radius.circular(AppConstants.defaultBorderRadius),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CachedNetworkImage(
                      imageUrl: program.posterUrl!,
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

                    // Play button overlay
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                    ),
                  ],
                ),
              ),

            // Program Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Program Name
                  Text(
                    program.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Program Date and Time
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppUtils.formatDate(program.date),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(program.time, style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Program Place
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: AppConstants.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          program.place,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),

                  // Program Description
                  if (program.description != null &&
                      program.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Description:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      program.description!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],

                  // Tap instruction
                  const SizedBox(height: 16),
                  Text(
                    program.isHosted == 'hosted'
                        ? 'Tap to watch video'
                        : 'Tap to open external link',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  Text("${program.externalLink}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openVideoPlayer(ProgramModel program) {
    if (program.videoUrl == null || program.videoUrl!.isEmpty) {
      AppUtils.showToast('Video not available');
      return;
    }

    // Navigate to video player screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _VideoPlayerScreen(videoUrl: program.videoUrl!),
      ),
    );
  }

  void _openExternalLink(ProgramModel program) {
    print("Opening external link: ${program.externalLink} \n\n\n\n\n");

    if (program.externalLink == null || program.externalLink!.isEmpty) {
      AppUtils.showToast('External link not available');
      return;
    }

    // Open external link
    AppUtils.launchURL(program.externalLink!);
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

  void _openPodcastPlayer(String? url) {
    if (url == null || url.isEmpty) {
      AppUtils.showToast('Podcast URL not available');
      return;
    }
    AppUtils.launchURL(url);
  }
}

class _VideoPlayerScreen extends StatelessWidget {
  final String videoUrl;

  const _VideoPlayerScreen({required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Program Video', showBackButton: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO: Implement video player using video_player or chewie package
            // For now, just show a placeholder
            Icon(
              Icons.play_circle_fill,
              size: 100,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 20),
            const Text(
              'Video Player Placeholder',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => AppUtils.launchURL(videoUrl),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('Open Video in Browser'),
            ),
          ],
        ),
      ),
    );
  }
}

class AudioPopup extends StatefulWidget {
  final String audioUrl;
  final String title;
  final String imageUrl;

  const AudioPopup({
    Key? key,
    required this.audioUrl,
    this.title = "Podcast Episode",
    this.imageUrl = AppConstants.demoNotifcationAudioImageURL,
  }) : super(key: key);

  @override
  State<AudioPopup> createState() => _AudioPopupState();
}

class _AudioPopupState extends State<AudioPopup> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudio();
  }

  Future<void> _initAudio() async {
    print(
      "Initializing podcast audio player with URL: ${widget.audioUrl} \n\n\n\n",
    );

    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(widget.audioUrl),
          tag: MediaItem(
            id: widget.audioUrl,
            album: "Podcasts",
            title: widget.title,
            artUri: Uri.parse(widget.imageUrl),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error loading audio: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _closePopup() {
    _audioPlayer.stop();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<Duration>(
            stream: _audioPlayer.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final total = _audioPlayer.duration ?? Duration.zero;
              return ProgressBar(
                progress: position,
                total: total,
                onSeek: (duration) => _audioPlayer.seek(duration),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<bool>(
                stream: _audioPlayer.playingStream,
                builder: (context, snapshot) {
                  final isPlaying = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    iconSize: 36,
                    onPressed: () {
                      if (isPlaying) {
                        _audioPlayer.pause();
                      } else {
                        _audioPlayer.play();
                      }
                    },
                  );
                },
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.close),
                iconSize: 28,
                onPressed: _closePopup,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
