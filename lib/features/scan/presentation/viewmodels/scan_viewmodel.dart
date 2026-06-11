import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

/// ViewModel quản lý trạng thái và logic nghiệp vụ cho tính năng quét tài liệu OCR.
/// Sử dụng Clean Architecture use cases để tương tác với repository.
class ScanViewModel extends ChangeNotifier with SafeChangeNotifier {
  /// Use case lấy danh sách tài liệu đã quét.
  final GetScannedDocuments getDocumentsUseCase;

  /// Use case tạo (lưu) tài liệu quét mới.
  final ScanDocument scanDocumentUseCase;

  /// Use case xóa tài liệu.
  final DeleteScannedDocument deleteDocumentUseCase;

  /// Use case lấy thông tin dung lượng lưu trữ.
  final GetStorageUsage getStorageUsageUseCase;

  /// Use case tìm kiếm tài liệu.
  final SearchDocuments searchDocumentsUseCase;

  // ============ Trạng thái nội bộ ============

  /// Danh sách tài liệu đã quét.
  List<ScannedDocumentEntity> _documents = [];
  List<ScannedDocumentEntity> get documents => _documents;

  /// Thông tin dung lượng lưu trữ.
  StorageUsageEntity? _storageUsage;
  StorageUsageEntity? get storageUsage => _storageUsage;

  /// Cờ đang tải danh sách tài liệu.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Cờ đang xử lý OCR (nhận diện chữ).
  bool _isProcessingOcr = false;
  bool get isProcessingOcr => _isProcessingOcr;

  /// Cờ đang lưu tài liệu (upload + gọi API).
  bool _isSaving = false;
  bool get isSaving => _isSaving;

  /// Thông báo lỗi (null nếu không có lỗi).
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Cờ đang ở chế độ tìm kiếm.
  bool _isSearching = false;
  bool get isSearching => _isSearching;

  /// Constructor khởi tạo ViewModel với các use cases và tải dữ liệu ban đầu.
  ScanViewModel({
    required this.getDocumentsUseCase,
    required this.scanDocumentUseCase,
    required this.deleteDocumentUseCase,
    required this.getStorageUsageUseCase,
    required this.searchDocumentsUseCase,
  }) {
    loadDocuments();
  }

  /// Tải danh sách tài liệu từ server.
  Future<void> loadDocuments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListenersSafely();

    try {
      _documents = await getDocumentsUseCase();
      await refreshStorageUsage();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      debugPrint('Load documents error: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListenersSafely();
    }
  }

  /// Xử lý OCR trên file ảnh: nén ảnh → nhận diện chữ → trả về kết quả.
  /// Trả về Map chứa: text, confidenceScore, detectedLanguage, compressedBytes, compressedImageBytes.
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

  /// Lưu tài liệu: upload ảnh lên Firebase Storage → gọi API backend.
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
      // Bước 1: Upload ảnh lên Firebase Storage
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'scanned-documents/$userId/$timestamp.jpg';

      final storageRef = FirebaseStorage.instance.ref().child(storagePath);
      final uploadTask = await storageRef.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Bước 2: Lấy download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Bước 3: Tính kích thước văn bản
      final textSizeBytes = extractedText.length * 2; // UTF-16 ước tính

      // Bước 4: Gửi thông tin lên backend API
      final document = await scanDocumentUseCase(
        title: title,
        extractedText: extractedText,
        originalImageUrl: downloadUrl,
        storagePath: storagePath,
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

  /// Xóa tài liệu theo ID.
  Future<bool> deleteDocument(String id) async {
    try {
      _errorMessage = null;

      // Tìm tài liệu để xóa ảnh trên Storage (nếu có)
      final doc = _documents.firstWhere(
        (d) => d.id == id,
        orElse: () => ScannedDocumentEntity(
          id: '', title: '', extractedText: '',
          createdAt: DateTime.now(), updatedAt: DateTime.now(),
        ),
      );

      // Xóa ảnh trên Firebase Storage nếu có storagePath
      if (doc.storagePath != null && doc.storagePath!.isNotEmpty) {
        try {
          await FirebaseStorage.instance.ref().child(doc.storagePath!).delete();
        } catch (e) {
          debugPrint('Cảnh báo: Không thể xóa ảnh trên Storage: $e');
        }
      }

      // Xóa trên backend
      await deleteDocumentUseCase(id);

      // Cập nhật danh sách local
      _documents.removeWhere((d) => d.id == id);
      notifyListenersSafely();

      // Làm mới dung lượng
      await refreshStorageUsage();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi xóa tài liệu: $e';
      debugPrint(_errorMessage);
      notifyListenersSafely();
      return false;
    }
  }

  /// Tìm kiếm tài liệu theo từ khóa.
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
      _documents = await searchDocumentsUseCase(query);
    } catch (e) {
      _errorMessage = 'Lỗi tìm kiếm: $e';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListenersSafely();
    }
  }

  /// Thoát chế độ tìm kiếm và tải lại danh sách gốc.
  Future<void> clearSearch() async {
    _isSearching = false;
    await loadDocuments();
  }

  /// Làm mới thông tin dung lượng lưu trữ.
  Future<void> refreshStorageUsage() async {
    try {
      _storageUsage = await getStorageUsageUseCase();
    } catch (e) {
      debugPrint('Không thể tải thông tin dung lượng: $e');
    }
  }

  /// Xóa thông báo lỗi.
  void clearError() {
    _errorMessage = null;
    notifyListenersSafely();
  }

  /// Phát hiện ngôn ngữ đơn giản dựa trên ký tự Unicode.
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
}
