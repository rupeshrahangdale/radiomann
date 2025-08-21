class ContactModel {
  final String? phoneNumber;
  final String? email;
  final String? address;
  final String? whatsappNumber;
  final String? callButtonUrl;

  ContactModel({
    this.phoneNumber,
    this.email,
    this.address,
    this.whatsappNumber,
    this.callButtonUrl,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      phoneNumber: json['phone_number'],
      email: json['email'],
      address: json['address'],
      whatsappNumber: json['whatsapp_number'],
      callButtonUrl: json['call_button_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'whatsapp_number': whatsappNumber,
      'call_button_url': callButtonUrl,
    };
  }
}