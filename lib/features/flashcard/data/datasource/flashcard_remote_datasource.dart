import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyflow/core/network/api_constants.dart';
import 'package:studyflow/features/flashcard/data/models/flashcard_model.dart';

class FlashcardRemoteDatasource {
  final FirebaseAuth auth;
  final String flashcardEndpoint = '${ApiConstants.baseUrl}/flashcards';

  FlashcardRemoteDatasource({required this.auth});

  Future<List<FlashcardSetModel>> getFlashcardSets() async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.get(Uri.parse(flashcardEndpoint), headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      final List<dynamic> jsonList = responseBody['data'] ?? [];
      return jsonList.map((json) => FlashcardSetModel.fromJson(json)).toList();
    } else {
      throw Exception('Không thể tải danh sách bộ flashcard');
    }
  }

  Future<FlashcardSetModel> getFlashcardSetById(String id) async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.get(Uri.parse('$flashcardEndpoint/$id'), headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      return FlashcardSetModel.fromJson(responseBody['data']);
    } else {
      throw Exception('Không tìm thấy bộ flashcard');
    }
  }

  Future<FlashcardSetModel> createFlashcardSet(String title, {String? targetDocumentId, required List<Map<String, String>> cards}) async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    
    final payload = {
      'title': title,
      'targetDocumentId': targetDocumentId,
      'flashcards': cards
    };

    final response = await http.post(
      Uri.parse(flashcardEndpoint),
      headers: headers,
      body: json.encode(payload),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      return FlashcardSetModel.fromJson(responseBody['data']);
    } else {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      throw Exception(responseBody['message'] ?? 'Không thể tạo bộ flashcard mới');
    }
  }

  Future<void> deleteFlashcardSet(String id) async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.delete(Uri.parse('$flashcardEndpoint/$id'), headers: headers);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Không thể xóa bộ flashcard');
    }
  }
}
