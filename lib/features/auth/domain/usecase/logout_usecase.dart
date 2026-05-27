import 'package:studyflow/features/auth/domain/repositories/auth_repository.dart';

/// Usecase for handling user logout.
class LogoutUsecase {
  /// The authentication repository used to perform logout.
  final AuthRepository repository;

  /// Creates a [LogoutUsecase] with the given [repository].
  LogoutUsecase(this.repository);

  /// Executes the logout operation.
  Future<void> call() async {
    await repository.Logout();
  }
}