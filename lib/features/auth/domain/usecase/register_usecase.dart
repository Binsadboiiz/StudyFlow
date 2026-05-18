import 'package:studyflow/features/auth/domain/entities/user_entity.dart';
import 'package:studyflow/features/auth/domain/repositories/auth_repository.dart';

class RegisterUsecase { 
  final AuthRepository repository;
  
  RegisterUsecase(this.repository);

  Future<void> call(UserEntity user) async {
    return await repository.Register(user);
  }
}