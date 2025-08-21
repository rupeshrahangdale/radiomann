import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../constants/app_constants.dart';

import '../services/api_service.dart';

class NewsHeadlineSlider extends StatefulWidget {
  const NewsHeadlineSlider({Key? key}) : super(key: key);

  @override
  State<NewsHeadlineSlider> createState() => _NewsHeadlineSliderState();
}

class _NewsHeadlineSliderState extends State<NewsHeadlineSlider> {
  final ApiService _apiService = ApiService();
  String headline = '';

  @override
  void initState() {
    super.initState();
    _loadHeadline();
  }

  Future<void> _loadHeadline() async {
    final news = await _apiService.fetchNewsHeadline();
    if (news != null) {
      setState(() {
        headline = news.headline;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: AppConstants.backgroundColor,
      child: headline.isEmpty
          ? const Center(
        child: Text(
          "Loading headline...",
          style: TextStyle(color: Colors.white),
        ),
      )
          : Marquee(
        text: headline,
        style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
        velocity: 50.0,
        blankSpace: 50.0,
        pauseAfterRound: const Duration(seconds: 1),
      ),
    );
  }
}
