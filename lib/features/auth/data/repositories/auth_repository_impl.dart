import 'package:studyflow/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:studyflow/features/auth/data/models/user_model.dart';
import 'package:studyflow/features/auth/domain/entities/user_entity.dart';
import 'package:studyflow/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;

  AuthRepositoryImpl(this.remoteDatasource);

  @override
  Future<void> Register(UserEntity user, String password) async {
    final usernameExists = await isUsernameExists(user.username);
    if(usernameExists) throw Exception("Username already exists");

    final uid = await remoteDatasource.registerWithEmailAndPassword(user.email, password);

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
    final uid = await remoteDatasource.loginWithEmailAndPassword(email, password);
    if (uid == null) return null;

    final userModel = await remoteDatasource.getUserFromFirestore(uid);
    if (userModel == null) return null;

    return UserEntity(
      id: userModel.id, 
      username: userModel.username, 
      email: userModel.email,
      fullName: userModel.fullName,
    );
  }

  @override
  Future<bool> isUsernameExists(String username) async {
    return await remoteDatasource.isUsernameExists(username);
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDatasource.authStateChanges.asyncMap((uid) async {
      if (uid == null) return null;
      final userModel = await remoteDatasource.getUserFromFirestore(uid);
      if (userModel == null) return null;
      return UserEntity(
        id: userModel.id, 
        username: userModel.username, 
        email: userModel.email,
        fullName: userModel.fullName,
      );
    });
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final uid = remoteDatasource.currentUserId;
    if (uid == null) return null;

    final userModel = await remoteDatasource.getUserFromFirestore(uid);
    if (userModel == null) return null;

    return UserEntity(
      id: userModel.id,
      username: userModel.username,
      email: userModel.email,
      fullName: userModel.fullName,
    );
  }

  @override
  Future<void> Logout() async {
    await remoteDatasource.logout();
  }
}