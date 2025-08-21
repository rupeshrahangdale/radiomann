import 'package:flutter/material.dart';
 import '../constants/app_constants.dart';
import '../sampleui.dart';
import '../screens/home_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/birthday_wish_screen.dart';
import '../screens/photo_gallery_screen.dart';
import '../screens/events_screen.dart';
import '../screens/programs_screen.dart';
import '../screens/contact_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: AppConstants.primaryColor),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 42,

                  backgroundColor: Colors.white,

                  child: Image(image: AssetImage(AppConstants.appLogo),height: 70,width: 70,),
                ),
                 Text(
                  AppConstants.appName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            title: 'Home',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushReplacement(
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  )
                  .then((_) {
                    // Optionally, you can refresh the home screen if needed
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const HomeScreen(),
                      ),
                    );
                  });
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.cake,
            title: 'Birthday Wishes',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BirthdayWishScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.photo_library,
            title: 'Photo Gallery',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PhotoGalleryScreen(),
                ),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.event,
            title: 'Events',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const EventsScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.live_tv,
            title: 'Programs',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProgramsScreen()),
              );
            },
          ),   _buildDrawerItem(
            context,
            icon: Icons.ad_units_outlined,
            title: 'AD Sample & Rate',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const AdSampleRateScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.contact_phone,
            title: 'Contact Us',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ContactScreen()),
              );
            },
          ),
          _buildDrawerItem(
            context,
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppConstants.primaryColor),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}
