import 'package:studyflow/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> Register(UserEntity user, String password);
  
  // identifier could be username or email (we will enforce email)
  Future<UserEntity?> Login(String email, String password);

  Future<bool> isUsernameExists(String username);

  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity?> getCurrentUser();

  Future<void> Logout();
}