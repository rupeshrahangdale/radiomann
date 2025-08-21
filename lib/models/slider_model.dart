class SliderModel {
  final int id;
  final String imageUrl;
  final String? caption;
  final String? fullUrl;

  SliderModel({
    required this.id,
    required this.imageUrl,
    this.caption,
    this.fullUrl,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      id: json['id'] ?? 0,
      // Prefer full_url if available, else slider_photo_url
      imageUrl: json['full_url'] ?? json['slider_photo_url'] ?? '',
      caption: json['caption'],
      fullUrl: json['full_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'caption': caption,
      'full_url': fullUrl,
    };
  }
}
