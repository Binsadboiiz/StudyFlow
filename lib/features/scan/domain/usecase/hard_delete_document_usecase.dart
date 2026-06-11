import 'package:studyflow/features/scan/domain/repositories/scan_repository.dart';

class HardDeleteDocument {
  final ScanRepository repository;

  HardDeleteDocument(this.repository);

  Future<void> call(String id) async {
    return await repository.hardDeleteDocument(id);
  }
}
