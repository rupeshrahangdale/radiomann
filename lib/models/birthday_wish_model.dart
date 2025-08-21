class BirthdayWishModel {
  final int? id;
  final String name;
  final String birthDate;
  final String? message;
  final String? imageUrl;
  final bool isApproved;

  BirthdayWishModel({
    this.id,
    required this.name,
    required this.birthDate,
    this.message,
    this.imageUrl,
    this.isApproved = false,
  });

  factory BirthdayWishModel.fromJson(Map<String, dynamic> json) {
    return BirthdayWishModel(
      id: json['id'],
      name: json['name'],
      birthDate: json['birth_date'],
      message: json['message'],
      imageUrl: json['image_url'],
      isApproved: json['is_approved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birth_date': birthDate,
      'message': message,
      'image_url': imageUrl,
      'is_approved': isApproved,
    };
  }
}