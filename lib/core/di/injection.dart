import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:studyflow/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:studyflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:studyflow/features/auth/domain/usecase/check_auth_usecase.dart';
import 'package:studyflow/features/auth/domain/usecase/login_usecase.dart';
import 'package:studyflow/features/auth/domain/usecase/logout_usecase.dart';
import 'package:studyflow/features/auth/domain/usecase/register_usecase.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';

import 'package:studyflow/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:studyflow/features/task/data/datasource/task_remote_datasource.dart';
import 'package:studyflow/features/task/data/repositories/task_repository_impl.dart';
import 'package:studyflow/features/task/presentation/viewmodels/task_viewmodel.dart';
import 'package:studyflow/features/task/domain/usecase/add__task.dart';
import 'package:studyflow/features/task/domain/usecase/delete_task.dart';
import 'package:studyflow/features/task/domain/usecase/get_task.dart';
import 'package:studyflow/features/task/domain/usecase/update_task.dart';
import 'package:studyflow/features/schedule/presentation/viewmodels/schedule_viewmodel.dart';
import 'package:studyflow/core/theme/theme_provider.dart';

class DependencyInjection {
  static late final TaskRepositoryImpl taskRepository;
  static late final AuthRepositoryImpl authRepository;

  static Future<void> init() async {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    final taskRemoteDatasource = TaskRemoteDatasource(firestore: firestore, auth: auth);
    taskRepository = TaskRepositoryImpl(taskRemoteDatasource);

    final authRemoteDatasource = AuthRemoteDatasource(auth: auth, firestore: firestore);
    authRepository = AuthRepositoryImpl(authRemoteDatasource);
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
