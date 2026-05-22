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

/// `AuthViewmodel` quản lý trạng thái (state) liên quan đến xác thực người dùng (Authentication).
/// Chịu trách nhiệm gọi các UseCases (Domain layer) và cập nhật UI (Presentation layer).
/// Kế thừa `SafeChangeNotifier` để đảm bảo `notifyListeners()` không gây lỗi khi widget đã unmount.
class AuthViewmodel extends ChangeNotifier with SafeChangeNotifier {
  // Các UseCase được tiêm (inject) qua constructor
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

  // Trạng thái loading khi đang call API/DB
  bool isLoading = false;
  // Trạng thái người dùng đã đăng nhập hay chưa
  bool isAuthenticated = false;
  // Lưu thông tin người dùng hiện tại
  UserEntity? currentUser;

  /// Hàm xử lý đăng ký tài khoản mới.
  /// Trả về `null` nếu thành công, trả về chuỗi báo lỗi nếu thất bại.
  Future<String?> Register(String fullName, String username, String email, String password) async {
    try {
      isLoading = true;
      notifyListenersSafely();

      // Gọi UseCase để lưu user vào DB
      await registerUsecase(UserEntity(
        fullName: fullName,
        username: username, 
        email: email,
        password: password));

      // Hiển thị thông báo thành công thông qua Singleton NotificationService
      NotificationService.instance.show(
        AppNotification(message: "Register Successfully!", type: NotificationType.success)
      );

      return null;
    } catch (e) {
      NotificationService.instance.show(
        AppNotification(message: "Register failed!", type: NotificationType.error)
      );
      // Xóa chữ "Exception: " mặc định khi vứt exception
      return e.toString().replaceFirst("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListenersSafely();
    }
  }

  /// Hàm xử lý đăng nhập.
  /// `identifier` có thể là username hoặc email.
  Future<String?> Login(String identifier, String password) async {
    try {
      isLoading = true;
      notifyListenersSafely();

      // Gọi UseCase xác thực
      final user = await loginUsecase(
        identifier,
        password,
      );

      // Nếu không tìm thấy user hoặc sai pass
      if (user == null) {
        NotificationService.instance.show(
          AppNotification(message: "Invalid credentials", type: NotificationType.error)
        );
        return "Invalid credentials";
      }
      
      // Đăng nhập thành công, lưu lại trạng thái và thông tin
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

  /// Hàm kiểm tra trạng thái đăng nhập (được gọi khi mở app ở màn hình `AuthGate`).
  Future<void> CheckAuthStatus() async {
    // Lấy thông tin user từ Session/SharedPreferences thông qua UseCase
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

  /// Hàm đăng xuất tài khoản. Xóa session và reset trạng thái.
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