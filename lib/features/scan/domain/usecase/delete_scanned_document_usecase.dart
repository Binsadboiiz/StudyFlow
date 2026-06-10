import 'package:studyflow/features/scan/domain/repositories/scan_repository.dart';

/// Use case để xóa một tài liệu quét khỏi hệ thống.
/// Đóng gói logic cần thiết để xóa tài liệu đã tồn tại.
class DeleteScannedDocument {
  /// Repository xử lý các thao tác dữ liệu cho tài liệu quét.
  final ScanRepository repository;

  /// Tạo use case [DeleteScannedDocument] với [ScanRepository] được cung cấp.
  DeleteScannedDocument(this.repository);

  /// Thực thi use case để xóa tài liệu có [id] tương ứng.
  Future<void> call(String id) async {
    await repository.deleteDocument(id);
  }
}
