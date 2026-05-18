import 'package:studyflow/features/auth/domain/entities/user_entity.dart';
import 'package:studyflow/features/auth/domain/repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<UserEntity?> call(String identifier, String password) async {
    return await repository.Login(identifier, password);
  }
}