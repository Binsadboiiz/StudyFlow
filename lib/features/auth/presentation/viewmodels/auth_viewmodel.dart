import 'package:flutter/foundation.dart';
import 'package:studyflow/core/utils/safe_change_notifier.dart';
import 'package:studyflow/features/auth/domain/entities/user_entity.dart';
import 'package:studyflow/features/auth/domain/usecase/login_usecase.dart';
import 'package:studyflow/features/auth/domain/usecase/register_usecase.dart';

class AuthViewmodel extends ChangeNotifier with SafeChangeNotifier {
  final RegisterUsecase registerUsecase;
  final LoginUsecase loginUsecase;

  AuthViewmodel({
    required this.registerUsecase, 
    required this.loginUsecase});

  bool isLoading = false;
  UserEntity? currentUser;

  Future<String?> Register(String username, String email, String password) async {
    try {
      isLoading = true;
      notifyListenersSafely();

      await registerUsecase(UserEntity(
        username: username, 
        email: email,
        password: password));

      return null;
    } catch (e) {
      return e.toString().replaceFirst("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListenersSafely();
    }
  }

  Future<String?> Login(String identifier, String password) async {
    try {
      isLoading = true;
      notifyListenersSafely();

      final user = await loginUsecase(
        identifier,
        password,
      );

      if (user == null) {
        return "Invalid credentials";
      }

      currentUser = user;
      return null;
    } catch (e) {
      return e.toString().replaceFirst("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListenersSafely();
    }
  }

  void Logout() {
    currentUser = null;
    notifyListenersSafely();
  }
}