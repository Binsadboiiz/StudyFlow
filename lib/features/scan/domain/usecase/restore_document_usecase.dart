import 'package:studyflow/features/scan/domain/repositories/scan_repository.dart';

class RestoreDocument {
  final ScanRepository repository;

  RestoreDocument(this.repository);

  Future<void> call(String id) async {
    return await repository.restoreDocument(id);
  }
}
