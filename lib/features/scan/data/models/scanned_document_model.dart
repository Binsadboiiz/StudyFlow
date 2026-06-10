import 'package:studyflow/features/scan/domain/entities/scanned_document_entity.dart';

/// Model dữ liệu cho tài liệu quét, extends từ [ScannedDocumentEntity].
/// Chịu trách nhiệm chuyển đổi giữa JSON (từ .NET API) và Entity.
class ScannedDocumentModel extends ScannedDocumentEntity {
  const ScannedDocumentModel({
    required super.id,
    required super.title,
    required super.extractedText,
    super.originalImageUrl,
    super.storagePath,
    super.imageSizeBytes,
    super.textSizeBytes,
    super.detectedLanguage,
    super.confidenceScore,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Factory constructor tạo [ScannedDocumentModel] từ JSON (trả về từ .NET API).
  factory ScannedDocumentModel.fromJson(Map<String, dynamic> json) {
    return ScannedDocumentModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      extractedText: json['extractedText'] ?? '',
      originalImageUrl: json['originalImageUrl'],
      storagePath: json['storagePath'],
      imageSizeBytes: json['imageSizeBytes'] ?? 0,
      textSizeBytes: json['textSizeBytes'] ?? 0,
      detectedLanguage: json['detectedLanguage'] ?? 'vi',
      confidenceScore: (json['confidenceScore'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Chuyển đổi sang JSON (dùng cho request POST/PUT đến .NET API).
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'extractedText': extractedText,
      'originalImageUrl': originalImageUrl,
      'storagePath': storagePath,
      'imageSizeBytes': imageSizeBytes,
      'textSizeBytes': textSizeBytes,
      'detectedLanguage': detectedLanguage,
      'confidenceScore': confidenceScore,
    };
  }

  /// Tạo [ScannedDocumentModel] từ [ScannedDocumentEntity].
  factory ScannedDocumentModel.fromEntity(ScannedDocumentEntity entity) {
    return ScannedDocumentModel(
      id: entity.id,
      title: entity.title,
      extractedText: entity.extractedText,
      originalImageUrl: entity.originalImageUrl,
      storagePath: entity.storagePath,
      imageSizeBytes: entity.imageSizeBytes,
      textSizeBytes: entity.textSizeBytes,
      detectedLanguage: entity.detectedLanguage,
      confidenceScore: entity.confidenceScore,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
