import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:studyflow/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:studyflow/features/auth/data/models/session_model.dart';
import 'package:studyflow/features/auth/data/models/user_model.dart';
import 'package:studyflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:studyflow/features/auth/domain/usecase/check_auth_usecase.dart';
import 'package:studyflow/features/auth/domain/usecase/login_usecase.dart';
import 'package:studyflow/features/auth/domain/usecase/logout_usecase.dart';
import 'package:studyflow/features/auth/domain/usecase/register_usecase.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';

import 'package:studyflow/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:studyflow/features/task/data/datasource/task_local_datasource.dart';
import 'package:studyflow/features/task/data/models/task_model.dart';
import 'package:studyflow/features/task/data/repositories/task_repository_impl.dart';
import 'package:studyflow/features/task/presentation/viewmodels/task_viewmodel.dart';
import 'package:studyflow/features/task/domain/usecase/add__task.dart';
import 'package:studyflow/features/task/domain/usecase/delete_task.dart';
import 'package:studyflow/features/task/domain/usecase/get_task.dart';
import 'package:studyflow/features/task/domain/usecase/update_task.dart';
import 'package:studyflow/features/schedule/presentation/viewmodels/schedule_viewmodel.dart';
import 'package:studyflow/core/theme/theme_provider.dart';

/// Lớp `DependencyInjection` chịu trách nhiệm khởi tạo và cung cấp toàn bộ 
/// các dependencies (database, repositories, viewmodels) cho ứng dụng theo mô hình Singleton.
class DependencyInjection {
  // Isar database instance dùng chung cho toàn bộ app
  static late final Isar isar;
  // Các Repository dùng để giao tiếp với local database
  static late final TaskRepositoryImpl taskRepository;
  static late final AuthRepositoryImpl authRepository;

  /// Hàm khởi tạo, cần được gọi ở `main.dart` trước khi chạy `runApp`.
  static Future<void> init() async {
    // Lấy đường dẫn thư mục tài liệu của ứng dụng trên thiết bị
    final dir = await getApplicationDocumentsDirectory();
    
    // Mở database Isar và đăng ký các Schema (cấu trúc bảng)
    isar = await Isar.open(
      [TaskModelSchema, UserModelSchema, SessionModelSchema],
      directory: dir.path,
    );

    // Khởi tạo các Datasources (lớp tương tác trực tiếp với Isar)
    final taskLocalDatasource = TaskLocalDatasource(isar);
    // Khởi tạo Repositories, tiêm Datasource vào
    taskRepository = TaskRepositoryImpl(taskLocalDatasource);

    final authLocalDatasource = AuthLocalDatasource(isar);
    authRepository = AuthRepositoryImpl(authLocalDatasource);
  }

  /// Trả về danh sách tất cả các `Provider` (ViewModels) để đăng ký vào `MultiProvider` ở `main.dart`.
  /// Các ViewModel được cấp phát các UseCases tương ứng.
  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider(
        create: (_) => HomeViewModel(
          taskRepository: taskRepository,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => TaskViewmodel(
          addTaskUseCase: AddTask(taskRepository),
          deleteTaskUseCase: DeleteTask(taskRepository),
          getTaskUseCase: GetTask(taskRepository),
          updateTaskUseCase: UpdateTask(taskRepository),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => ScheduleViewmodel(
          addTaskUseCase: AddTask(taskRepository),
          deleteTaskUseCase: DeleteTask(taskRepository),
          getTaskUseCase: GetTask(taskRepository),
          updateTaskUseCase: UpdateTask(taskRepository),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => AuthViewmodel(
          registerUsecase: RegisterUsecase(authRepository), 
          loginUsecase: LoginUsecase(authRepository),
          checkAuthUsecase: CheckAuthUsecase(authRepository),
          logoutUsecase: LogoutUsecase(authRepository),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
      ),
    ];
  }
}
