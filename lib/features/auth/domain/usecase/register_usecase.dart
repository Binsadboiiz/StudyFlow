import 'package:studyflow/features/auth/domain/entities/user_entity.dart';
import 'package:studyflow/features/auth/domain/repositories/auth_repository.dart';

/// Usecase for handling user registration.
class RegisterUsecase { 
  /// The authentication repository used for registration.
  final AuthRepository repository;
  
  /// Creates a [RegisterUsecase] with the given [repository].
  RegisterUsecase(this.repository);

  /// Executes the registration operation for a [user] with the provided [password].
  Future<void> call(UserEntity user, String password) async {
    return await repository.Register(user, password);
  }
}