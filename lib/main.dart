import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:radio_mann/services/podcast_audio_service.dart';
  import 'constants/app_constants.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/birthday_wish_screen.dart';
import 'screens/photo_gallery_screen.dart';
import 'screens/events_screen.dart';
import 'screens/programs_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'services/audio_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Keep your orientation settings
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.radiomann.channel.audio',
    androidNotificationChannelName: 'Radio man Audio',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Keep your status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // runApp(
  //   ChangeNotifierProvider(
  //     create: (context) => AudioService(),
  //     child:MyApp(),
  //   ),
  // );

  runApp(
    MultiProvider(
      providers: [
         ChangeNotifierProvider(create: (context) => AudioService()),
          ChangeNotifierProvider(create: (context) => PodcastAudioService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppConstants.primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          primary: AppConstants.primaryColor,
        ),
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(color: AppConstants.textColor),
          bodyLarge: TextStyle(color: AppConstants.textColor),
          bodyMedium: TextStyle(color: AppConstants.textColor),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/birthday_wish': (context) => const BirthdayWishScreen(),
        '/photo_gallery': (context) => const PhotoGalleryScreen(),
        '/events': (context) => const EventsScreen(),
        '/programs': (context) => const ProgramsScreen(),
        '/contact': (context) => const ContactScreen(),
        '/privacy_policy': (context) => const PrivacyPolicyScreen(),
      },
    );
  }
}
