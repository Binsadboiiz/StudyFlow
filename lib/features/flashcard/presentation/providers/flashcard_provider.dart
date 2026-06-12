import 'package:flutter/material.dart';
import 'package:studyflow/features/flashcard/data/datasource/flashcard_remote_datasource.dart';
import 'package:studyflow/features/ai_chat/data/datasource/ai_chat_remote_datasource.dart';
import 'package:studyflow/features/flashcard/data/models/flashcard_model.dart';

class FlashcardProvider with ChangeNotifier {
  final FlashcardRemoteDatasource remoteDatasource;
  final AiChatRemoteDatasource aiRemoteDatasource;

  List<FlashcardSetModel> _flashcardSets = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FlashcardSetModel> get flashcardSets => _flashcardSets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  FlashcardProvider({
    required this.remoteDatasource,
    required this.aiRemoteDatasource,
  });

  Future<void> loadFlashcardSets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _flashcardSets = await remoteDatasource.getFlashcardSets();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<FlashcardSetModel?> createFlashcardSet(String title, List<Map<String, String>> cards) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newSet = await remoteDatasource.createFlashcardSet(title, cards: cards);
      _flashcardSets.insert(0, newSet);
      return newSet;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteFlashcardSet(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await remoteDatasource.deleteFlashcardSet(id);
      _flashcardSets.removeWhere((element) => element.id == id);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<FlashcardSetModel?> generateFromDocument(String documentId, {String? customTitle}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newSet = await aiRemoteDatasource.generateFlashcardsFromDocument(documentId, customTitle: customTitle);
      _flashcardSets.insert(0, newSet);
      return newSet;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
