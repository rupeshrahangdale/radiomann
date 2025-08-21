class ProgramModel {
  final int id;
  final String name;
  final DateTime date;
  final String time;
  final String place;
  final String? posterUrl;
  final String? description;
  final String? videoUrl; // For hosted programs
  final String? externalLink; // For join programs
  final bool isHosted; // To differentiate between hosted and join programs

  ProgramModel({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.place,
    this.posterUrl,
    this.description,
    this.videoUrl,
    this.externalLink,
    required this.isHosted,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      place: json['place'],
      posterUrl: json['poster_url'],
      description: json['description'],
      videoUrl: json['video_url'] ?? json['program_link'], // for hosted
      externalLink: json['external_link'] ?? json['program_link'], // for joint
      isHosted: json['is_hosted'] ?? (json['video_url'] != null),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'time': time,
      'place': place,
      'poster_url': posterUrl,
      'description': description,
      'video_url': videoUrl,
      'external_link': externalLink,
      'is_hosted': isHosted,
    };
  }
}