import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'features/home/presentation/screens/home_screen.dart';
import 'features/home/presentation/viewmodels/home_viewmodel.dart';
import 'features/task/data/repositories/mock_task_repository_impl.dart';

/// Điểm bắt đầu của toàn bộ ứng dụng (Entry point).
void main() async {
  // Đảm bảo Flutter Engine đã được khởi tạo xong trước khi chạy các setup bất đồng bộ (async).
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo dữ liệu định dạng ngày tháng của thư viện `intl`.
  // Yêu cầu bắt buộc để package `table_calendar` có thể format ngày tháng đúng chuẩn.
  await initializeDateFormatting(); 

  // Chạy ứng dụng
  runApp(const StudyFlowApp());
}

/// Lớp gốc chứa toàn bộ cấu hình chung của ứng dụng
class StudyFlowApp extends StatelessWidget {
  const StudyFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider cho phép khai báo danh sách tất cả các Provider (ViewModel) sẽ dùng trong app.
    // Việc bọc nó ở ngoài cùng giúp bất kỳ màn hình nào cũng có thể truy xuất được các ViewModel này.
    return MultiProvider(
      providers: [
        // Khởi tạo HomeViewModel và tiêm (inject) MockTaskRepositoryImpl vào nó.
        // Cú pháp ChangeNotifierProvider sẽ tự động lắng nghe và dọn dẹp bộ nhớ (dispose) khi không dùng nữa.
        ChangeNotifierProvider(
          create: (_) => HomeViewModel(
            taskRepository: MockTaskRepositoryImpl(), // Dependency Injection (có thể thay = Isar sau này)
          ),
        ),
      ],
      // MaterialApp chứa cấu hình về giao diện Material Design (Theme, Màu sắc, Routing...)
      child: MaterialApp(
        title: 'StudyFlow',
        // Thiết lập theme (giao diện) cho toàn app
        theme: ThemeData(
          // Tạo một bảng màu đồng bộ (ColorScheme) dựa trên màu xanh lam chủ đạo
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          // Sử dụng Material 3 - ngôn ngữ thiết kế mới nhất của Google
          useMaterial3: true,
        ),
        // Màn hình đầu tiên hiện lên khi mở app
        home: const HomeScreen(),
      ),
    );
  }
}
