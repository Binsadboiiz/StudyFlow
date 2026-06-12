import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:studyflow/core/network/api_constants.dart';
import 'package:studyflow/features/ai_chat/data/models/ai_chat_model.dart';
import 'package:studyflow/features/flashcard/data/models/flashcard_model.dart';

class AiChatRemoteDatasource {
  final FirebaseAuth auth;
  final String aiEndpoint = '${ApiConstants.baseUrl}/ai';

  AiChatRemoteDatasource({required this.auth});

  Future<ChatResponseModel> sendChatMessage(String message, List<ChatMessageModel> history) async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    
    final payload = {
      'message': message,
      'history': history.map((e) => e.toJson()).toList(),
    };

    final response = await http.post(
      Uri.parse('$aiEndpoint/chat'),
      headers: headers,
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      return ChatResponseModel.fromJson(responseBody['data']);
    } else {
      String? serverMessage;
      try {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        serverMessage = responseBody['message'];
      } catch (_) {}

      if (response.statusCode == 429) {
        throw Exception(serverMessage ?? 'AI daily request limit reached.');
      } else {
        throw Exception(serverMessage ?? 'Unable to receive response from AI. Please try again later.');
      }
    }
  }

  Future<List<ChatMessageModel>> getChatHistory() async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.get(Uri.parse('$aiEndpoint/history'), headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      final List<dynamic> jsonList = responseBody['data'] ?? [];
      return jsonList.map((e) => ChatMessageModel.fromJson(e)).toList();
    } else {
      String? serverMessage;
      try {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        serverMessage = responseBody['message'];
      } catch (_) {}
      throw Exception(serverMessage ?? 'Unable to load chat history.');
    }
  }

  Future<void> clearChatHistory() async {
    final headers = await ApiConstants.getAuthHeaders(auth);
    final response = await http.post(Uri.parse('$aiEndpoint/clear'), headers: headers);

    if (response.statusCode != 200) {
      String? serverMessage;
      try {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        serverMessage = responseBody['message'];
      } catch (_) {}
      throw Exception(serverMessage ?? 'Unable to clear chat history.');
    }
  }

  Future<FlashcardSetModel> generateFlashcardsFromDocument(String documentId, {String? customTitle}) async {
    final headers = await ApiConstants.getAuthHeaders(auth);

    final payload = {
      'documentId': documentId,
      'customTitle': customTitle,
    };

    final response = await http.post(
      Uri.parse('$aiEndpoint/generate-flashcards'),
      headers: headers,
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      return FlashcardSetModel.fromJson(responseBody['data']);
    } else if (response.statusCode == 429) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      throw Exception(responseBody['message'] ?? 'AI daily request limit reached.');
    } else {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      throw Exception(responseBody['message'] ?? 'Could not generate flashcards using AI.');
    }
  }
}
