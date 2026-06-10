import 'package:studyflow/features/scan/domain/entities/scanned_document_entity.dart';
import 'package:studyflow/features/scan/domain/repositories/scan_repository.dart';

/// Use case để lấy danh sách tài liệu đã quét từ hệ thống.
/// Đóng gói logic cần thiết để truy xuất tất cả tài liệu.
class GetScannedDocuments {
  /// Repository xử lý các thao tác dữ liệu cho tài liệu quét.
  final ScanRepository repository;

  /// Tạo use case [GetScannedDocuments] với [ScanRepository] được cung cấp.
  GetScannedDocuments(this.repository);

  /// Thực thi use case để lấy danh sách tài liệu.
  Future<List<ScannedDocumentEntity>> call() async {
    return await repository.getDocuments();
  }
}
