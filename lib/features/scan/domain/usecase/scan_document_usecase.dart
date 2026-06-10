import 'package:studyflow/features/scan/domain/entities/scanned_document_entity.dart';
import 'package:studyflow/features/scan/domain/repositories/scan_repository.dart';

/// Use case để tạo (lưu) một tài liệu quét mới vào hệ thống.
/// Đóng gói logic cần thiết để xử lý và lưu trữ kết quả OCR.
class ScanDocument {
  /// Repository xử lý các thao tác dữ liệu cho tài liệu quét.
  final ScanRepository repository;

  /// Tạo use case [ScanDocument] với [ScanRepository] được cung cấp.
  ScanDocument(this.repository);

  /// Thực thi use case để tạo tài liệu mới với các thông tin được cung cấp.
  Future<ScannedDocumentEntity> call({
    required String title,
    required String extractedText,
    String? originalImageUrl,
    String? storagePath,
    required int imageSizeBytes,
    required int textSizeBytes,
    required String detectedLanguage,
    required double confidenceScore,
  }) async {
    return await repository.createDocument(
      title: title,
      extractedText: extractedText,
      originalImageUrl: originalImageUrl,
      storagePath: storagePath,
      imageSizeBytes: imageSizeBytes,
      textSizeBytes: textSizeBytes,
      detectedLanguage: detectedLanguage,
      confidenceScore: confidenceScore,
    );
  }
}
