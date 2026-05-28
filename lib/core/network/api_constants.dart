import 'package:firebase_auth/firebase_auth.dart';

/// Chứa các hằng số và helper cho việc gọi API
class ApiConstants {
  // TODO: Thay đổi Base URL tùy vào môi trường (VD: http://10.0.2.2:5000 cho Android Emulator)
  static const String baseUrl = 'http://localhost:5000/api';

  /// Helper tạo Headers đính kèm Firebase ID Token
  static Future<Map<String, String>> getAuthHeaders(FirebaseAuth auth) async {
    final token = await auth.currentUser?.getIdToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
