import 'package:studyflow/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:studyflow/features/auth/data/models/user_model.dart';
import 'package:studyflow/features/auth/domain/entities/user_entity.dart';
import 'package:studyflow/features/auth/domain/repositories/auth_repository.dart';
import 'package:bcrypt/bcrypt.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDatasource localDatasource;

  AuthRepositoryImpl(this.localDatasource);

  @override
  Future<void> Register(UserEntity user) async {
    final usernameExists = await isUsernameExists(user.username);
    if(usernameExists) throw Exception("Username already exists");

    final emailExists = await isEmailExists(user.email);
    if(emailExists) throw Exception("Email already exists");

    final hashedPassword = BCrypt.hashpw(
      user.password, 
      BCrypt.gensalt());

    final userModel = UserModel()
      ..username = user.username
      ..email = user.email
      ..password = hashedPassword;

    await localDatasource.Register(userModel);
  }

  @override
  Future<UserEntity?> Login(String identifier, String password) async {
    final user = await localDatasource.getUserByUserNameOrEmail(identifier);

    if(user == null) return null;

    final isPasswordCorrect = BCrypt.checkpw(password, user.password);
    if (!isPasswordCorrect) return null;

    return UserEntity(
      id: user.id, 
      username: user.username, 
      email: user.email,
      password: user.password
    );
  }

  @override
  Future<bool> isUsernameExists(String username) async {
    final user = await localDatasource.getUserByUserName(username);
    return user != null;
  }

  @override
  Future<bool> isEmailExists(String email) async {
    final user = await localDatasource.getUserByEmail(email);
    return user != null;
  }
}