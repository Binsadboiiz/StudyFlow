import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:studyflow/core/database/isar_service.dart';
import 'package:studyflow/core/services/network_connection_service.dart';
import 'package:studyflow/features/flashcard/data/datasource/flashcard_remote_datasource.dart';
import 'package:studyflow/features/ai_chat/data/datasource/ai_chat_remote_datasource.dart';
import 'package:studyflow/features/flashcard/data/models/flashcard_model.dart';
import 'package:studyflow/features/flashcard/data/models/flashcard_set_isar_model.dart';

class FlashcardProvider with ChangeNotifier {
  final FlashcardRemoteDatasource remoteDatasource;
  final AiChatRemoteDatasource aiRemoteDatasource;
  final NetworkConnectionService connectionService;

  List<FlashcardSetModel> _flashcardSets = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FlashcardSetModel> get flashcardSets => _flashcardSets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  FlashcardProvider({
    required this.remoteDatasource,
    required this.aiRemoteDatasource,
    required this.connectionService,
  }) {
    connectionService.addListener(_onConnectionStatusChanged);
  }

  void _onConnectionStatusChanged() {
    if (connectionService.isOnline) {
      debugPrint('Internet khôi phục, tự động chạy đồng bộ offline flashcards...');
      syncAllPending().then((_) => loadFlashcardSets());
    }
  }

  @override
  void dispose() {
    connectionService.removeListener(_onConnectionStatusChanged);
    super.dispose();
  }

  /// Khôi phục danh sách bộ flashcards từ Isar local database (dữ liệu offline hiển thị tức thời)
  Future<List<FlashcardSetModel>> _getLocalFlashcardSets() async {
    final isar = IsarService.isar;
    final currentUid = remoteDatasource.auth.currentUser?.uid ?? '';
    final localModels = await isar.flashcardSetIsarModels
        .filter()
        .userIdEqualTo(currentUid)
        .not()
        .syncStatusEqualTo('pending_delete')
        .findAll();
    localModels.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return localModels.map((model) => model.toDomain()).toList();
  }

  Future<void> loadFlashcardSets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Luôn hiển thị dữ liệu cục bộ trước để UI phản hồi ngay lập tức
      final localSets = await _getLocalFlashcardSets();
      _flashcardSets = localSets;
      notifyListeners();

      // 2. Nếu online, thực hiện đồng bộ và tải dữ liệu mới
      if (connectionService.isOnline) {
        // Thực hiện đồng bộ các bộ flashcard tạo/xóa offline trước
        await syncAllPending();

        // Tải danh sách mới từ API
        final remoteSets = await remoteDatasource.getFlashcardSets();

        final isar = IsarService.isar;
        await isar.writeTxn(() async {
          final currentUid = remoteDatasource.auth.currentUser?.uid ?? '';
          // Lấy danh sách local UUIDs để tránh xóa nhầm các record đang chờ đồng bộ offline
          final pendingModels = await isar.flashcardSetIsarModels
              .filter()
              .userIdEqualTo(currentUid)
              .and()
              .group((q) => q
                  .syncStatusEqualTo('pending_insert')
                  .or()
                  .syncStatusEqualTo('pending_delete'))
              .findAll();
          final pendingUuids = pendingModels.map((m) => m.uuid).toSet();

          // Xóa các record đã synced cũ không còn nằm trong danh sách pending
          await isar.flashcardSetIsarModels
              .filter()
              .userIdEqualTo(currentUid)
              .syncStatusEqualTo('synced')
              .deleteAll();

          // Ghi đè dữ liệu mới từ Server vào Local Isar dưới dạng 'synced'
          for (final set in remoteSets) {
            if (!pendingUuids.contains(set.id)) {
              final isarModel = FlashcardSetIsarModel.fromDomain(set, userId: currentUid, syncStatus: 'synced');
              await isar.flashcardSetIsarModels.put(isarModel);
            }
          }
        });

        // Load lại kết hợp local + remote synced
        final updatedLocalSets = await _getLocalFlashcardSets();
        _flashcardSets = updatedLocalSets;
      }
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

    // 1. Tạo domain model cục bộ với UUID tạm thời
    final tempId = DateTime.now().microsecondsSinceEpoch.toString();
    final domainCards = cards.map((c) => FlashcardModel(
      id: '${DateTime.now().microsecondsSinceEpoch}_${cards.indexOf(c)}',
      question: c['question'] ?? '',
      answer: c['answer'] ?? '',
      flashcardSetId: tempId,
      createdAt: DateTime.now(),
    )).toList();

    final localSet = FlashcardSetModel(
      id: tempId,
      title: title,
      createdAt: DateTime.now(),
      flashcards: domainCards,
    );

    final isar = IsarService.isar;
    final currentUid = remoteDatasource.auth.currentUser?.uid ?? '';
    final localModel = FlashcardSetIsarModel.fromDomain(localSet, userId: currentUid, syncStatus: 'pending_insert');

