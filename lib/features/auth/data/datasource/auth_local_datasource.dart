import 'package:isar/isar.dart';
import 'package:studyflow/features/auth/data/models/user_model.dart';

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
}