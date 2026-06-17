import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:studyflow/core/database/isar_service.dart';
import 'package:studyflow/core/services/network_connection_service.dart';

import 'package:studyflow/features/auth/data/datasource/auth_remote_datasource.dart';
import 'package:studyflow/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:studyflow/features/auth/domain/usecase/check_auth_usecase.dart';
import 'package:studyflow/features/auth/domain/usecase/login_usecase.dart';
import 'package:studyflow/features/auth/domain/usecase/logout_usecase.dart';
import 'package:studyflow/features/auth/domain/usecase/register_usecase.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:studyflow/features/auth/domain/usecase/update_streak_usecase.dart';
import 'package:studyflow/features/auth/domain/usecase/login_with_google_usecase.dart';
import 'package:studyflow/features/auth/domain/usecase/update_profile_usecase.dart';

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
import 'package:studyflow/core/providers/performance_provider.dart';
import 'package:studyflow/core/providers/language_provider.dart';
import 'package:studyflow/features/notification/data/datasource/notification_remote_datasource.dart';
import 'package:studyflow/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:studyflow/features/notification/presentation/viewmodels/notification_viewmodel.dart';
import 'package:studyflow/features/gamification/data/repositories/gamification_repository.dart';
import 'package:studyflow/features/gamification/data/repositories/pet_repository.dart';
import 'package:studyflow/features/gamification/presentation/viewmodels/gamification_viewmodel.dart';
import 'package:studyflow/features/gamification/presentation/viewmodels/pet_viewmodel.dart';

// Scan feature (OCR Document Scanning)
import 'package:studyflow/features/scan/data/datasource/scan_remote_datasource.dart';
import 'package:studyflow/features/scan/data/repositories/scan_repository_impl.dart';
import 'package:studyflow/features/scan/presentation/viewmodels/scan_viewmodel.dart';
import 'package:studyflow/features/scan/domain/usecase/get_scanned_documents_usecase.dart';
import 'package:studyflow/features/scan/domain/usecase/scan_document_usecase.dart';
import 'package:studyflow/features/scan/domain/usecase/delete_scanned_document_usecase.dart';
import 'package:studyflow/features/scan/domain/usecase/get_storage_usage_usecase.dart';
import 'package:studyflow/features/scan/domain/usecase/search_documents_usecase.dart';
import 'package:studyflow/features/scan/domain/usecase/get_trash_documents_usecase.dart';
import 'package:studyflow/features/scan/domain/usecase/restore_document_usecase.dart';
import 'package:studyflow/features/scan/domain/usecase/hard_delete_document_usecase.dart';
import 'package:studyflow/features/scan/domain/usecase/batch_delete_documents_usecase.dart';

// Flashcard & AI Chat features
import 'package:studyflow/features/flashcard/data/datasource/flashcard_remote_datasource.dart';
import 'package:studyflow/features/flashcard/presentation/providers/flashcard_provider.dart';
import 'package:studyflow/features/ai_chat/data/datasource/ai_chat_remote_datasource.dart';
import 'package:studyflow/features/ai_chat/presentation/providers/ai_chat_provider.dart';

/// A utility class for setting up dependency injection across the application.
/// It initializes repositories and provides a list of Providers for state management.
class DependencyInjection {
  /// The globally available task repository instance.
  static late final TaskRepositoryImpl taskRepository;
  /// The globally available authentication repository instance.
  static late final AuthRepositoryImpl authRepository;
  /// The globally available notification repository instance.
  static late final NotificationRepositoryImpl notificationRepository;
  /// The globally available gamification repository instance.
  static late final GamificationRepository gamificationRepository;
  /// The globally available study pet repository instance.
  static late final PetRepository petRepository;
  /// The globally available scan repository instance (OCR Document Scanning).
  static late final ScanRepositoryImpl scanRepository;
  /// Flashcard & AI Remote datasources
  static late final FlashcardRemoteDatasource flashcardRemoteDatasource;
  static late final AiChatRemoteDatasource aiChatRemoteDatasource;
  /// The globally available network connection service instance.
  static late final NetworkConnectionService connectionService;

  /// Initializes all the dependencies needed for the application.
  /// This should be called before `runApp()` in `main.dart`.
  static Future<void> init() async {
    // Khởi tạo Isar Local Database
    await IsarService.init();

    // Khởi tạo Network Connection Service
    connectionService = NetworkConnectionService();

    // Initialize Firebase instances
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;

    // Set up data sources and repositories for tasks
    final taskRemoteDatasource = TaskRemoteDatasource(auth: auth);
    taskRepository = TaskRepositoryImpl(taskRemoteDatasource, connectionService);

    // Set up data sources and repositories for authentication
    final authRemoteDatasource = AuthRemoteDatasource(auth: auth, firestore: firestore);
    authRepository = AuthRepositoryImpl(authRemoteDatasource);

    // Set up data sources and repositories for notifications
    final notificationRemoteDatasource = NotificationRemoteDatasource(auth: auth);
    notificationRepository = NotificationRepositoryImpl(notificationRemoteDatasource);

    // Set up gamification and pet repositories
    gamificationRepository = GamificationRepository();
    petRepository = PetRepository();

    // Set up data sources and repositories for scan (OCR)
    final scanRemoteDatasource = ScanRemoteDatasource(auth: auth);
    scanRepository = ScanRepositoryImpl(scanRemoteDatasource);

    // Set up Flashcard & AI Datasources
    flashcardRemoteDatasource = FlashcardRemoteDatasource(auth: auth);
    aiChatRemoteDatasource = AiChatRemoteDatasource(auth: auth);
  }

  /// Returns a list of all state management providers used in the application.
  /// These are injected at the root level using `MultiProvider`.
  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider.value(
        value: connectionService,
      ),
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
          loginWithGoogleUsecase: LoginWithGoogleUsecase(authRepository),
          updateProfileUsecase: UpdateProfileUsecase(authRepository),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => NotificationViewModel(
          repository: notificationRepository,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => LanguageProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => PerformanceProvider(),
      ),
      ChangeNotifierProvider(
        create: (_) => GamificationViewModel(
          gamificationRepository: gamificationRepository,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => PetViewModel(
          petRepository: petRepository,
        ),
      ),
      // Provider cho tính năng quét tài liệu OCR
      ChangeNotifierProvider(
        create: (_) => ScanViewModel(
          getDocumentsUseCase: GetScannedDocuments(scanRepository),
          scanDocumentUseCase: ScanDocument(scanRepository),
          deleteDocumentUseCase: DeleteScannedDocument(scanRepository),
          getStorageUsageUseCase: GetStorageUsage(scanRepository),
          searchDocumentsUseCase: SearchDocuments(scanRepository),
          getTrashDocumentsUseCase: GetTrashDocuments(scanRepository),
          restoreDocumentUseCase: RestoreDocument(scanRepository),
          hardDeleteDocumentUseCase: HardDeleteDocument(scanRepository),
          batchDeleteDocumentsUseCase: BatchDeleteDocuments(scanRepository),
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => FlashcardProvider(
          remoteDatasource: flashcardRemoteDatasource,
          aiRemoteDatasource: aiChatRemoteDatasource,
        ),
      ),
      ChangeNotifierProvider(
        create: (_) => AiChatProvider(
          remoteDatasource: aiChatRemoteDatasource,
        ),
      ),
    ];
  }
}
