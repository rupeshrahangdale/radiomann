class EnquiryModel {
  final int? id;
  final String name;
  final String email;
  final String mobile;
  final String message;
  final int? status;
  final String? createdAt;
  final String? updatedAt;

  EnquiryModel({
    this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.message,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory EnquiryModel.fromJson(Map<String, dynamic> json) {
    return EnquiryModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      message: json['message'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'mobile': mobile,
      'message': message,
    };
  }
}