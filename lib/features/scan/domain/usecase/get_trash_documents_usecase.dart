import 'package:studyflow/features/scan/domain/entities/scanned_document_entity.dart';
import 'package:studyflow/features/scan/domain/repositories/scan_repository.dart';

class GetTrashDocuments {
  final ScanRepository repository;

  GetTrashDocuments(this.repository);

  Future<List<ScannedDocumentEntity>> call() async {
    return await repository.getTrashDocuments();
  }
}
