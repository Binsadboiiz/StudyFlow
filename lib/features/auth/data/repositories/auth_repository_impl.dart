import 'package:studyflow/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:studyflow/features/auth/data/models/user_model.dart';
import 'package:studyflow/features/auth/domain/entities/user_entity.dart';
import 'package:studyflow/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl(this.remoteDatasource);

  UserEntity _toEntity(UserModel userModel) {
    return UserEntity(
      id: userModel.id,
      username: userModel.username,
      email: userModel.email,
      fullName: userModel.fullName,
      streak: _effectiveStreak(userModel),
      dailyTargetMinutes: userModel.dailyTargetMinutes,
      lastStreakDate: userModel.lastStreakDate,
    );
  }

  int _effectiveStreak(UserModel userModel) {
    final lastStreakDate = userModel.lastStreakDate;
    if (lastStreakDate == null) return 0;

    final today = _dateOnly(DateTime.now());
    final lastDay = _dateOnly(lastStreakDate);
    final yesterday = today.subtract(const Duration(days: 1));

    if (lastDay == today || lastDay == yesterday) {
      return userModel.streak;
    }

    return 0;
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  @override
  Future<void> Register(UserEntity user, String password) async {
    final usernameExists = await isUsernameExists(user.username);
    if (usernameExists) throw Exception("Username already exists");

    final uid = await remoteDatasource.registerWithEmailAndPassword(
      user.email,
      password,
    );

    final userModel = UserModel(
      id: uid,
      username: user.username,
      email: user.email,
      fullName: user.fullName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await remoteDatasource.saveUserToFirestore(userModel);
  }

  @override
  Future<UserEntity?> Login(String email, String password) async {
    final uid = await remoteDatasource.loginWithEmailAndPassword(
      email,
      password,
    );
    if (uid == null) return null;

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
    return remoteDatasource.userChanges.map((userModel) {
      if (userModel == null) return null;
      return _toEntity(userModel);
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final uid = remoteDatasource.currentUserId;
    if (uid == null) return null;

    final userModel = await remoteDatasource.getUserFromFirestore(uid);
    if (userModel == null) return null;

    return _toEntity(userModel);
  }

  @override
  Future<void> Logout() async {
    await remoteDatasource.logout();
  }
}
