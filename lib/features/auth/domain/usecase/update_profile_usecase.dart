import 'package:studyflow/features/auth/domain/repositories/auth_repository.dart';

/// Use case for updating the user profile.
class UpdateProfileUsecase {
  /// The authentication repository.
  final AuthRepository repository;

  /// Creates an [UpdateProfileUsecase] instance.
  UpdateProfileUsecase(this.repository);

  /// Executes the profile update.
  Future<void> call({
    required String fullName,
    String? photoUrl,
    String? newPassword,
    String? currentPassword,
  }) async {
    await repository.updateProfile(
      fullName: fullName,
      photoUrl: photoUrl,
      newPassword: newPassword,
      currentPassword: currentPassword,
    );
  }
}
