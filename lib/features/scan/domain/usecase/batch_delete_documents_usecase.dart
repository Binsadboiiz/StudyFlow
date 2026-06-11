import 'package:studyflow/features/scan/domain/repositories/scan_repository.dart';

class BatchDeleteDocuments {
  final ScanRepository repository;

  BatchDeleteDocuments(this.repository);

  Future<void> call(List<String> ids) async {
    return await repository.batchDeleteDocuments(ids);
  }
}
