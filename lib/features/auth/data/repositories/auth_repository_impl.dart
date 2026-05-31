import 'package:studyflow/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:studyflow/features/auth/data/models/user_model.dart';
import 'package:studyflow/features/auth/domain/entities/user_entity.dart';
import 'package:studyflow/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository] that interacts with [AuthRemoteDatasource]
/// to handle authentication and user-related operations.
class AuthRepositoryImpl implements AuthRepository {
  /// The remote data source for authentication.
  final AuthRemoteDatasource remoteDatasource;

  /// Creates an [AuthRepositoryImpl] instance with the required [remoteDatasource].
  AuthRepositoryImpl(this.remoteDatasource);

  /// Converts a [UserModel] into a [UserEntity] for use in the domain layer.
  UserEntity _toEntity(UserModel userModel) {
    return UserEntity(
      id: userModel.id,
      username: userModel.username,
      email: userModel.email,
      fullName: userModel.fullName,
      photoUrl: userModel.photoUrl,
      level: userModel.level,
      xp: userModel.xp,
      streak: _effectiveStreak(userModel),
      dailyTargetMinutes: userModel.dailyTargetMinutes,
      lastStreakDate: userModel.lastStreakDate,
      streakHistory: userModel.streakHistory,
      createdAt: userModel.createdAt,
      updatedAt: userModel.updatedAt,
    );
  }

  /// Calculates the effective streak of the user based on the current date.
  /// 
  /// If the streak was not updated today or yesterday, it resets to 0.
  int _effectiveStreak(UserModel userModel) {
    final lastStreakDate = userModel.lastStreakDate;
    if (lastStreakDate == null) return 0;

    // Get date-only components to safely compare days without time interference.
    final today = _dateOnly(DateTime.now());
    final lastDay = _dateOnly(lastStreakDate);
    final yesterday = today.subtract(const Duration(days: 1));

    // The streak is valid if it was updated today or yesterday.
    if (lastDay == today || lastDay == yesterday) {
      return userModel.streak;
    }

    // Streak is broken.
    return 0;
  }

  /// Returns a [DateTime] with only the year, month, and day components.
  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  Future<void> register(UserEntity user, String password) async {
    // Check if the username is already taken.
    final usernameExists = await isUsernameExists(user.username);
    if (usernameExists) throw Exception("Username already exists");

    // Register the user with Firebase Authentication.
    final uid = await remoteDatasource.registerWithEmailAndPassword(
      user.email,
      password,
      user.fullName,
      user.username,
    );

    // Create a new UserModel with the generated UID.
    final userModel = UserModel(
      id: uid,
      username: user.username,
      email: user.email,
      fullName: user.fullName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save the new user data to Firestore.
    await remoteDatasource.saveUserToFirestore(userModel);
  }

  @override
  Future<UserEntity?> login(String email, String password) async {
    // Authenticate the user and get their UID.
    final uid = await remoteDatasource.loginWithEmailAndPassword(
      email,
      password,
    );
    if (uid == null) return null;

    // Fetch user details from Firestore.
    final userModel = await remoteDatasource.getUserFromFirestore(uid);
    if (userModel == null) return null;

    return _toEntity(userModel);
  }

  @override
  Future<bool> isUsernameExists(String username) async {
    return await remoteDatasource.isUsernameExists(username);
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    // Listen to changes from the remote datasource and map them to UserEntity.
    return remoteDatasource.userChanges.map((userModel) {
      if (userModel == null) return null;
      return _toEntity(userModel);
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // Get the currently authenticated UID.
    final uid = remoteDatasource.currentUserId;
    if (uid == null) return null;

    // Fetch and return the corresponding user entity.
    final userModel = await remoteDatasource.getUserFromFirestore(uid);
    if (userModel == null) return null;

    return _toEntity(userModel);
  }

  @override
  Future<void> updateUserStreak(int streak, DateTime lastStreakDate, List<String> streakHistory) async {
    final uid = remoteDatasource.currentUserId;
    if (uid == null) return;
    
    // Update the streak fields in Firestore.
    await remoteDatasource.updateUserFields(uid, {
      'streak': streak,
      'lastStreakDate': lastStreakDate.toIso8601String(),
      'streakHistory': streakHistory,
    });
  }

  @override
  Future<void> logout() async {
    // Log out the current user via the remote datasource.
    await remoteDatasource.logout();
  }
}
