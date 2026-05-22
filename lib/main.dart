import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:studyflow/core/di/injection.dart';
import 'package:studyflow/core/services/widgets/auth_gate.dart';
import 'package:studyflow/core/services/widgets/global_snackbar.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/theme/theme_provider.dart';

void main() async {
  // Đảm bảo Flutter framework đã được khởi tạo trước khi gọi các native code hoặc async.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo locale data cho intl package (để format ngày tháng theo ngôn ngữ máy).
  await initializeDateFormatting(); 
  
  // Khởi tạo toàn bộ các dependency (database, repositories, v.v...) trước khi chạy UI.
  await DependencyInjection.init();

  // Bắt đầu render ứng dụng.
  runApp(const StudyFlowApp());
}

/// Widget gốc của ứng dụng.
/// Sử dụng `MultiProvider` để cung cấp state (ViewModels) xuống toàn bộ widget tree.
class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Lấy danh sách các Provider từ DependencyInjection
      providers: DependencyInjection.getProviders(),
      // Consumer lắng nghe sự thay đổi của ThemeProvider để tự động cập nhật theme (Light/Dark/System)
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'StudyFlow',
            // Cấu hình theme sáng mặc định
            theme: AppTheme.lightTheme,
            // Cấu hình theme tối
            darkTheme: AppTheme.darkTheme,
            // Chế độ theme hiện tại đang được chọn (lấy từ ThemeProvider)
            themeMode: themeProvider.themeMode,
            // builder này bao bọc toàn bộ app bằng GlobalSnackbar để có thể hiển thị thông báo ở bất kỳ đâu
            builder: (context, child) {
              return GlobalSnackbar(child: child!);
            },
            // Màn hình đầu tiên load lên là AuthGate để kiểm tra xem đã đăng nhập chưa
            home: const AuthGate(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
