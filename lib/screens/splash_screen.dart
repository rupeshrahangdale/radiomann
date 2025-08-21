import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    initializeApp();
    print(
      "Splash screen initialized \nLoading base URL and checking login status... \n\n\n\n\n",
    );

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Create animation
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Start animation
    _animationController.forward();

    print(
      "API base url ${AppConstants.apiBaseURL} \n\n navigating to home screen in 3 seconds...",
    );

    // Navigate to home screen after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen()));
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> initializeApp() async {
    print("Initializing app... loading base URL and checking login status");
    await RemoteConfigService.loadBaseURL();
    setState(() {
      print("Base URL loaded: ${AppConstants.apiBaseURL}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              const Spacer(),

              // Logo animation
              FadeTransition(
                opacity: _animation,
                child: ScaleTransition(
                  scale: _animation,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: const Image(
                      image: AssetImage(
                        AppConstants.appLogo,
                        // 'https://radiobharatbharti.com/assets/images/logo.png',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // App name
              FadeTransition(
                opacity: _animation,
                child: Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ),

              const Spacer(),

              // App version at bottom
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'Version ${AppConstants.appVersion}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
