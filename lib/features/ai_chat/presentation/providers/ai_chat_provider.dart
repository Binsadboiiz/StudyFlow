import 'package:flutter/material.dart';
import 'package:studyflow/features/ai_chat/data/datasource/ai_chat_remote_datasource.dart';
import 'package:studyflow/features/ai_chat/data/models/ai_chat_model.dart';

class AiChatProvider with ChangeNotifier {
  final AiChatRemoteDatasource remoteDatasource;

  List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _dailyRequestsRemaining = 20;

  List<ChatMessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get dailyRequestsRemaining => _dailyRequestsRemaining;

  AiChatProvider({required this.remoteDatasource});

  Future<ChatResponseModel?> sendMessage(String userMessage) async {
    if (userMessage.trim().isEmpty) return null;

    // Thêm message của user vào list cục bộ
    final userMsgObj = ChatMessageModel(role: 'user', content: userMessage);
    _messages.add(userMsgObj);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Gửi history giới hạn 6 tin nhắn gần nhất để tiết kiệm token context
      final history = _messages.length > 6 
          ? _messages.sublist(_messages.length - 6, _messages.length - 1)
          : _messages.sublist(0, _messages.length - 1);

      final responseObj = await remoteDatasource.sendChatMessage(userMessage, history);
      
      // Thêm câu trả lời của AI vào list
      _messages.add(ChatMessageModel(role: 'model', content: responseObj.response));
      _dailyRequestsRemaining = responseObj.dailyRequestsRemaining;
      notifyListeners();
      
      return responseObj;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      // Xóa message lỗi của user ra để tránh làm nhiễu lịch sử nếu muốn, hoặc giữ lại tùy ý
      _messages.removeLast();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadChatHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _messages = await remoteDatasource.getChatHistory();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearConversation() async {
    _messages.clear();
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDatasource.clearChatHistory();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void setDailyRequestsRemaining(int val) {
    _dailyRequestsRemaining = val;
    notifyListeners();
  }
}
