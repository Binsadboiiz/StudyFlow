import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:studyflow/core/utils/safe_change_notifier.dart';
import 'package:studyflow/features/scan/domain/entities/scanned_document_entity.dart';
import 'package:studyflow/features/scan/domain/entities/storage_usage_entity.dart';
import 'package:studyflow/features/scan/domain/usecase/get_scanned_documents_usecase.dart';
import 'package:studyflow/features/scan/domain/usecase/scan_document_usecase.dart';
import 'package:studyflow/features/scan/domain/usecase/delete_scanned_document_usecase.dart';
import 'package:studyflow/features/scan/domain/usecase/get_storage_usage_usecase.dart';
import 'package:studyflow/features/scan/domain/usecase/search_documents_usecase.dart';

import 'package:studyflow/features/scan/domain/usecase/get_trash_documents_usecase.dart';
import 'package:studyflow/features/scan/domain/usecase/restore_document_usecase.dart';
import 'package:studyflow/features/scan/domain/usecase/hard_delete_document_usecase.dart';
import 'package:studyflow/features/scan/domain/usecase/batch_delete_documents_usecase.dart';

/// ViewModel managing state and business logic for the OCR scanning feature.
/// Uses Clean Architecture use cases to interact with the repository.
class ScanViewModel extends ChangeNotifier with SafeChangeNotifier {
  /// Use case to fetch scanned documents.
  final GetScannedDocuments getDocumentsUseCase;

  /// Use case to create (save) a new scanned document.
  final ScanDocument scanDocumentUseCase;

  /// Use case to delete (soft delete) a document.
  final DeleteScannedDocument deleteDocumentUseCase;

  /// Use case to fetch storage usage info.
  final GetStorageUsage getStorageUsageUseCase;

  /// Use case to search documents.
  final SearchDocuments searchDocumentsUseCase;

  /// Use case to fetch trash documents.
  final GetTrashDocuments getTrashDocumentsUseCase;

  /// Use case to restore document from trash.
  final RestoreDocument restoreDocumentUseCase;

  /// Use case to permanently delete document.
  final HardDeleteDocument hardDeleteDocumentUseCase;

  /// Use case to batch delete documents.
  final BatchDeleteDocuments batchDeleteDocumentsUseCase;

  // ============ Internal State ============

  /// List of all fetched scanned documents.
  List<ScannedDocumentEntity> _allDocuments = [];

  /// List of currently displayed scanned documents (after filtering).
  List<ScannedDocumentEntity> _documents = [];
  List<ScannedDocumentEntity> get documents => _documents;

  /// List of documents in trash.
  List<ScannedDocumentEntity> _trashDocuments = [];
  List<ScannedDocumentEntity> get trashDocuments => _trashDocuments;

  /// Storage usage info.
  StorageUsageEntity? _storageUsage;
  StorageUsageEntity? get storageUsage => _storageUsage;

  /// Loading state for documents list.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Processing state for OCR recognition.
  bool _isProcessingOcr = false;
  bool get isProcessingOcr => _isProcessingOcr;

  /// Saving state (upload + API call).
  bool _isSaving = false;
  bool get isSaving => _isSaving;

  /// Error message (null if no error).
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Searching mode flag.
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  /// Selection mode for batch actions.
  bool _isSelectionMode = false;
  bool get isSelectionMode => _isSelectionMode;

  /// Set of selected document IDs.
  Set<String> _selectedIds = {};
  Set<String> get selectedIds => _selectedIds;

  /// Current filter for days ago (null = All Time).
  int? _currentFilterDays;
  int? get currentFilterDays => _currentFilterDays;

  /// Constructor initializing ViewModel with use cases and initial data load.
  ScanViewModel({
    required this.getDocumentsUseCase,
    required this.scanDocumentUseCase,
    required this.deleteDocumentUseCase,
    required this.getStorageUsageUseCase,
    required this.searchDocumentsUseCase,
    required this.getTrashDocumentsUseCase,
    required this.restoreDocumentUseCase,
    required this.hardDeleteDocumentUseCase,
    required this.batchDeleteDocumentsUseCase,
  }) {
    loadDocuments();
  }

  /// Load documents list from server.
  Future<void> loadDocuments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListenersSafely();

