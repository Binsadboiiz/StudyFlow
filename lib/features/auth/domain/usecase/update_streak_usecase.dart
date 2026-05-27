import 'package:studyflow/features/auth/domain/repositories/auth_repository.dart';

/// Usecase for updating the user's login streak.
class UpdateStreakUsecase {
  /// The authentication repository.
  final AuthRepository repository;

  /// Creates an [UpdateStreakUsecase] with the given [repository].
  UpdateStreakUsecase(this.repository);

  /// Executes the streak update operation.
  /// 
  /// [streak] is the new streak count.
  /// [lastStreakDate] is the date when the streak was last updated.
  /// [streakHistory] is the history of streak dates.
  Future<void> call(int streak, DateTime lastStreakDate, List<String> streakHistory) async {
    return await repository.updateUserStreak(streak, lastStreakDate, streakHistory);
  }
}
