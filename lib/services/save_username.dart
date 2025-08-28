import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class UsernameStore {

  static const _key = 'username';
  static const _userIdKey = 'user_id';
  
  static Future<String?> get() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_key);
  }

  static Future<String?> getUserId() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_userIdKey);
  }

  static Future<void> set(String name) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_key, name.trim());
    
    // Check if user_id already exists, if not generate a new one
    if (p.getString(_userIdKey) == null) {
      final userId = _generateUserId();
      await p.setString(_userIdKey, userId);
    }
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
    await p.remove(_userIdKey);
  }
  
  // Generate a random 10-digit user ID
  static String _generateUserId() {
    final random = Random();
    String userId = '';
    
    // Ensure first digit is not zero for a true 10-digit number
    userId += (random.nextInt(9) + 1).toString();
    
    // Generate the remaining 9 digits
    for (int i = 0; i < 9; i++) {
      userId += random.nextInt(10).toString();
    }
    
    return userId;
  }
}
