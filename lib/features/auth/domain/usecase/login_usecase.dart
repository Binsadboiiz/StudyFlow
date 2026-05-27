import 'package:studyflow/features/auth/domain/entities/user_entity.dart';
import 'package:studyflow/features/auth/domain/repositories/auth_repository.dart';

/// Use case for authenticating a user.
class LoginUsecase {
  /// The authentication repository.
  final AuthRepository repository;

  /// Creates a [LoginUsecase] instance.
  LoginUsecase(this.repository);

  /// Executes the use case to log in a user with the provided [email] and [password].
  /// 
  /// Returns the authenticated [UserEntity], or null if login fails.
  Future<UserEntity?> call(String email, String password) async {
    return await repository.Login(email, password);
  }
}