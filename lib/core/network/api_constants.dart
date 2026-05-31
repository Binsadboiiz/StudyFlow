import 'package:firebase_auth/firebase_auth.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Chứa các hằng số và helper cho việc gọi API
class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5141/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5141/api';
    return 'http://localhost:5141/api';
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
