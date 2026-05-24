import 'package:studyflow/features/auth/domain/entities/user_entity.dart';
import 'package:studyflow/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthUsecase {
  final AuthRepository repository;

  CheckAuthUsecase(this.repository);

  Stream<UserEntity?> call() {
    return repository.authStateChanges;
  }
}