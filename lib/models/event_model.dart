class EventModel {
  final int id;
  final String name;
  final DateTime date;
  final String time;
  final String place;
  final String? posterUrl;
  final String? description;

  EventModel({
    required this.id,
    required this.name,
    required this.date,
    required this.time,
    required this.place,
    this.posterUrl,
    this.description,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      place: json['place'],
      posterUrl: json['poster_url'],
      description: json['description'],
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
    };
  }
}