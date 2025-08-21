// podcast_model.dart
class PodcastModel {
  final int? id;
  final String? podcastTitle;
  final String? podcastSpeaker;
  final String? podcastDuration;
  final String? podcastThumbnail;
  final String? podcastAudio;
  final String? podcastDescription;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? podcastThumbnailUrl;
  final String? podcastAudioUrl;

  // Getters for backward compatibility with your widget
  String get title => podcastTitle ?? '';
  String? get speaker => podcastSpeaker;
  String? get duration => podcastDuration;
  String? get thumbnailUrl => podcastThumbnailUrl;
  String? get audioUrl => podcastAudioUrl;
  String? get description => podcastDescription;

  PodcastModel({
    this.id,
    this.podcastTitle,
    this.podcastSpeaker,
    this.podcastDuration,
    this.podcastThumbnail,
    this.podcastAudio,
    this.podcastDescription,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.podcastThumbnailUrl,
    this.podcastAudioUrl,
  });

  factory PodcastModel.fromJson(Map<String, dynamic> json) {
    return PodcastModel(
      id: json['id'],
      podcastTitle: json['podcast_title'] as String?,
      podcastSpeaker: json['podcast_speaker'] as String?,
      podcastDuration: json['podcast_duration'] as String?,
      podcastThumbnail: json['podcast_thumbnail'] as String?,
      podcastAudio: json['podcast_audio'] as String?,
      podcastDescription: json['podcast_description'] as String?,
      status: json['status']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      podcastThumbnailUrl: json['podcast_thumbnail_url'] as String?,
      podcastAudioUrl: json['podcast_audio_url'] as String?,
    );
  }
}


// class PodcastModel {
//   final int id;
//   final String title;
//   final String description;
//   final String audioUrl;
//   final String imageUrl;
//
//   PodcastModel({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.audioUrl,
//     required this.imageUrl,
//   });
//
//   factory PodcastModel.fromJson(Map<String, dynamic> json) {
//     return PodcastModel(
//       id: json['id'] ?? 0,
//       title: json['podcast_title'] ?? '',
//       description: json['description'] ?? '',
//       audioUrl: json['audio_url'] ?? '',
//       imageUrl: json['image_url'] ?? '',
//     );
//   }
// }


