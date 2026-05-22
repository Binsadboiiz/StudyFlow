import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/features/auth/presentation/screens/login_screen.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:studyflow/features/home/presentation/screens/main_screen.dart';

/// `AuthGate` là màn hình đầu tiên được gọi khi ứng dụng khởi động.
/// Nó đóng vai trò như một "cửa bảo vệ", kiểm tra xem người dùng đã đăng nhập hay chưa.
/// Nếu đã đăng nhập -> Chuyển đến màn hình chính (MainScreen).
/// Nếu chưa đăng nhập -> Chuyển đến màn hình đăng nhập (LoginScreen).
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // Cờ trạng thái: đang trong quá trình kiểm tra đăng nhập
  bool isChecking = true;

  @override
  void initState() {
    super.initState();
    // Bắt đầu kiểm tra ngay khi widget được tạo
    _init();
  }

  /// Hàm kiểm tra trạng thái xác thực từ local storage (thông qua AuthViewmodel)
  Future<void> _init() async {
    final authVM = context.read<AuthViewmodel>();

    // Gọi hàm kiểm tra trong ViewModel (đọc token/session từ DB)
    await authVM.CheckAuthStatus();

    // Cập nhật lại UI sau khi kiểm tra xong
    setState(() {
      isChecking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Nếu đang kiểm tra, hiển thị vòng tròn loading
    if(isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 2. Sau khi kiểm tra xong, lấy kết quả từ AuthViewmodel
    final authVM = context.watch<AuthViewmodel>();

    // 3. Điều hướng dựa trên kết quả
    if(authVM.isAuthenticated) {
      return const MainScreen();
    }
    return const LoginScreen();
  }
}