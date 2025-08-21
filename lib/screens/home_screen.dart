import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../constants/app_constants.dart';
import '../models/birthday_sticker_model.dart';
import '../models/slider_model.dart';
import '../models/streaming_model.dart';
import '../models/contact_model.dart';
import '../models/social_media_model.dart';
import '../models/birthday_wish_model.dart';
import '../services/api_service.dart';
import '../services/audio_service.dart';
import '../utils/app_utils.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/news_headline_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  late List<SliderModel> _sliders = [];
  StreamingModel? _streamingModel;
  ContactInfoSocial? _socialMediaModel;
  List<BirthdayStickerModel> _birthdayStickers = [];


  bool _isLoading = true;
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  DateTime? _lastLoadTime;

  @override
  void initState() {
    super.initState();
    print("Initializing HomeScreen... \n\n\n\n");
    // Register this object as an observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    _loadData();
    _setupAudioPlayer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // This will be called when the app is resumed from background
    if (state == AppLifecycleState.resumed) {
      print("App resumed, refreshing home screen data... \n\n\n\n");
      _loadData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("didChangeDependencies called... \n\n\n\n");

    // Get the current route
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      // Check if we need to refresh (if it's been more than 2 seconds since last refresh)
      final now = DateTime.now();
      if (_lastLoadTime == null ||
          now.difference(_lastLoadTime!).inSeconds > 2) {
        print("Refreshing HomeScreen data... \n\n\n\n");
        _loadData();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Update last load time
    _lastLoadTime = DateTime.now();

    setState(() {
      _isLoading = true;
    });

    try {
      final streamingFuture = getStreamingLink();
      final contactFuture = getContactSocial();
      final slidersFuture = _apiService.getSliders();
      final stickersFuture = _apiService.getBirthdayStickers();

      final results = await Future.wait([
        streamingFuture,
        contactFuture,
        slidersFuture,
        stickersFuture,
      ]);

      _streamingModel = results[0] as StreamingModel?;
      _socialMediaModel = results[1] as ContactInfoSocial?;
      _sliders = results[2] as List<SliderModel>;
      _birthdayStickers = results[3] as List<BirthdayStickerModel>;

      setState(() {
        _isLoading = false;
      });

      // Set the URL in our audio service
      final audioService = Provider.of<AudioService>(context, listen: false);
      await audioService.setUrl(_streamingModel?.streamingUrl ?? '');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error loading data: $e  \n\n\n\n");
      AppUtils.showToast('Error loading data: $e');
    }
  }

  void _setupAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioService = Provider.of<AudioService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          AppConstants.appName,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppConstants.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const CustomDrawer(),
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: AppConstants.primaryColor,
                size: 50,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              color: AppConstants.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    NewsHeadlineSlider(),
                    // Image Slider
                    _buildImageSlider(),

                    AudioPlayerWidget(
                      audioService: audioService,
                      streamingUrl: _streamingModel?.streamingUrl ?? '',
                    ),

                    _buildBirthdayStickerSection(), // ✅ new section
                    // Audio Player Section
                    // _buildAudioPlayerSection(),

                    // Contact and Social Media Section
                    _buildContactSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImageSlider() {
    if (_sliders.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[300],
        alignment: Alignment.center,
        child: Image(image: NetworkImage("${AppConstants.demoNetworkURL}")),
      );
    }

    return ImageSlideshow(
      width: double.infinity,
      height: 200,
      initialPage: 0,
      indicatorColor: AppConstants.primaryColor,
      indicatorBackgroundColor: Colors.grey,
      autoPlayInterval: 3000,
      isLoop: true,
      children: _sliders.map((slider) {
        return Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Colors.grey[300]),
          child: CachedNetworkImage(
            imageUrl: slider.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: AppConstants.primaryColor,
                size: 30,
              ),
            ),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBirthdayStickerSection() {
    if (_birthdayStickers.isEmpty) return const SizedBox.shrink();

    final sticker = _birthdayStickers[0];

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            "We Wish You Very Happy Birthday",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Image with loading animation + rounded corners
          ClipRRect(
            borderRadius: BorderRadius.circular(
              AppConstants.defaultBorderRadius,
            ),
            child: CachedNetworkImage(
              imageUrl: sticker.stickerUrl,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: Center(
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: AppConstants.primaryColor,
                    size: 30,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(
              red: 128,
              green: 128,
              blue: 128,
              alpha: 51,
            ), // 0.2 alpha
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Social Media Icons
          const Text(
            'Follow Us',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (_socialMediaModel?.facebookUrl != null)
                _buildSocialMediaIcon(
                  icon: FontAwesomeIcons.facebook,
                  color: const Color(0xFF1877F2),
                  onTap: () =>
                      AppUtils.launchURL(_socialMediaModel!.facebookUrl),
                ),
              if (_socialMediaModel?.twitterUrl != null)
                _buildSocialMediaIcon(
                  icon: FontAwesomeIcons
                      .twitter, // Using flutter_dash as a substitute for Twitter/X
                  color: const Color(0xFF1DA1F2),
                  onTap: () =>
                      AppUtils.launchURL(_socialMediaModel!.twitterUrl),
                ),
              if (_socialMediaModel?.instagramUrl != null)
                _buildSocialMediaIcon(
                  icon: FontAwesomeIcons.instagram,
                  color: const Color(0xFFE1306C),
                  onTap: () =>
                      AppUtils.launchURL(_socialMediaModel!.instagramUrl),
                ),
              if (_socialMediaModel?.youtubeUrl != null)
                _buildSocialMediaIcon(
                  icon: FontAwesomeIcons.youtube,
                  color: const Color(0xFFFF0000),
                  onTap: () =>
                      AppUtils.launchURL(_socialMediaModel!.youtubeUrl),
                ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Contact Us',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Call Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppUtils.launchPhoneCall(_socialMediaModel!.mobile);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.defaultBorderRadius,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  icon: const Icon(FontAwesomeIcons.phone),
                  label: const Text('Call Us'),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    AppUtils.openWhatsApp(_socialMediaModel!.whatsapp);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppConstants.defaultBorderRadius,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                  ),
                  icon: const Icon(FontAwesomeIcons.whatsapp),
                  label: const Text('Chat with Us'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSocialMediaIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}
