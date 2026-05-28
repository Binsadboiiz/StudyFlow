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
import 'package:studyflow/features/auth/domain/usecase/update_streak_usecase.dart';

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

/// A utility class for setting up dependency injection across the application.
/// It initializes repositories and provides a list of Providers for state management.
class DependencyInjection {
  /// The globally available task repository instance.
  static late final TaskRepositoryImpl taskRepository;
  /// The globally available authentication repository instance.
  static late final AuthRepositoryImpl authRepository;

  /// Initializes all the dependencies needed for the application.
  /// This should be called before `runApp()` in `main.dart`.
  static Future<void> init() async {
    // Initialize Firebase instances
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    // Set up data sources and repositories for tasks
    final taskRemoteDatasource = TaskRemoteDatasource(auth: auth);
    taskRepository = TaskRepositoryImpl(taskRemoteDatasource);

    // Set up data sources and repositories for authentication
    final authRemoteDatasource = AuthRemoteDatasource(auth: auth, firestore: firestore);
    authRepository = AuthRepositoryImpl(authRemoteDatasource);
  }

  /// Returns a list of all state management providers used in the application.
  /// These are injected at the root level using `MultiProvider`.
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
          updateStreakUsecase: UpdateStreakUsecase(authRepository),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
      ),
    ];
  }
}