    try {
      _allDocuments = await getDocumentsUseCase();
      _applyFilter();
      await refreshStorageUsage();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Load documents error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListenersSafely();
    }
  }

  /// Process OCR on image file: compress -> recognize text -> return result.
  /// Returns Map containing: text, confidenceScore, detectedLanguage, compressedBytes, compressedImageBytes.
  Future<Map<String, dynamic>?> processOcr(File imageFile) async {
    _isProcessingOcr = true;
    _errorMessage = null;
    notifyListenersSafely();

    try {
      // Bước 1: Nén ảnh trước khi xử lý (JPEG quality 70%, max 2048px)
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: 2048,
        minHeight: 2048,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null) {
        throw Exception('Không thể nén ảnh');
      }

      // Bước 2: Lưu ảnh nén tạm để chạy OCR
      final tempDir = await Directory.systemTemp.createTemp('ocr_');
      final tempFile = File('${tempDir.path}/compressed.jpg');
      await tempFile.writeAsBytes(compressedBytes);

      // Bước 3: Nhận diện chữ trên thiết bị bằng Google ML Kit
      final inputImage = InputImage.fromFile(tempFile);
      final textRecognizer = TextRecognizer();
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Tính điểm tin cậy trung bình từ các block
      double totalConfidence = 0;
      int blockCount = 0;
      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          if (line.confidence != null) {
            totalConfidence += line.confidence!;
            blockCount++;
          }
        }
      }
      final avgConfidence = blockCount > 0 ? totalConfidence / blockCount : 0.0;

      // Phát hiện ngôn ngữ đơn giản dựa vào ký tự
      final detectedLang = _detectLanguage(recognizedText.text);

      // Dọn dẹp tài nguyên
      await textRecognizer.close();

      return {
        'text': recognizedText.text,
        'confidenceScore': avgConfidence,
        'detectedLanguage': detectedLang,
        'compressedSizeBytes': compressedBytes.length,
        'compressedImageBytes': compressedBytes,
      };
    } catch (e) {
      _errorMessage = 'Lỗi xử lý OCR: $e';
      debugPrint(_errorMessage);
      return null;
    } finally {
      _isProcessingOcr = false;
      notifyListenersSafely();
    }
  }

  /// Save document: upload image to Firebase Storage -> call backend API.
  Future<ScannedDocumentEntity?> saveDocument({
    required String title,
    required String extractedText,
    required Uint8List imageBytes,
    required int imageSizeBytes,
    required String detectedLanguage,
    required double confidenceScore,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListenersSafely();

    try {
      // Bước 1: Chuyển đổi ảnh sang Base64
      final imageBase64 = base64Encode(imageBytes);

      // Bước 2: Tính kích thước văn bản
      final textSizeBytes = extractedText.length * 2; // UTF-16 ước tính

      // Bước 3: Gửi thông tin lên backend API
      final document = await scanDocumentUseCase(
        title: title,
        extractedText: extractedText,
        imageBase64: imageBase64,
        imageSizeBytes: imageSizeBytes,
        textSizeBytes: textSizeBytes,
        detectedLanguage: detectedLanguage,
        confidenceScore: confidenceScore,
      );

      // Bước 5: Cập nhật danh sách local
      await loadDocuments();

      return document;
    } catch (e) {
      _errorMessage = 'Lỗi lưu tài liệu: $e';
      debugPrint(_errorMessage);
      return null;
    } finally {
      _isSaving = false;
      notifyListenersSafely();
    }
  }

  /// Delete document by ID (Soft delete).
  Future<bool> deleteDocument(String id) async {
    try {
      _errorMessage = null;

      // Soft delete on backend
      await deleteDocumentUseCase(id);

      // Update local lists
      _allDocuments.removeWhere((d) => d.id == id);
      _applyFilter();
      
      // If in selection mode, remove from selection
      if (_selectedIds.contains(id)) {
        toggleSelection(id);
      }

      notifyListenersSafely();

      return true;
    } catch (e) {
      _errorMessage = 'Delete error: $e';
      debugPrint(_errorMessage);
      notifyListenersSafely();
      return false;
    }
  }

  /// Load trash documents from server.
  Future<void> loadTrashDocuments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListenersSafely();

    try {
      _trashDocuments = await getTrashDocumentsUseCase();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Load trash error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListenersSafely();
    }
  }

  /// Restore document from trash.
  Future<bool> restoreDocument(String id) async {
    try {
      _errorMessage = null;
      await restoreDocumentUseCase(id);
      
      _trashDocuments.removeWhere((d) => d.id == id);
      notifyListenersSafely();
      
      // Background reload active documents
      loadDocuments();
      return true;
    } catch (e) {
      _errorMessage = 'Restore error: $e';
      debugPrint(_errorMessage);
      notifyListenersSafely();
      return false;
    }
  }

  /// Hard delete document permanently.
  Future<bool> hardDeleteDocument(String id) async {
    try {
      _errorMessage = null;
      await hardDeleteDocumentUseCase(id);
      
      _trashDocuments.removeWhere((d) => d.id == id);
      notifyListenersSafely();
      
      await refreshStorageUsage();
      return true;
    } catch (e) {
      _errorMessage = 'Hard delete error: $e';
      debugPrint(_errorMessage);
      notifyListenersSafely();
      return false;
    }
  }

  /// Batch delete selected documents.
  Future<bool> batchDeleteSelected() async {
    if (_selectedIds.isEmpty) return false;
    
    try {
      _errorMessage = null;
      final idsList = _selectedIds.toList();
      await batchDeleteDocumentsUseCase(idsList);
      
      _allDocuments.removeWhere((d) => _selectedIds.contains(d.id));
      _applyFilter();
      clearSelection();
      notifyListenersSafely();
      
      return true;
    } catch (e) {
      _errorMessage = 'Batch delete error: $e';
      debugPrint(_errorMessage);
      notifyListenersSafely();
      return false;
    }
  }

  /// Search documents by keyword.
  Future<void> searchDocuments(String query) async {
    if (query.trim().isEmpty) {
      _isSearching = false;
      await loadDocuments();
      return;
    }

    _isSearching = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListenersSafely();

    try {
      _allDocuments = await searchDocumentsUseCase(query);
      _applyFilter();
    } catch (e) {
      _errorMessage = 'Lỗi tìm kiếm: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListenersSafely();
    }
  }

  /// Exit search mode and reload original list.
  Future<void> clearSearch() async {
    _isSearching = false;
    await loadDocuments();
  }

  /// Toggle selection mode.
  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedIds.clear();
    }
    notifyListenersSafely();
  }

  /// Toggle selection for a specific document.
  void toggleSelection(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    
    // Auto exit selection mode if no items left
    if (_selectedIds.isEmpty && _isSelectionMode) {
      _isSelectionMode = false;
    }
    notifyListenersSafely();
  }

  /// Clear all selections and exit selection mode.
  void clearSelection() {
    _selectedIds.clear();
    _isSelectionMode = false;
    notifyListenersSafely();
  }

  /// Select all documents.
  void selectAll() {
    _selectedIds = _documents.map((d) => d.id).toSet();
    notifyListenersSafely();
  }

  /// Filter documents locally by date.
  void filterDocuments({int? daysAgo}) {
    _currentFilterDays = daysAgo;
    _applyFilter();
    notifyListenersSafely();
  }

  /// Apply current filter to _allDocuments and update _documents.
  void _applyFilter() {
    if (_currentFilterDays == null) {
      _documents = List.from(_allDocuments);
    } else {
      final cutoffDate = DateTime.now().subtract(Duration(days: _currentFilterDays!));
      _documents = _allDocuments.where((doc) => doc.createdAt.isAfter(cutoffDate)).toList();
    }
  }

  /// Refresh storage usage info.
  Future<void> refreshStorageUsage() async {
    try {
      _storageUsage = await getStorageUsageUseCase();
    } catch (e) {
      debugPrint('Không thể tải thông tin dung lượng: $e');
    }
  }

  /// Clear error message.
  void clearError() {
    _errorMessage = null;
    notifyListenersSafely();
  }

  /// Simple language detection based on Unicode characters.
  String _detectLanguage(String text) {
    if (text.isEmpty) return 'unknown';

    // Đếm ký tự tiếng Việt (có dấu)
    final vietnameseChars = RegExp(r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]', caseSensitive: false);
    final vnCount = vietnameseChars.allMatches(text).length;

    if (vnCount > text.length * 0.02) return 'vi';

    // Kiểm tra ký tự CJK (Trung, Nhật, Hàn)
    final cjkChars = RegExp(r'[\u4e00-\u9fff\u3040-\u309f\u30a0-\u30ff\uac00-\ud7af]');
    final cjkCount = cjkChars.allMatches(text).length;
    if (cjkCount > text.length * 0.1) return 'zh';

    return 'en';
  }

  /// Clears in-memory scanned document data upon logout
  void clear() {
    _allDocuments = [];
    _documents = [];
    _trashDocuments = [];
    _storageUsage = null;
    _isLoading = false;
    _isProcessingOcr = false;
    _isSaving = false;
    _errorMessage = null;
    _isSearching = false;
    _isSelectionMode = false;
    _selectedIds = {};
    _currentFilterDays = null;
    notifyListenersSafely();
  }
}
