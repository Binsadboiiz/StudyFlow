import 'package:flutter/foundation.dart';
import 'package:studyflow/core/services/notification/app_notification.dart';
import 'package:studyflow/core/services/notification/notification_service.dart';
import 'package:studyflow/core/services/notification/notification_type.dart';
import 'package:studyflow/core/utils/safe_change_notifier.dart';
import 'package:studyflow/features/auth/domain/entities/user_entity.dart';
import 'package:studyflow/features/auth/domain/usecase/check_auth_usecase.dart';
import 'package:studyflow/features/auth/domain/usecase/login_usecase.dart';
import 'package:studyflow/features/auth/domain/usecase/logout_usecase.dart';
import 'package:studyflow/features/auth/domain/usecase/register_usecase.dart';

class AuthViewmodel extends ChangeNotifier with SafeChangeNotifier {
  final RegisterUsecase registerUsecase;
  final LoginUsecase loginUsecase;
  final CheckAuthUsecase checkAuthUsecase;
  final LogoutUsecase logoutUsecase;

  AuthViewmodel({
    required this.registerUsecase, 
    required this.loginUsecase,
    required this.checkAuthUsecase,
    required this.logoutUsecase,
    });

  bool isLoading = false;
  bool isAuthenticated = false;
  UserEntity? currentUser;

  Future<String?> Register(String username, String email, String password) async {
    try {
      isLoading = true;
      notifyListenersSafely();

      await registerUsecase(UserEntity(
        username: username, 
        email: email,
        password: password));

      NotificationService.instance.show(
        AppNotification(message: "Register Successfully!", type: NotificationType.success)
      );

      return null;
    } catch (e) {
      NotificationService.instance.show(
        AppNotification(message: "Register failed!", type: NotificationType.error)
      );
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
        NotificationService.instance.show(
          AppNotification(message: "Invalid credentials", type: NotificationType.error)
        );
      }
      isAuthenticated = true;

      currentUser = user;
      NotificationService.instance.show(
        AppNotification(message: "Login Successfully", type: NotificationType.success)
      );
      return null;
    } catch (e) {
      NotificationService.instance.show(
        AppNotification(message: "Login failed", type: NotificationType.error)
      );
      return e.toString().replaceFirst("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListenersSafely();
    }
  }

  Future<void> CheckAuthStatus() async {
    final user = await checkAuthUsecase();
    if (user != null) {
      isAuthenticated = true;
      currentUser = user;
    } else {
      isAuthenticated = false;
      currentUser = null;
    }

    notifyListenersSafely();
  }

  Future<void> Logout() async {
    await logoutUsecase();
    isAuthenticated = false;
    currentUser = null;
    NotificationService.instance.show(
      AppNotification(message: 'Logout success', type: NotificationType.success)
    );
    notifyListenersSafely();
  }
}