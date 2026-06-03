import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyflow/core/network/api_constants.dart';
import '../models/notification_model.dart';

/// Data source to call backend notifications API.
class NotificationRemoteDatasource {
  final FirebaseAuth auth;
  final String notificationEndpoint = '${ApiConstants.baseUrl}/notifications';

  NotificationRemoteDatasource({required this.auth});

  /// Get notifications for current user from API.
  Future<List<NotificationModel>> getNotifications() async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.get(Uri.parse(notificationEndpoint), headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      final List<dynamic> jsonList = responseBody['data'] ?? [];
      return jsonList.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications from API');
    }
  }

  /// Delete a notification by ID via API.
  Future<void> deleteNotification(String id) async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.delete(
      Uri.parse('$notificationEndpoint/$id'),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete notification');
    }
  }

  /// Clear all notifications via API.
  Future<void> clearAllNotifications() async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.delete(
      Uri.parse(notificationEndpoint),
      headers: headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to clear notifications');
    }
  }
}
