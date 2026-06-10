import 'package:studyflow/features/scan/domain/entities/storage_usage_entity.dart';
import 'package:studyflow/features/scan/domain/repositories/scan_repository.dart';

/// Use case để lấy thông tin sử dụng dung lượng lưu trữ.
/// Đóng gói logic truy vấn dung lượng đã dùng và quota.
class GetStorageUsage {
  /// Repository xử lý các thao tác dữ liệu cho tài liệu quét.
  final ScanRepository repository;

  /// Tạo use case [GetStorageUsage] với [ScanRepository] được cung cấp.
  GetStorageUsage(this.repository);

  /// Thực thi use case để lấy thông tin dung lượng lưu trữ.
  Future<StorageUsageEntity> call() async {
    return await repository.getStorageUsage();
  }
}
