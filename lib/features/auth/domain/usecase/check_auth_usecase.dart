import 'package:studyflow/features/auth/domain/entities/user_entity.dart';
import 'package:studyflow/features/auth/domain/repositories/auth_repository.dart';

/// Use case for checking the current authentication state.
class CheckAuthUsecase {
  /// The authentication repository.
  final AuthRepository repository;

  /// Creates a [CheckAuthUsecase] instance.
  CheckAuthUsecase(this.repository);

  /// Executes the use case to listen for authentication state changes.
  /// 
  /// Returns a stream of [UserEntity] representing the currently logged-in user,
  /// or null if the user is logged out.
  Stream<UserEntity?> call() {
    return repository.authStateChanges;
  }
}