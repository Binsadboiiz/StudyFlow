import 'package:firebase_auth/firebase_auth.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Chứa các hằng số và helper cho việc gọi API
class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) return 'http://192.168.1.81:5141/api';
    if (Platform.isAndroid) return 'http://192.168.1.81:5141/api';
    return 'http://192.168.1.81:5141/api';
  }

  static String get googleClientId {
    if (kIsWeb) return '252578618828-i7lamrdbktcpft29733n5uhsqpmiuf99.apps.googleusercontent.com';
    if (Platform.isAndroid) return '252578618828-i7lamrdbktcpft29733n5uhsqpmiuf99.apps.googleusercontent.com';
    return '252578618828-i7lamrdbktcpft29733n5uhsqpmiuf99.apps.googleusercontent.com';
  }

  /// Helper tạo Headers đính kèm Firebase ID Token
  static Future<Map<String, String>> getAuthHeaders(FirebaseAuth auth) async {
    final token = await auth.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