    try {
      // 2. Lưu local ngay lập tức
      await isar.writeTxn(() async {
        await isar.flashcardSetIsarModels.put(localModel);
      });

      // Cập nhật state UI nhanh
      final localSets = await _getLocalFlashcardSets();
      _flashcardSets = localSets;
      notifyListeners();

      // 3. Nếu online, cố gắng tạo trên server
      if (connectionService.isOnline) {
        try {
          final newSet = await remoteDatasource.createFlashcardSet(title, cards: cards);
          
          // Xóa bản ghi local tạm thời và ghi đè bản ghi từ server đã synced
          await isar.writeTxn(() async {
            final modelToDelete = await isar.flashcardSetIsarModels.filter().uuidEqualTo(tempId).findFirst();
            if (modelToDelete != null) {
              await isar.flashcardSetIsarModels.delete(modelToDelete.id);
            }
            final syncedModel = FlashcardSetIsarModel.fromDomain(newSet, userId: currentUid, syncStatus: 'synced');
            await isar.flashcardSetIsarModels.put(syncedModel);
          });

          // Cập nhật lại UI state
          final updatedLocalSets = await _getLocalFlashcardSets();
          _flashcardSets = updatedLocalSets;
          return newSet;
        } catch (e) {
          debugPrint('Lỗi thêm flashcard lên server, lưu tạm offline: $e');
        }
      }
      return localSet;
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

    final isar = IsarService.isar;
    try {
      final currentUid = remoteDatasource.auth.currentUser?.uid ?? '';
      final existingModel = await isar.flashcardSetIsarModels.filter().userIdEqualTo(currentUid).uuidEqualTo(id).findFirst();
      if (existingModel == null) return false;

      // 1. Cập nhật local
      if (existingModel.syncStatus == 'pending_insert') {
        // Chưa từng đồng bộ, xóa cứng local luôn
        await isar.writeTxn(() async {
          await isar.flashcardSetIsarModels.delete(existingModel.id);
        });
      } else {
        // Chờ xóa (Soft delete)
        await isar.writeTxn(() async {
          existingModel.syncStatus = 'pending_delete';
          existingModel.updatedAt = DateTime.now();
          await isar.flashcardSetIsarModels.put(existingModel);
        });
      }

      // Cập nhật lại UI state nhanh
      final localSets = await _getLocalFlashcardSets();
      _flashcardSets = localSets;
      notifyListeners();

      // 2. Đồng bộ xóa lên server nếu online
      if (connectionService.isOnline && existingModel.syncStatus != 'pending_insert') {
        try {
          await remoteDatasource.deleteFlashcardSet(id);
          // Xóa cứng local khi server xóa thành công
          await isar.writeTxn(() async {
            await isar.flashcardSetIsarModels.delete(existingModel.id);
          });
        } catch (e) {
          debugPrint('Lỗi xóa flashcard trên server, chờ sync offline: $e');
        }
      }
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
      
      // Lưu local cache
      final isar = IsarService.isar;
      final currentUid = remoteDatasource.auth.currentUser?.uid ?? '';
      await isar.writeTxn(() async {
        final syncedModel = FlashcardSetIsarModel.fromDomain(newSet, userId: currentUid, syncStatus: 'synced');
        await isar.flashcardSetIsarModels.put(syncedModel);
      });

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

  /// Đồng bộ toàn bộ các bộ flashcard đang chờ xử lý offline lên server
  Future<void> syncAllPending() async {
    if (!connectionService.isOnline) return;

    final currentUid = remoteDatasource.auth.currentUser?.uid ?? '';
    if (currentUid.isEmpty) return;

    final isar = IsarService.isar;

    // 1. Đồng bộ lệnh XÓA
    final pendingDeletes = await isar.flashcardSetIsarModels
        .filter()
        .userIdEqualTo(currentUid)
        .syncStatusEqualTo('pending_delete')
        .findAll();

    for (final model in pendingDeletes) {
      try {
        await remoteDatasource.deleteFlashcardSet(model.uuid);
        await isar.writeTxn(() async {
          await isar.flashcardSetIsarModels.delete(model.id);
        });
      } catch (e) {
        debugPrint('Lỗi đồng bộ xóa flashcard ${model.uuid}: $e');
      }
    }

    // 2. Đồng bộ lệnh THÊM
    final pendingInserts = await isar.flashcardSetIsarModels
        .filter()
        .userIdEqualTo(currentUid)
        .syncStatusEqualTo('pending_insert')
        .findAll();

    for (final model in pendingInserts) {
      try {
        final domainSet = model.toDomain();
        final cardsList = domainSet.flashcards.map((c) => {
          'question': c.question,
          'answer': c.answer,
        }).toList();

        final newSet = await remoteDatasource.createFlashcardSet(
          domainSet.title,
          targetDocumentId: domainSet.targetDocumentId,
          cards: cardsList,
        );

        // Cập nhật trạng thái record local: xóa record tạm offline và ghi record đã sync từ server
        await isar.writeTxn(() async {
          await isar.flashcardSetIsarModels.delete(model.id);
          final syncedModel = FlashcardSetIsarModel.fromDomain(newSet, userId: currentUid, syncStatus: 'synced');
          await isar.flashcardSetIsarModels.put(syncedModel);
        });
      } catch (e) {
        debugPrint('Lỗi đồng bộ thêm flashcard ${model.uuid}: $e');
      }
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clear() {
    _flashcardSets = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
