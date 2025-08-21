import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/adsample_model.dart';
import '../models/newe_headline.dart';
import '../models/slider_model.dart';
import '../models/contact_model.dart';
import '../models/birthday_wish_model.dart';
import '../models/birthday_sticker_model.dart';
import '../models/event_model.dart';
import '../models/program_model.dart';
import '../models/podcast_model.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  // Generic GET request with authentication header
  Future<dynamic> _get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseURL}$endpoint'),
        headers: {
          'Authorization': AppConstants.apiAuthToken,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Check for API response format from documentation
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('status') &&
            responseData.containsKey('data')) {
          if (responseData['status'] == true) {
            return responseData['data'];
          } else {
            throw Exception(
              responseData['message'] ?? 'API returned error status',
            );
          }
        }
        return responseData;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else if (response.statusCode == 404) {
        throw Exception('Resource not found');
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Generic POST request with authentication header
  Future<dynamic> _post(String endpoint, Map<String, dynamic> data) async {
    try {
      print("Posting data to $endpoint: $data");
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseURL}$endpoint'),
        headers: {
          'Authorization': AppConstants.apiAuthToken,
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      print("Response status: ${response}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Response body: ${response.body}");
        final responseData = json.decode(response.body);
        // Check for API response format from documentation
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('status') &&
            responseData.containsKey('data')) {
          if (responseData['status'] == true) {
            return responseData['data'];
          } else {
            throw Exception(
              responseData['message'] ?? 'API returned error status',
            );
          }
        }
        return responseData;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else if (response.statusCode == 404) {
        throw Exception('Resource not found');
      } else if (response.statusCode == 422) {
        throw Exception('Validation failed');
      } else {
        throw Exception('Failed to post data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get sliders for home screen
  // Future<List<SliderModel>> getSliders() async {
  //   final data = await _get(AppConstants.slidersEndpoint);
  //   print("Sliders endpoint: ${AppConstants.slidersEndpoint}");
  //   print("Sliders data: $data \n\n\n\n");
  //   if (data is! List) {
  //     throw Exception('Invalid data format for sliders');
  //   }
  //   print("Sliders data: $data \n\n\n\n");
  //   return (data).map((item) => SliderModel.fromJson(item)).toList();
  // }
  Future<List<SliderModel>> getSliders() async {
    final data = await _get(AppConstants.slidersEndpoint);
    if (data is! List) {
      throw Exception('Invalid data format for sliders');
    }
    return data.map<SliderModel>((item) => SliderModel.fromJson(item)).toList();
  }

  // // Get streaming URLs (new API)
  // Future<List<StreamingModel>> getStreamingUrls() async {
  //   final data = await _get(AppConstants.streamingUrlsEndpoint);
  //   if (data is! List) {
  //     throw Exception('Invalid data format for streaming URLs');
  //   }
  //   print("Streaming URLs data: $data \n\n\n\n");
  //
  //   return (data).map((item) => StreamingModel.fromJson({
  //     'streaming_url': item['streaming_url'] as String,
  //     'title': null,
  //     'description': null,
  //     'cover_image_url': null,
  //   })).toList();
  // }

  // Get streaming link (legacy API - for backward compatibility)
  // Future<StreamingModel> getStreamingLink() async {
  //   try {
  //     print("Attempting to get streaming link from new API...\n\n ");
  //     // Try new API first
  //     final streamingUrls = await getStreamingUrls();
  //
  //     if (streamingUrls.isNotEmpty) {
  //       return streamingUrls.first;
  //     }
  //     throw Exception('No streaming URLs available');
  //   } catch (e) {
  //     // Fall back to legacy API
  //     final data = await _get(AppConstants.streamingLinkEndpoint);
  //     if (data is! Map<String, dynamic>) {
  //       throw Exception('Invalid data format for streaming link');
  //     }
  //     print("Streaming link data: $data \n\n\n\n");
  //     return StreamingModel.fromJson(data);
  //   }
  // }

  // Future<StreamingModel> getStreamingLink() async {
  //   final response = await http.get(
  //     Uri.parse('${AppConstants.baseUrl}/api/streaming-urls'),
  //     headers: {
  //       'Authorization': 'RABTK875673',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final jsonData = jsonDecode(response.body);
  //
  //     if (jsonData['data'] != null && jsonData['data'] is List && jsonData['data'].isNotEmpty) {
  //       // Take the first item in the list
  //       return StreamingModel.fromJson(jsonData['data'][0]);
  //     } else {
  //       throw Exception('No streaming URLs found');
  //     }
  //   } else {
  //     throw Exception('Failed to load streaming URLs');
  //   }
  // }

  // Get contact info (new API)
  Future<ContactModel> getContactInfo() async {
    final data = await _get(AppConstants.contactInfoEndpoint);
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid data format for contact info');
    }
    print("Contact info data: $data \n\n\n\n");
    return ContactModel.fromJson({
      'phone_number': data['mobile'],
      'email': data['email'],
      'address': data['address'],
      'whatsapp_number': data['whatsapp'],
      'call_button_url': null,
    });
  }

  // Get social media links from contact info
  // Future<SocialMediaModel> getSocialMediaLinks() async {
  //   final data = await _get(AppConstants.contactInfoEndpoint);
  //   if (data is! Map<String, dynamic>) {
  //     throw Exception('Invalid data format for social media links');
  //   }
  //   print("Social media links data: $data \n\n\n\n");
  //   return SocialMediaModel.fromJson({
  //     'facebook_url': data['facebook_url'],
  //     'twitter_url': data['twitter_url'],
  //     'instagram_url': data['instagram_url'],
  //     'youtube_url': data['youtube_url'],
  //   });
  // }

  // Legacy method for backward compatibility
  Future<ContactModel> getContactDetails() async {
    return getContactInfo();
  }

  // Legacy method for social media links (kept for backward compatibility)
  // Future<SocialMediaModel> _getLegacySocialMediaLinks() async {
  //   final data = await _get(AppConstants.socialMediaEndpoint);
  //   if (data is! Map<String, dynamic>) {
  //     throw Exception('Invalid data format for social media links');
  //   }
  //   print("Legacy social media links data: $data \n\n\n\n");
  //   return SocialMediaModel.fromJson(data);
  // }

  // Get privacy policy
  Future<String> getPrivacyPolicy() async {
    final data = await _get(AppConstants.privacyPolicyEndpoint);
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid data format for privacy policy');
    }
    print("Privacy policy data: $data \n\n\n\n");
    return data['content'] ?? '';
  }

  // Get birthday stickers
  Future<List<BirthdayStickerModel>> getBirthdayStickers() async {
    final data = await _get(AppConstants.birthdayStickersEndpoint);
    if (data is! List) {
      throw Exception('Invalid data format for birthday stickers');
    }
    print("Birthday stickers data: $data \n\n\n\n");
    return (data)
        .map((item) => BirthdayStickerModel.fromJson(item))
        .toList();
  }

  // Submit birthday wish request (new API)
  Future<bool> submitBirthdayWish({
    required String name,
    required DateTime birthDate,
    required String message,
    File? imageFile, // optional
  }) async {
    try {
      final uri = Uri.parse('${AppConstants.apiBaseURL}${AppConstants.birthdayWishRequestEndpoint}');

      // If image is selected -> use multipart
      if (imageFile != null) {
        var request = http.MultipartRequest('POST', uri);

        request.headers['Authorization'] = AppConstants.apiAuthToken;

        // Text fields
        request.fields['name'] = name;
        request.fields['dob'] = birthDate.toIso8601String().split('T')[0]; // YYYY-MM-DD
        request.fields['message'] = message;

        // File field (must be birthday_photo as per API)
        request.files.add(await http.MultipartFile.fromPath(
          'birthday_photo',
          imageFile.path,
        ));

        final response = await request.send();

        if (response.statusCode == 200 || response.statusCode == 201) {
          final resBody = await response.stream.bytesToString();
          print("Response body (multipart): $resBody");
          return true;
        } else {
          final errorBody = await response.stream.bytesToString();
          throw Exception("Upload failed [${response.statusCode}]: $errorBody");
        }
      } else {
        // No image -> normal JSON post
        final wishData = {
          'name': name,
          'dob': birthDate.toIso8601String().split('T')[0],
          'message': message,
        };

        await _post(AppConstants.birthdayWishRequestEndpoint, wishData);
        return true;
      }
    } catch (e) {
      print("Error submitting birthday wish: $e");
      return false;
    }
  }



  // Get birthday wishes
  Future<List<BirthdayWishModel>> getBirthdayWishes() async {
    final data = await _get(AppConstants.birthdayStickersEndpoint);
    if (data is! List) {
      throw Exception('Invalid data format for birthday wishes');
    }
    print("Birthday wishes data: $data \n\n\n\n");
    return (data)
        .map((item) => BirthdayWishModel.fromJson(item))
        .toList();
  }

  // Get gallery images (new API)
  // Future<List<GalleryModel>> getGalleryImages() async {
  //   try {
  //     final data = await _get(AppConstants.photosEndpoint);
  //     if (data is! List) {
  //       throw Exception('Invalid data format for gallery images');
  //     }
  //     print("Gallery images data: $data \n\n\n\n");
  //     return (data as List).map((item) => GalleryModel.fromJson({
  //       'id': item['id'],
  //       'image_url': item['photo_url'],
  //       'title': null,
  //       'description': item['caption'],
  //       'upload_date': item['created_at'],
  //     })).toList();
  //   } catch (e) {
  //     // Fall back to legacy endpoint
  //     final data = await _get(AppConstants.galleryEndpoint);
  //     if (data is! List) {
  //       throw Exception('Invalid data format for gallery images');
  //     }
  //     return (data as List).map((item) => GalleryModel.fromJson(item)).toList();
  //   }
  // }

  // Get upcoming events (new API)
  Future<List<EventModel>> getEvents() async {
    try {
      final data = await _get(AppConstants.upcomingEventsEndpoint);
      if (data is! List) {
        throw Exception('Invalid data format for events');
      }
      print("Events data: $data \n\n\n\n");
      return (data)
          .map(
            (item) => EventModel.fromJson({
              'id': item['id'],
              'name': item['event_name'],
              'date': item['event_date_time'].split(' ')[0],
              'time': item['event_date_time'].split(' ')[1],
              'place': item['event_place'],
              'poster_url': item['event_poster_url'],
              'description': item['event_details'],
            }),
          )
          .toList();
    } catch (e) {
      // Fall back to legacy endpoint
      final data = await _get(AppConstants.upcomingEventsEndpoint);
      if (data is! List) {
        throw Exception('Invalid data format for events');
      }
      return (data).map((item) => EventModel.fromJson(item)).toList();
    }
  }

  // Get all programs (new API)
  Future<List<ProgramModel>> getAllPrograms() async {
    final data = await _get(AppConstants.programsEndpoint);
    if (data is! List) {
      throw Exception('Invalid data format for programs');
    }
    print("Programs data: $data \n\n\n\n");
    return (data)
        .map(
          (item) => ProgramModel.fromJson({
            'id': item['id'],
            'name': item['program_name'],
            'date': item['program_date'],
            'time': item['program_time'],
            'place': item['program_place'],
            'poster_url': item['program_poster_url'],
            'description': null,
            'video_url': null,
            'external_link': item['program_link'],
            'is_hosted': item['program_type'] == 'Live',
          }),
        )
        .toList();
  }

  // Get programs by type (Live or Recorded)
  Future<List<ProgramModel>> getProgramsByType(String type) async {
    if (type != 'Live' && type != 'Recorded') {
      throw Exception(
        'Invalid program type. Must be either "Live" or "Recorded"',
      );
    }

    final data = await _get('${AppConstants.programsByTypeEndpoint}$type');

    if (data is! List) {
      throw Exception('Invalid data format for programs');
    }
    print("Programs by type data: $data \n\n\n\n");
    return (data)
        .map(
          (item) => ProgramModel.fromJson({
            'id': item['id'],
            'name': item['program_name'],
            'date': item['program_date'],
            'time': item['program_time'],
            'place': item['program_place'],
            'poster_url': item['program_poster_url'],
            'description': null,
            'video_url': item["program_link"],
            'external_link': item['program_link'],
            'is_hosted': item['program_type'] == 'Live',
          }),
        )
        .toList();
  }

  // // Get hosted programs (legacy API - for backward compatibility)
  // Future<List<ProgramModel>> getHostedPrograms() async {
  //   try {
  //     return await getProgramsByType('Live');
  //   } catch (e) {
  //     // Fall back to legacy endpoint
  //     final data = await _get(AppConstants.programsByTypeEndpoint);
  //     if (data is! List) {
  //       throw Exception('Invalid data format for hosted programs');
  //     }
  //     print("Hosted programs data: $data \n\n\n\n");
  //     return (data).map((item) => ProgramModel.fromJson(item)).toList();
  //   }
  // }
  //
  // // Get joint programs (legacy API - for backward compatibility)
  Future<List<ProgramModel>> getJointPrograms() async {
    try {
      return await getProgramsByType('Recorded');
    } catch (e) {
      // Fall back to legacy endpoint
      final data = await _get(AppConstants.programsEndpoint);
      if (data is! List) {
        throw Exception('Invalid data format for joint programs');
      }
      print("Joint programs data: $data \n\n\n\n");
      return (data).map((item) => ProgramModel.fromJson(item)).toList();
    }
  }


  // Future<List<PodcastModel>> getPodcasts() async {
  //   final response = await _get(AppConstants.podcastsEndpoint);
  //
  //   if (response is Map && response.containsKey('data')) {
  //     final data = response['data'];
  //
  //     if (data is! List) {
  //       throw Exception('Invalid data format for podcasts');
  //     }
  //     print("Api response Podcasts data  : $data \n\n\n\n");
  //     return data.map<PodcastModel>((item) => PodcastModel.fromJson(item)).toList();
  //   } else {
  //     throw Exception('Invalid response format');
  //   }
  // }

  Future<List<PodcastModel>> getPodcasts() async {
    final response = await _get(AppConstants.podcastsEndpoint);

    if (response is List) {
      return response
          .map<PodcastModel>((item) => PodcastModel.fromJson(item))
          .toList();
    } else {
      throw Exception('Invalid data format for podcasts');
    }
  }


  Future<List<PodcastModel>> fetchHostedPodcasts() async {
    final response = await http.get(Uri.parse('YOUR_API_URL'));

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse is Map && jsonResponse['data'] is List) {
        return (jsonResponse['data'] as List)
            .map((item) => PodcastModel.fromJson(item))
            .toList();
      } else {
        throw Exception("Invalid response format");
      }
    } else {
      throw Exception("Failed to load podcasts");
    }
  }

  Future<NewsHeadline?> fetchNewsHeadline() async {
    final url = Uri.parse("${AppConstants.apiBaseURL}${AppConstants.newsHeadlinesEndpoint}");
    final response = await http.get(url, headers: {
      'Authorization': '${AppConstants.apiAuthToken}',
    });

    if (response.statusCode == 200) {
      print("News headline response: ${response.body}");
      final Map<String, dynamic> jsonData = json.decode(response.body);
      if (jsonData['status'] == true) {
        return NewsHeadline.fromJson(jsonData['data']);
      }
    }
    return null;
  }


  Future<SampleAdsResult> fetchSampleAds() async {
    print("Fetching sample ads from API...");
    final uri = Uri.parse('${AppConstants.apiBaseURL}${AppConstants.sampleAdsEndpoint}');
    final res = await http.get(
      uri,
      headers: {
        'Authorization': AppConstants.apiAuthToken,
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200) {
      print("Sample ads response: ${res.body} \n\n\n");
      final jsonBody = json.decode(res.body);
      if (jsonBody is Map<String, dynamic> && (jsonBody['status'] == true)) {
        return SampleAdsResult.fromJson(jsonBody);
      } else {
        throw Exception('API returned error: ${jsonBody['message'] ?? 'Unknown error'}');
      }
    } else {
      throw Exception('Failed to fetch sample ads: ${res.statusCode} ${res.body}');
    }
  }


  // Submit enquiry (new API)
  Future<bool> submitEnquiry({
    required String name,
    required String email,
    required String mobile,
    required String message,
  }) async {
    try {
      final enquiryData = {
        'name': name,
        'email': email,
        'mobile': mobile,
        'message': message,
      };

      await _post(AppConstants.enquiryEndpoint, enquiryData);
      return true;
    } catch (e) {
      print("Error submitting enquiry: $e");
      return false;
    }
  }

  // Submit contact form (legacy API - for backward compatibility)
  Future<bool> submitContactForm({
    required String name,
    required String email,
    required String phone,
    required String message,
  }) async {
    return submitEnquiry(
      name: name,
      email: email,
      mobile: phone,
      message: message,
    );
  }
}



class RemoteConfigService {
  static Future<void> loadBaseURL() async {
    final url = Uri.parse(
        "https://nextinlabs.com/AppRemoteConfiguration/remote-configure.php");

    final response = await http.post(
      url,
      body: jsonEncode({
        "app_id": "RADIOBHARATBHARTI_C_1",
        "app_package_name": "com.nxtinlbs.radiobharatbharti"
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print("Base URL response: ${jsonData.toString()}");
      if (jsonData["status"] == "success") {
        AppConstants.apiBaseURL = jsonData["data"]["app_config_url"];
        print(
            "Base URL loaded successfully: ${AppConstants.apiBaseURL}  \n\n\n\n");
      } else {
        throw Exception("Base URL config not found");
      }
    } else {
      throw Exception("Failed to load base URL");
    }
  }
}