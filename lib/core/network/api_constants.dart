import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


/// Chứa các hằng số và helper cho việc gọi API
class ApiConstants {
  static String get baseUrl {
    final url = dotenv.env['BACKEND_URL'];
    if (url == null) throw Exception('BACKEND_URL not found');
    return url;
  }

  static String get googleClientId {
    final clientId = dotenv.env['GOOGLE_CLIENT_ID'];
    if (clientId == null) throw Exception('GOOGLE_CLIENT_ID not found');
    return clientId;
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
