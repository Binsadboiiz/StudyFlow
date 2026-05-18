import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'package:studyflow/features/auth/data/datasource/auth_local_datasource.dart';
import 'package:studyflow/features/auth/data/models/user_model.dart';
import 'package:studyflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:studyflow/features/auth/domain/usecase/login_usecase.dart';
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

class DependencyInjection {
  static late final Isar isar;
  static late final TaskRepositoryImpl taskRepository;
  static late final AuthRepositoryImpl authRepository;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open(
      [TaskModelSchema, UserModelSchema],
      directory: dir.path,
    );

    final taskLocalDatasource = TaskLocalDatasource(isar);
    taskRepository = TaskRepositoryImpl(taskLocalDatasource);

    final authLocalDatasource = AuthLocalDatasource(isar);
    authRepository = AuthRepositoryImpl(authLocalDatasource);
  }

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
        ),
      ),
    ];
  }
}
