import 'package:studyflow/features/auth/domain/entities/user_entity.dart';

/// Abstract repository defining authentication-related operations.
abstract class AuthRepository {
  /// Registers a new user with the given [user] details and [password].
  Future<void> register(UserEntity user, String password);
  
  /// Logs in a user using their [email] and [password].
  /// 
  /// Note: The identifier is expected to be an email.
  Future<UserEntity?> login(String email, String password);

  /// Checks if a given [username] is already taken.
  /// 
  /// Returns `true` if the username exists, `false` otherwise.
  Future<bool> isUsernameExists(String username);

  /// A stream that emits the current [UserEntity] whenever the authentication state changes.
  Stream<UserEntity?> get authStateChanges;
  
  /// Retrieves the currently authenticated [UserEntity].
  Future<UserEntity?> getCurrentUser();

  /// Updates the user's streak information.
  /// 
  /// [streak] is the new streak count.
  /// [lastStreakDate] is the timestamp of the last streak update.
  /// [streakHistory] is the historical record of streak dates.
  Future<void> updateUserStreak(int streak, DateTime lastStreakDate, List<String> streakHistory);

  /// Logs out the currently authenticated user.
  Future<void> logout();
}