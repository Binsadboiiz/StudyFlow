import 'dart:convert';
import 'package:isar_community/isar.dart';
import 'package:studyflow/features/flashcard/data/models/flashcard_model.dart';

part 'flashcard_set_isar_model.g.dart';

@collection
class FlashcardSetIsarModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  late String userId;

  late String title;
  
  String? targetDocumentId;

  late DateTime createdAt;

  // JSON string containing the list of flashcards (question, answer, etc.)
  late String flashcardsJson;

  // Trạng thái đồng bộ: 'synced', 'pending_insert', 'pending_delete'
  late String syncStatus;

  // Thời gian cập nhật gần nhất
  late DateTime updatedAt;

  /// Chuyển đổi sang FlashcardSetModel
  FlashcardSetModel toDomain() {
    final List<dynamic> decoded = jsonDecode(flashcardsJson);
    final flashcards = decoded.map((e) => FlashcardModel.fromJson(e as Map<String, dynamic>)).toList();
    return FlashcardSetModel(
      id: uuid,
      title: title,
      targetDocumentId: targetDocumentId,
      createdAt: createdAt,
      flashcards: flashcards,
    );
  }

  /// Khởi tạo Isar model từ FlashcardSetModel
  static FlashcardSetIsarModel fromDomain(FlashcardSetModel model, {required String userId, required String syncStatus, DateTime? updatedAt}) {
    final isarModel = FlashcardSetIsarModel();
    isarModel.uuid = model.id;
    isarModel.userId = userId;
    isarModel.title = model.title;
    isarModel.targetDocumentId = model.targetDocumentId;
    isarModel.createdAt = model.createdAt;
    
    // Convert flashcards list to json
    final cardsList = model.flashcards.map((c) => {
      'id': c.id,
      'question': c.question,
      'answer': c.answer,
      'flashcardSetId': c.flashcardSetId,
      'createdAt': c.createdAt.toIso8601String(),
    }).toList();
    isarModel.flashcardsJson = jsonEncode(cardsList);
    
    isarModel.syncStatus = syncStatus;
    isarModel.updatedAt = updatedAt ?? DateTime.now();
    return isarModel;
  }
}
