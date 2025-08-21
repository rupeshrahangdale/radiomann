import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class ContactInfoSocial {
  final String mobile;
  final String email;
  final String address;
  final String whatsapp;
  final String instagramUrl;
  final String facebookUrl;
  final String twitterUrl;
  final String youtubeUrl;

  ContactInfoSocial({
    required this.mobile,
    required this.email,
    required this.address,
    required this.whatsapp,
    required this.instagramUrl,
    required this.facebookUrl,
    required this.twitterUrl,
    required this.youtubeUrl,
  });

  factory ContactInfoSocial.fromJson(Map<String, dynamic> json) {
    return ContactInfoSocial(
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      instagramUrl: json['instagram_url'] ?? '',
      facebookUrl: json['facebook_url'] ?? '',
      twitterUrl: json['twitter_url'] ?? '',
      youtubeUrl: json['youtube_url'] ?? '',
    );
  }
}




Future<ContactInfoSocial> getContactSocial() async {
  final url = Uri.parse("${AppConstants.apiBaseURL}/api/contact-info");

  final response = await http.get(
    url,
    headers: {
      "Authorization": "RABTK875673",
      "Content-Type": "application/json",
    },
  );

  if (response.statusCode == 200) {
    print("Response: ${response.body}");
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    if (jsonResponse['status'] == true) {
      
      return ContactInfoSocial.fromJson(jsonResponse['data']);
    } else {
      throw Exception(jsonResponse['message'] ?? "Unknown error");
    }
  } else {
    throw Exception("Failed to load contact info. Status code: ${response.statusCode}");
  }
}