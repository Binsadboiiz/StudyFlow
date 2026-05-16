import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'features/home/presentation/screens/home_screen.dart';
import 'features/home/presentation/screens/main_screen.dart';
import 'features/home/presentation/viewmodels/home_viewmodel.dart';
import 'features/task/data/datasource/task_local_datasource.dart';
import 'features/task/data/models/task_model.dart';
import 'features/task/data/repositories/task_repository_impl.dart';
import 'features/task/domain/repositories/task_repository.dart';
import 'features/task/presentation/viewmodels/task_viewmodel.dart';
import 'features/task/domain/usecase/add__task.dart';
import 'features/task/domain/usecase/delete_task.dart';
import 'features/task/domain/usecase/get_task.dart';
import 'features/task/domain/usecase/update_task.dart';
/// Điểm bắt đầu của toàn bộ ứng dụng (Entry point).
void main() async {
  // Đảm bảo Flutter Engine đã được khởi tạo xong trước khi chạy các setup bất đồng bộ (async).
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo dữ liệu định dạng ngày tháng của thư viện `intl`.
  // Yêu cầu bắt buộc để package `table_calendar` có thể format ngày tháng đúng chuẩn.
  await initializeDateFormatting(); 

  // Khởi tạo Isar
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [TaskModelSchema],
    directory: dir.path,
  );

  // Khởi tạo Repository dùng chung cho các tính năng
  final taskLocalDatasource = TaskLocalDatasource(isar);
  final taskRepository = TaskRepositoryImpl(taskLocalDatasource);

  // Chạy ứng dụng
  runApp(StudyFlowApp(taskRepository: taskRepository));
}

/// Lớp gốc chứa toàn bộ cấu hình chung của ứng dụng
class StudyFlowApp extends StatelessWidget {
  final TaskRepository taskRepository;

  const StudyFlowApp({super.key, required this.taskRepository});

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
            taskRepository: taskRepository, // Dependency Injection (có thể thay = Isar sau này)
          ),
        ),
        // Khởi tạo TaskViewmodel và tiêm các UseCase vào nó
        ChangeNotifierProvider(
          create: (_) => TaskViewmodel(
            addTaskUseCase: AddTask(taskRepository),
            deleteTaskUseCase: DeleteTask(taskRepository),
            getTaskUseCase: GetTask(taskRepository),
            updateTaskUseCase: UpdateTask(taskRepository),
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
        home: const MainScreen(),
      ),
    );
  }
}
