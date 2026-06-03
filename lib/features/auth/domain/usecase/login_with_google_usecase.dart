import 'package:studyflow/features/auth/domain/entities/user_entity.dart';
import 'package:studyflow/features/auth/domain/repositories/auth_repository.dart';

/// Use case for authenticating a user with Google.
class LoginWithGoogleUsecase {
  /// The authentication repository.
  final AuthRepository repository;

  /// Creates a [LoginWithGoogleUsecase] instance.
  LoginWithGoogleUsecase(this.repository);

  /// Executes the use case to log in a user with Google.
  /// 
  /// Returns the authenticated [UserEntity], or null if sign-in fails.
  Future<UserEntity?> call() async {
    return await repository.loginWithGoogle();
  }
}
