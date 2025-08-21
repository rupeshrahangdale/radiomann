import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class GalleryModel {
  final int id;
  final String imageUrl;
  final String? title;
  final String? description;

  GalleryModel({
    required this.id,
    required this.imageUrl,
    this.title,
    this.description,
  });

  factory GalleryModel.fromJson(Map<String, dynamic> json, String baseUrl) {
    return GalleryModel(
      id: json['id'],
      imageUrl: "${json['full_url']}",
      title: json['caption'], // API field: caption
      description: null, // No description in API
    );
  }
}

Future<List<GalleryModel>> getGalleryImages() async {
  final response = await http.get(
    Uri.parse('${AppConstants.apiBaseURL}/api/photos'),
    headers: {'Authorization': 'RABTK875673'},
  );

  if (response.statusCode == 200) {
    print("Response: ${response.body}");
    final data = jsonDecode(response.body);
    if (data['status'] == true) {
      final List images = data['data'];
      return images
          .map((item) => GalleryModel.fromJson(item, AppConstants.apiBaseURL))
          .toList();
    }
  }
  throw Exception('Failed to load gallery images');
}
