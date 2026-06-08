import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyflow/core/network/api_constants.dart';
import 'package:studyflow/features/gamification/data/models/pet_model.dart';

/// Repository quản lý việc gọi API liên quan tới Thú cưng học tập.
class PetRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Lấy thông tin trạng thái Pet của người dùng.
  Future<PetModel?> getPet() async {
    try {
      final headers = await ApiConstants.getAuthHeaders(_auth);
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/Pet'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return PetModel.fromJson(body['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting study pet: $e');
      return null;
    }
  }

  /// Nhận nuôi Pet mới với tên và chủng loại.
  Future<PetModel?> adoptPet(String name, String petType) async {
    try {
      final headers = await ApiConstants.getAuthHeaders(_auth);
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/Pet/adopt'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'petType': petType,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return PetModel.fromJson(body['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error adopting pet: $e');
      return null;
    }
  }

  /// Cho Pet ăn (tiêu tốn 10 Coins).
  Future<PetModel?> feedPet() async {
    try {
      final headers = await ApiConstants.getAuthHeaders(_auth);
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/Pet/feed'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return PetModel.fromJson(body['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error feeding pet: $e');
      return null;
    }
  }

  /// Tương tác/Vui chơi cùng Pet.
  Future<PetModel?> interactPet() async {
    try {
      final headers = await ApiConstants.getAuthHeaders(_auth);
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/Pet/interact'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return PetModel.fromJson(body['data']);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error interacting with pet: $e');
      return null;
    }
  }
}
