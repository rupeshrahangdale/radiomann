// screens/ad_sample_rate_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
 import 'package:radio_mann/services/ad_sample_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_service.dart';

import 'constants/app_constants.dart';
import 'models/adsample_model.dart';

class AdSampleRateScreen extends StatefulWidget {
  const AdSampleRateScreen({super.key});

  @override
  State<AdSampleRateScreen> createState() => _AdSampleRateScreenState();
}

class _AdSampleRateScreenState extends State<AdSampleRateScreen> {
  final ApiService _api = ApiService();

  late Future<SampleAdsResult> _future;

  // Use the singleton audio service
  final AdSampleAudioService _audioService = AdSampleAudioService();

  // calculator
  final TextEditingController _secondsCtrl = TextEditingController(text: '10');
  double _ratePerSecond = 0.0;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchSampleAds();

    _future.then((result) {
      setState(() {
        _ratePerSecond = result.ratePerSecond;
        _total = (double.tryParse(_secondsCtrl.text.trim()) ?? 0.0) * _ratePerSecond;
      });
    });

    // Set this service as active when screen is visible
    _audioService.isActive = true;

    // Listen to audio service changes to update UI
    _audioService.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _secondsCtrl.dispose();
    // Set this service as inactive when screen is disposed
    _audioService.isActive = false;
    // Stop any playing audio when leaving this screen
    if (_audioService.isPlaying) {
      _audioService.stop();
    }
    // Remove listener when widget is disposed
    _audioService.removeListener(() {
      setState(() {});
    });
    super.dispose();
  }


  Future<void> _togglePlay(SampleAd ad) async {
    if (ad.audioUrl == null || ad.audioUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No audio available for this sample.')),
      );
      return;
    }

    try {
      await _audioService.togglePlay(ad.id!, ad.audioUrl!);
      setState(() {}); // refresh play/pause icon
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playback error: $e')),
      );
    }
  }


  void _recalc() {
    final secs = double.tryParse(_secondsCtrl.text.trim()) ?? 0.0;
    setState(() {
      _total = secs * _ratePerSecond;
    });
  }

  String _money(double v) => '₹ ${v.toStringAsFixed(2)}';

  Future<void> _callNow() async {
    final uri = Uri.parse('tel:${AppConstants.phoneNumber}');
    if (!await launchUrl(uri)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open dialer')),
      );
    }
  }

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse(
        'https://wa.me/${AppConstants.whatsappNumber}?text=Hello%20I%20am%20interested%20in%20radio%20ads');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ad Samples & Rate'),
        backgroundColor: AppConstants.primaryColor,
      ),
      body: FutureBuilder<SampleAdsResult>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final result = snap.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...result.ads.map((ad) {
                  final hasAudio = (ad.audioUrl ?? '').isNotEmpty;
                  final bool isPlaying = _audioService.currentAdId == ad.id && _audioService.isPlaying;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(ad.title ?? 'Untitled'),
                      subtitle: Text(ad.duration ?? '—'),
                      trailing: ElevatedButton.icon(
                        onPressed: hasAudio ? () => _togglePlay(ad) : null,
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                        label: Text(isPlaying ? 'Pause' : 'Play'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPlaying ? Colors.red : AppConstants.primaryColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),

                const Text('Rate Calculator',
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _secondsCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(
                          labelText: 'No. of Seconds',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => _recalc(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Rate: ${_money(_ratePerSecond)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Total Charge: ${_money(_total)}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 20),
                _ExamplesBlock(
                    ratePerSecond: _ratePerSecond, secondsCtrl: _secondsCtrl),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _callNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppConstants.primaryColor,
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
                        icon: const Icon(Icons.call),
                        label: const Text('Call'),
                      ),
                    ),
                    SizedBox(width:15 ,),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _openWhatsApp();
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
              ],
            ),
          );
        },
      ),
    );
  }
}


class _ExamplesBlock extends StatelessWidget {
  const _ExamplesBlock({
    required this.ratePerSecond,
    required this.secondsCtrl,
  });

  final double ratePerSecond;
  final TextEditingController secondsCtrl;

  String _money(double v) => '₹ ${v.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final secs = double.tryParse(secondsCtrl.text.trim()) ?? 0.0;
    final perSpot = secs * ratePerSecond;      // single spot cost
    final tenSpotsPerDay = perSpot * 10;       // 10 spots/day
    final tenDays = tenSpotsPerDay * 10;       // 10 days

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('10 Spots per Day = ${_money(perSpot)} × 10 = ${_money(tenSpotsPerDay)}/day'),
        Text('10 Days = ${_money(tenSpotsPerDay)} × 10 = ${_money(tenDays)} / 10 days'),
        const SizedBox(height: 8),
        const Text('Rates are negotiable. Please contact us.'),
      ],
    );
  }
}
