import 'package:flutter/material.dart';

class AppConstants {
  // App name
  static const String appName = 'Radio Mann';
  static const String appVersion = '1.0.0';

  static const String appAudioDescription = 'Listen to our live radio stream';
  static const String appAudioTitle = 'Radio Mann Live ';
  // app logo
  static const String appLogo = 'assets/images/logo.png';

  // Colors
  static const Color primaryColor = Color(0xE5FF0000); // Bright Red
  static const Color secondaryColor = Color(0xFF333333);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF212121);
  static const Color lightTextColor = Color(0xFF757575);

  // API Endpoints
  static String apiBaseURL = '';
  // static const String baseUrl = 'https://radiobharatbharti.com'; // Replace with actual API base URL
  static const String apiAuthToken = 'RABTK875673'; // API Authentication Token

  // API Endpoints from documentation
  static const String streamingUrlsEndpoint = '/api/streaming-urls';
  static const String contactInfoEndpoint = '/api/contact-info';
  static const String privacyPolicyEndpoint = '/api/privacy-policy';
  static const String birthdayStickersEndpoint = '/api/birthday-stickers';
  static const String birthdayWishRequestEndpoint =
      '/api/birthday-wish-request';
  static const String photosEndpoint = '/api/photos';
  static const String upcomingEventsEndpoint = '/api/upcoming-events';
  static const String programsEndpoint = '/api/programs';
  static const String programsByTypeEndpoint =
      '/api/programs/'; // Append 'Live' or 'Recorded'
  static const String podcastsEndpoint = '/api/podcasts';
  static const String enquiryEndpoint = '/api/enquiry';
  static const String newsHeadlinesEndpoint = '/api/news-headline';
  static var sampleAdsEndpoint = '/api/sample-ads';

  // Legacy endpoints (keeping for backward compatibility)
  static const String slidersEndpoint = '/api/app-slider';
  static const String demoNetworkURL =
      'https://e7.pngegg.com/pngimages/210/602/png-clipart-golden-age-of-radio-internet-radio-antique-radio-music-radio-electronics-fm-broadcasting.png';
  static const String demoAssetsURL = 'assets/images/pngegg.png';
  static const String demoAudioURL =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
  static const String demoNotifcationAudioImageURL =
      'asset:///assets/images/logo.png';

  // Padding and Margin
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Border Radius
  static const double defaultBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Animation Duration
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Font Sizes
  static const double headingFontSize = 24.0;
  static const double subheadingFontSize = 18.0;
  static const double bodyFontSize = 14.0;
  static const double smallFontSize = 12.0;
  // Phone and WhatsApp numbers
  static const String phoneNumber = "+911234567890";
  static const String whatsappNumber =
      "911234567890"; // with country code, no +
}
