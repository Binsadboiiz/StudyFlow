import 'package:studyflow/features/scan/data/datasource/scan_remote_datasource.dart';

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
    String? imageBase64,
    required int imageSizeBytes,
    required int textSizeBytes,
    required String detectedLanguage,
    required double confidenceScore,
  }) async {
    // Tạo data để gửi JSON lên API
    final data = <String, dynamic>{
      'title': title,
      'extractedText': extractedText,
      'imageBase64': imageBase64,
      'imageSizeBytes': imageSizeBytes,
      'textSizeBytes': textSizeBytes,
      'detectedLanguage': detectedLanguage,
      'confidenceScore': confidenceScore,
    };

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

  @override
  Future<List<ScannedDocumentEntity>> getTrashDocuments() async {
    return await remoteDatasource.getTrashDocuments();
  }

  @override
  Future<void> restoreDocument(String id) async {
    await remoteDatasource.restoreDocument(id);
  }

  @override
  Future<void> hardDeleteDocument(String id) async {
    await remoteDatasource.hardDeleteDocument(id);
  }

  @override
  Future<void> batchDeleteDocuments(List<String> ids) async {
    await remoteDatasource.batchDeleteDocuments(ids);
  }
}
