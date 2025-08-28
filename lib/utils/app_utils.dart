import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../constants/app_constants.dart';

class AppUtils {
  // Launch URL
  static Future<bool> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);

      // showToast('Could not launch $url');
      // return false;
    }
  }

  // Launch phone call
  static Future<bool> launchPhoneCall(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    } else {
      showToast('Could not make call to $phoneNumber');
      return false;
    }
  }

  // Alias for launchPhoneCall for backward compatibility
  static Future<bool> makePhoneCall(String phoneNumber) async {
    return launchPhoneCall(phoneNumber);
  }

  // Launch WhatsApp
  static Future<bool> launchWhatsApp(
    String phoneNumber, {
    String message = 'hii',
  }) async {
    final Uri uri = Uri.parse(
      // 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}'
      'https://api.whatsapp.com/send/?phone=$phoneNumber&text=${Uri.encodeComponent(message)}&type=phone_number&app_absent=0',
    );
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // Alias for launchWhatsApp for backward compatibility
  static Future<bool> openWhatsApp(
    String phoneNumber, {
    String message = '',
  }) async {
    return launchWhatsApp(phoneNumber, message: message);
  }

  // Launch email
  static Future<bool> launchEmail(
    String email, {
    String subject = '',
    String body = '',
  }) async {
    final Uri uri = Uri.parse(
      'mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    } else {
      showToast('Could not open email client');
      return false;
    }
  }

  // Alias for launchEmail for backward compatibility
  static Future<bool> sendEmail(
    String email, {
    String subject = 'your subject',
    String body = 'your message',
  }) async {
    return launchEmail(email, subject: subject, body: body);
  }

  // Show toast message
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: AppConstants.primaryColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Format date
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  // Check if string is a valid URL
  static bool isValidUrl(String url) {
    Uri? uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  // Check if string is a valid email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Check if string is a valid phone number
  static bool isValidPhoneNumber(String phoneNumber) {
    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phoneNumber);
  }

  // Alias for isValidPhoneNumber for backward compatibility
  static bool isValidPhone(String phoneNumber) {
    return isValidPhoneNumber(phoneNumber);
  }
}
