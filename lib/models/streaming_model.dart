import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';

class StreamingModel {
  final String streamingUrl;
  final String status;

  StreamingModel({
    required this.streamingUrl,
    required this.status,
  });

  factory StreamingModel.fromJson(Map<String, dynamic> json) {
    return StreamingModel(
      streamingUrl: json['streaming_url'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

Future<StreamingModel> getStreamingLink() async {
  final response = await http.get(
    Uri.parse('${AppConstants.apiBaseURL}/api/streaming-urls'),
    headers: {
      'Authorization': 'RABTK875673',
    },
  );

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body);

    if (jsonData['data'] != null && jsonData['data'] is List && jsonData['data'].isNotEmpty) {
      // Take the first item in the list
      return StreamingModel.fromJson(jsonData['data'][0]);
    } else {
      throw Exception('No streaming URLs found');
    }
  } else {
    throw Exception('Failed to load streaming URLs');
  }
}
