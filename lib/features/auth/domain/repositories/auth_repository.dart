import 'package:studyflow/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> Register(UserEntity user);
  
  // identifier could be username or email
  Future<UserEntity?> Login(String identifier, String password);

  Future<bool> isUsernameExists(String username);
  Future<bool> isEmailExists(String email);
}