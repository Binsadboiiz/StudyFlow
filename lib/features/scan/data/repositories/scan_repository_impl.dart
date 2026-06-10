import 'package:studyflow/features/scan/data/datasource/scan_remote_datasource.dart';
import 'package:studyflow/features/scan/data/models/scanned_document_model.dart';
import 'package:studyflow/features/scan/domain/entities/scanned_document_entity.dart';
import 'package:studyflow/features/scan/domain/entities/storage_usage_entity.dart';
import 'package:studyflow/features/scan/domain/repositories/scan_repository.dart';

/// Triển khai cụ thể của [ScanRepository] sử dụng .NET API.
/// Chuyển tiếp các thao tác xuống [ScanRemoteDatasource].
class ScanRepositoryImpl implements ScanRepository {
  final ScanRemoteDatasource remoteDatasource;

  ScanRepositoryImpl(this.remoteDatasource);

  @override
  Future<List<ScannedDocumentEntity>> getDocuments() async {
    return await remoteDatasource.getDocuments();
  }

  @override
  Future<ScannedDocumentEntity> createDocument({
    required String title,
    required String extractedText,
    String? originalImageUrl,
    String? storagePath,
    required int imageSizeBytes,
    required int textSizeBytes,
    required String detectedLanguage,
    required double confidenceScore,
  }) async {
    // Tạo model để gửi JSON lên API
    final data = ScannedDocumentModel(
      id: '', // ID sẽ được API tự động tạo
      title: title,
      extractedText: extractedText,
      originalImageUrl: originalImageUrl,
      storagePath: storagePath,
      imageSizeBytes: imageSizeBytes,
      textSizeBytes: textSizeBytes,
      detectedLanguage: detectedLanguage,
      confidenceScore: confidenceScore,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ).toJson();

    return await remoteDatasource.createDocument(data);
  }

  @override
  Future<void> deleteDocument(String id) async {
    await remoteDatasource.deleteDocument(id);
  }

  @override
  Future<ScannedDocumentEntity?> getDocumentById(String id) async {
    return await remoteDatasource.getDocumentById(id);
  }

  @override
  Future<void> updateDocument(String id, {String? title, String? extractedText}) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (extractedText != null) data['extractedText'] = extractedText;
    await remoteDatasource.updateDocument(id, data);
  }

  @override
  Future<List<ScannedDocumentEntity>> searchDocuments(String query) async {
    return await remoteDatasource.searchDocuments(query);
  }

  @override
  Future<StorageUsageEntity> getStorageUsage() async {
    return await remoteDatasource.getStorageUsage();
  }
}
