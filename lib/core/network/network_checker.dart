import 'dart:async';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class NetworkChecker {
  /// Kiểm tra xem server có đang hoạt động và có thể kết nối được không.
  /// Hàm này gọi api ping và có set timeout ngắn (mặc định 5s)
  /// Giúp app không bị loading vô hạn.
  static Future<bool> isServerReachable({int timeoutSeconds = 5}) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/health/ping');
      final response = await http.get(url).timeout(
        Duration(seconds: timeoutSeconds),
        onTimeout: () {
          throw TimeoutException('The connection has timed out.');
        },
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      // Có thể là SocketException (mất mạng) hoặc TimeoutException
      return false;
    }
  }
}
