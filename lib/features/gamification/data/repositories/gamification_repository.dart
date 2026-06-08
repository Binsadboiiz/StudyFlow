import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyflow/core/network/api_constants.dart';
import 'package:studyflow/features/gamification/data/models/gamification_summary_model.dart';
import 'package:studyflow/features/gamification/data/models/badge_model.dart';
import 'package:studyflow/features/gamification/data/models/leaderboard_entry_model.dart';

/// Repository quản lý việc gọi API liên quan tới điểm số, cấp độ, huy hiệu và bảng xếp hạng.
class GamificationRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Lấy thông tin tóm tắt điểm và streak hiện tại của người dùng.
  Future<GamificationSummaryModel?> getSummary() async {
    try {
      final headers = await ApiConstants.getAuthHeaders(_auth);
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/Gamification/summary'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return GamificationSummaryModel.fromJson(body['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting gamification summary: $e');
      return null;
    }
  }

  /// Lấy danh sách toàn bộ huy hiệu kèm trạng thái đã đạt/chưa đạt.
  Future<List<BadgeModel>> getBadges() async {
    try {
      final headers = await ApiConstants.getAuthHeaders(_auth);
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/Gamification/badges'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> jsonList = body['data'];
          return jsonList.map((json) => BadgeModel.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting badges: $e');
      return [];
    }
  }

  /// Lấy danh sách bảng xếp hạng học sinh toàn cầu và thứ hạng của người dùng hiện tại theo một tiêu chí.
  Future<Map<String, dynamic>?> getLeaderboard(String sortBy) async {
    try {
      final headers = await ApiConstants.getAuthHeaders(_auth);
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/Gamification/leaderboard?sortBy=$sortBy'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final data = body['data'];
          final List<dynamic> jsonList = data['entries'] ?? [];
          final entries = jsonList.map((json) => LeaderboardEntryModel.fromJson(json)).toList();
          final userRank = data['userRank'] ?? 0;
          return {
            'entries': entries,
            'userRank': userRank,
          };
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting leaderboard: $e');
      return null;
    }
  }

  /// Cài đặt huy hiệu nổi bật (Danh hiệu hiển thị cạnh tên).
  Future<bool> setFeaturedBadge(String? badgeId) async {
    try {
      final headers = await ApiConstants.getAuthHeaders(_auth);
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/Gamification/featured-badge'),
        headers: headers,
        body: jsonEncode({
          'badgeId': badgeId,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['success'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error setting featured badge: $e');
      return false;
    }
  }
}
