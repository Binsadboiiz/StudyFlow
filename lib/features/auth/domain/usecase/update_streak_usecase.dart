import 'package:studyflow/features/auth/domain/repositories/auth_repository.dart';

class UpdateStreakUsecase {
  final AuthRepository repository;

  UpdateStreakUsecase(this.repository);

  Future<void> call(int streak, DateTime lastStreakDate, List<String> streakHistory) async {
    return await repository.updateUserStreak(streak, lastStreakDate, streakHistory);
  }
}
