import 'dart:math';
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

    // Generate a random ID and ensure it doesn't collide
    int randomId;
    bool exists = true;
    final random = Random();
    do {
      randomId = random.nextInt(900000) + 100000;
      final existingUser = await localDatasource.getUserById(randomId);
      if (existingUser == null) {
        exists = false;
      }
    } while (exists);

    final userModel = UserModel()
      ..id = randomId
      ..username = user.username
      ..email = user.email
      ..password = hashedPassword
      ..fullName = user.fullName;

    await localDatasource.Register(userModel);
  }

  @override
  Future<UserEntity?> Login(String identifier, String password) async {
    final user = await localDatasource.getUserByUserNameOrEmail(identifier);

    if(user == null) return null;

    final isPasswordCorrect = BCrypt.checkpw(password, user.password);
    if (!isPasswordCorrect) return null;

    await localDatasource.saveSession(user.id);

    return UserEntity(
      id: user.id, 
      username: user.username, 
      email: user.email,
      password: user.password,
      fullName: user.fullName,
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

  @override
  Future<void> saveSession(int userId) async {
    await localDatasource.saveSession(userId);
  }

  @override
  Future<bool> isLoggedIn() async {
    return await localDatasource.isLoggedIn();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final session = await localDatasource.getSession();
    if (session == null || !session.isLoggedIn) return null;

    final user = await localDatasource.getUserById(session.userId);
    if (user == null) return null;

    return UserEntity(
      id: user.id,
      username: user.username,
      email: user.email,
      password: user.password,
      fullName: user.fullName,
    );
  }

  @override
  Future<void> Logout() async {
    await localDatasource.Logout();
  }
}