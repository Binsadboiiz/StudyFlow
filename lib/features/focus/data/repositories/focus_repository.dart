import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyflow/core/network/api_constants.dart';
import 'package:studyflow/features/focus/data/models/focus_session_model.dart';

class FocusRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<FocusSessionModel?> saveFocusSession(FocusSessionModel session) async {
    try {
      final headers = await ApiConstants.getAuthHeaders(_auth);
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/Focus/sessions'),
        headers: headers,
        body: jsonEncode(session.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return FocusSessionModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('Error saving focus session: $e');
      return null;
    }
  }

  Future<List<DailyFocusHeatmapModel>> getHeatmapData(DateTime startDate, DateTime endDate) async {
    try {
      final headers = await ApiConstants.getAuthHeaders(_auth);
      final start = startDate.toIso8601String();
      final end = endDate.toIso8601String();
      
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/Focus/heatmap?startDate=$start&endDate=$end'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => DailyFocusHeatmapModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching heatmap data: $e');
      return [];
    }
  }

  Future<List<FocusSessionModel>> getFocusSessions() async {
    try {
      final headers = await ApiConstants.getAuthHeaders(_auth);
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/Focus/sessions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => FocusSessionModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching focus sessions: $e');
      return [];
    }
  }
}
