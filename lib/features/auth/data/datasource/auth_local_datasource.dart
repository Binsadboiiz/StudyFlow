import 'package:isar/isar.dart';
import 'package:studyflow/features/auth/data/models/session_model.dart';
import 'package:studyflow/features/auth/data/models/user_model.dart';
import 'package:studyflow/features/task/data/models/task_model.dart';

class AuthLocalDatasource {
  final Isar isar;

  AuthLocalDatasource(this.isar);

  Future<void> Register(UserModel user) async {
    await isar.writeTxn(() async {
      await isar.userModels.put(user);
    });
  }

  Future<UserModel?> getUserByUserName(String username) async {
    return await isar.userModels.filter().usernameEqualTo(username).findFirst();
  }

  Future<UserModel?> getUserByEmail(String email) async {
    return await isar.userModels.filter().emailEqualTo(email).findFirst();
  }

  Future<UserModel?> getUserByUserNameOrEmail(String identifier) async {
    return await isar.userModels.filter()
        .usernameEqualTo(identifier)
        .or()
        .emailEqualTo(identifier)
        .findFirst();
  }

  Future<UserModel?> getUserById(int id) async {
    return await isar.userModels.get(id);
  }

  Future<void> saveSession(int userId) async {
    final session = SessionModel()
      ..id = 0
      ..userId = userId
      ..isLoggedIn = true;

    await isar.writeTxn(() async {
      await isar.sessionModels.put(session);
    });
  }

  Future<SessionModel?> getSession() async {
    return await isar.sessionModels.get(0);
  }

  Future<bool> isLoggedIn() async {
    final session =
      await isar.sessionModels.get(0);

    return session?.isLoggedIn ?? false;
  }

  Future<void> Logout() async {
    await isar.writeTxn(() async {
      await isar.sessionModels.delete(0);
    });
  }
}