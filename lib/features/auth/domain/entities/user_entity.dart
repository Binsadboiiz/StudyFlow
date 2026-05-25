class UserEntity {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final int streak;
  final int dailyTargetMinutes;
  final DateTime? lastStreakDate;
  final List<String> streakHistory;

  UserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.streak = 0,
    this.dailyTargetMinutes = 120,
    this.lastStreakDate,
    this.streakHistory = const [],
  });
}
