class NewsHeadline {
  final int id;
  final String headline;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  NewsHeadline({
    required this.id,
    required this.headline,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewsHeadline.fromJson(Map<String, dynamic> json) {
    return NewsHeadline(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      headline: json['headline'] ?? '',
      status: json['status'].toString(),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }
}
