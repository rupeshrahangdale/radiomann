// models/sample_ads_model.dart
class SampleAd {
  final int id;
  final String? title;
  final String? duration; // e.g., "10 Sec."
  final String? audio;
  final String? audioUrl;

  SampleAd({
    required this.id,
    this.title,
    this.duration,
    this.audio,
    this.audioUrl,
  });

  factory SampleAd.fromJson(Map<String, dynamic> json) {
    return SampleAd(
      id: (json['id'] ?? 0) is int ? json['id'] ?? 0 : int.tryParse('${json['id']}') ?? 0,
      title: json['sample_ad_title'] as String?,
      duration: json['sample_ad_duration'] as String?,
      audio: json['sample_ad_audio'] as String?,
      audioUrl: json['sample_ad_audio_url'] as String?,
    );
  }
}

class SampleAdsResult {
  final List<SampleAd> ads;
  final double ratePerSecond;

  SampleAdsResult({required this.ads, required this.ratePerSecond});

  factory SampleAdsResult.fromJson(Map<String, dynamic> json) {
    final dataList = (json['data'] as List?) ?? const [];
    final ads = dataList.map((e) => SampleAd.fromJson(e as Map<String, dynamic>)).toList();

    // "Rate_Per_Second": "7.20"
    final rpsRaw = json['Rate_Per_Second'];
    double rps;
    if (rpsRaw is num) {
      rps = rpsRaw.toDouble();
    } else if (rpsRaw is String) {
      rps = double.tryParse(rpsRaw.replaceAll(',', '')) ?? 0.0;
    } else {
      rps = 0.0;
    }

    return SampleAdsResult(ads: ads, ratePerSecond: rps);
  }
}
