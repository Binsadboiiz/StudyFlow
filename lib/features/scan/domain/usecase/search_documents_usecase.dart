import 'package:studyflow/features/scan/domain/entities/scanned_document_entity.dart';
import 'package:studyflow/features/scan/domain/repositories/scan_repository.dart';

/// Use case để tìm kiếm tài liệu theo từ khóa.
/// Đóng gói logic tìm kiếm trong tiêu đề và nội dung văn bản.
class SearchDocuments {
  /// Repository xử lý các thao tác dữ liệu cho tài liệu quét.
  final ScanRepository repository;

  /// Tạo use case [SearchDocuments] với [ScanRepository] được cung cấp.
  SearchDocuments(this.repository);

  /// Thực thi use case để tìm kiếm tài liệu chứa [query].
  Future<List<ScannedDocumentEntity>> call(String query) async {
    return await repository.searchDocuments(query);
  }
}
