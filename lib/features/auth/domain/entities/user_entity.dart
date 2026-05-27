/// Represents the domain-level entity for a user.
class UserEntity {
  /// The unique identifier of the user.
  final String id;
  
  /// The user's chosen username.
  final String username;
  
  /// The user's email address.
  final String email;
  
  /// The user's full name.
  final String fullName;
  
  /// The user's current effective streak count.
  final int streak;
  
  /// The daily target duration for the user, in minutes.
  final int dailyTargetMinutes;
  
  /// The date when the streak was last successfully updated.
  final DateTime? lastStreakDate;
  
  /// The historical records of streak dates.
  final List<String> streakHistory;

  /// Creates a [UserEntity] instance.
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
