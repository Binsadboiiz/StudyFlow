import 'package:studyflow/features/scan/domain/entities/scanned_document_entity.dart';
import 'package:studyflow/features/scan/domain/entities/storage_usage_entity.dart';

/// Interface định nghĩa các thao tác truy xuất/lưu trữ dữ liệu liên quan đến tài liệu quét.
/// Tầng Domain chỉ định nghĩa interface này mà không cần biết dữ liệu đến từ đâu (API hay Local DB).
/// Điều này giúp tách biệt logic ứng dụng khỏi công nghệ database bên dưới.
abstract class ScanRepository {
  /// Lấy danh sách tất cả tài liệu đã quét của người dùng.
  Future<List<ScannedDocumentEntity>> getDocuments();

  /// Tạo một tài liệu quét mới với đầy đủ thông tin.
  Future<ScannedDocumentEntity> createDocument({
    required String title,
    required String extractedText,
    String? imageBase64,
    required int imageSizeBytes,
    required int textSizeBytes,
    required String detectedLanguage,
    required double confidenceScore,
  });

  /// Xóa một tài liệu theo ID.
  Future<void> deleteDocument(String id);

  /// Lấy thông tin chi tiết một tài liệu theo ID.
  Future<ScannedDocumentEntity?> getDocumentById(String id);

  /// Cập nhật thông tin tài liệu (tiêu đề, nội dung văn bản).
  Future<void> updateDocument(String id, {String? title, String? extractedText});

  /// Tìm kiếm tài liệu theo từ khóa trong tiêu đề hoặc nội dung.
  Future<List<ScannedDocumentEntity>> searchDocuments(String query);

  /// Lấy thông tin sử dụng dung lượng lưu trữ.
  Future<StorageUsageEntity> getStorageUsage();

  /// Lấy danh sách tài liệu trong thùng rác.
  Future<List<ScannedDocumentEntity>> getTrashDocuments();

  /// Phục hồi tài liệu từ thùng rác.
  Future<void> restoreDocument(String id);

  /// Xóa vĩnh viễn tài liệu.
  Future<void> hardDeleteDocument(String id);

  /// Xóa hàng loạt tài liệu.
  Future<void> batchDeleteDocuments(List<String> ids);
}
