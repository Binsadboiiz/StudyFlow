import 'package:studyflow/features/scan/domain/entities/storage_usage_entity.dart';

/// Model dữ liệu cho thông tin sử dụng dung lượng, extends từ [StorageUsageEntity].
/// Chịu trách nhiệm chuyển đổi giữa JSON (từ .NET API) và Entity.
class StorageUsageModel extends StorageUsageEntity {
  const StorageUsageModel({
    required super.usedBytes,
    required super.quotaBytes,
    required super.usedPercentage,
    required super.documentCount,
  });

  /// Factory constructor tạo [StorageUsageModel] từ JSON (trả về từ .NET API).
  factory StorageUsageModel.fromJson(Map<String, dynamic> json) {
    return StorageUsageModel(
      usedBytes: json['usedBytes'] ?? 0,
      quotaBytes: json['quotaBytes'] ?? 0,
      usedPercentage: (json['usedPercentage'] ?? 0.0).toDouble(),
      documentCount: json['documentCount'] ?? 0,
    );
  }

  /// Chuyển đổi sang JSON.
  Map<String, dynamic> toJson() {
    return {
      'usedBytes': usedBytes,
      'quotaBytes': quotaBytes,
      'usedPercentage': usedPercentage,
      'documentCount': documentCount,
    };
  }
}
