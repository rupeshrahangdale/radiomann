class BirthdayStickerModel {
  final int id;
  final String stickerUrl;

  BirthdayStickerModel({
    required this.id,
    required this.stickerUrl,
  });

  factory BirthdayStickerModel.fromJson(Map<String, dynamic> json) {
    return BirthdayStickerModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      stickerUrl: json['sticker_url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sticker_url': stickerUrl,
    };
  }
}
