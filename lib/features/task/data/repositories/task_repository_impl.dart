import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:studyflow/core/database/isar_service.dart';
import 'package:studyflow/core/services/network_connection_service.dart';
import 'package:studyflow/features/task/data/datasource/task_remote_datasource.dart';
import 'package:studyflow/features/task/data/models/task_isar_model.dart';
import 'package:studyflow/features/task/data/models/task_model.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/repositories/task_repository.dart';

/// Implementation of the [TaskRepository] interface using Isar for local storage
/// and .NET API with Supabase integration for cloud storage.
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDatasource remoteDatasource;
  final NetworkConnectionService connectionService;

  // In-memory cache of tasks
  List<Task>? _tasksCache;

  // Broadcast StreamController to notify all view models/listeners of task changes
  final StreamController<List<Task>> _tasksController = StreamController<List<Task>>.broadcast();
  bool _isFetching = false;

  TaskRepositoryImpl(this.remoteDatasource, this.connectionService) {
    // Lắng nghe trạng thái kết nối mạng để tự động đồng bộ khi online trở lại
    connectionService.addListener(_onConnectionStatusChanged);
  }

  void _onConnectionStatusChanged() {
    if (connectionService.isOnline) {
      debugPrint('Internet khôi phục, tự động chạy đồng bộ offline tasks...');
      syncAllPending().then((_) => refresh());
    }
  }

  /// Khôi phục dữ liệu từ Isar local database (dữ liệu hiển thị offline tức thời)
  Future<List<Task>> _getLocalTasks() async {
    final isar = IsarService.isar;
    final localModels = await isar.taskIsarModels
        .filter()
        .not()
        .syncStatusEqualTo('pending_delete')
        .findAll();
    return localModels.map((model) => model.toDomain()).toList();
  }

  /// Fetches tasks from remote datasource, updates the local cache, and emits to stream
  Future<void> _fetchAndEmit() async {
    if (_isFetching) return;
    _isFetching = true;

    try {
      // 1. Luôn hiển thị dữ liệu cục bộ trước để giao diện phản hồi ngay lập tức
      final localTasks = await _getLocalTasks();
      _tasksCache = localTasks;
      _tasksController.add(localTasks);

      // 2. Nếu online, thực hiện đồng bộ và tải dữ liệu mới nhất
      if (connectionService.isOnline) {
        try {
          // Thực hiện đồng bộ các tác vụ chưa đồng bộ trước khi fetch
          await syncAllPending();

          // Fetch dữ liệu mới từ máy chủ
          final remoteModels = await remoteDatasource.getTasks();
          final remoteTasks = remoteModels.map((model) => Task(
            id: model.id,
            title: model.title,
            description: model.description,
            date: model.date,
            startTime: model.startTime,
            endTime: model.endTime,
            isCompleted: model.isCompleted,
            reminderTime: model.reminderTime,
          )).toList();

          final isar = IsarService.isar;
          await isar.writeTxn(() async {
            // Lấy danh sách local UUIDs để tránh xóa nhầm các tasks đang chờ insert/update offline
            final pendingModels = await isar.taskIsarModels
                .filter()
                .syncStatusEqualTo('pending_insert')
                .or()
                .syncStatusEqualTo('pending_update')
                .or()
                .syncStatusEqualTo('pending_delete')
                .findAll();
            final pendingUuids = pendingModels.map((m) => m.uuid).toSet();

            // Xóa các record đã synced cũ không còn trong danh sách pending
            await isar.taskIsarModels
                .filter()
                .syncStatusEqualTo('synced')
                .deleteAll();

            // Ghi đè dữ liệu mới từ Server vào Local Isar dưới dạng 'synced'
            for (final task in remoteTasks) {
              // Nếu task này không nằm trong danh sách đang chờ đồng bộ local
              if (!pendingUuids.contains(task.id)) {
                final isarModel = TaskIsarModel.fromDomain(task, syncStatus: 'synced');
                await isar.taskIsarModels.put(isarModel);
              }
            }
          });

          // Trả về danh sách kết hợp dữ liệu remote mới + local pending
          final updatedLocalTasks = await _getLocalTasks();
          _tasksCache = updatedLocalTasks;
          _tasksController.add(updatedLocalTasks);
        } catch (e) {
          debugPrint('Lỗi tải dữ liệu từ API, chuyển sang chế độ offline: $e');
        }
      }
    } catch (e) {
      _tasksController.addError(e);
    } finally {
      _isFetching = false;
    }
  }

  /// Exposes a force refresh method for the viewmodels
  @override
  Future<void> refresh() async {
    await _fetchAndEmit();
  }

  @override
  Stream<List<Task>> getTasksStream() async* {
    if (_tasksCache != null) {
      yield _tasksCache!;
    }
    
    // Trigger a fresh fetch
    _fetchAndEmit();
    
    yield* _tasksController.stream;
  }

  @override
  Future<void> addTask(Task task) async {
    final isar = IsarService.isar;
    // Tạo ID cục bộ duy nhất nếu ID trống (khi tạo offline)
    final taskId = task.id.isEmpty
        ? DateTime.now().microsecondsSinceEpoch.toString()
        : task.id;
    final taskWithId = task.copyWith(id: taskId);
    
    final localModel = TaskIsarModel.fromDomain(taskWithId, syncStatus: 'pending_insert');
    
    // 1. Lưu local ngay lập tức
    await isar.writeTxn(() async {
      await isar.taskIsarModels.put(localModel);
    });
    
    // Emit lại để UI cập nhật ngay lập tức
    final localTasks = await _getLocalTasks();
    _tasksCache = localTasks;
    _tasksController.add(localTasks);

    // 2. Cố gắng đẩy lên server nếu online
    if (connectionService.isOnline) {
      try {
        final model = TaskModel(
          id: taskWithId.id,
          userId: '', 
          title: taskWithId.title,
          description: taskWithId.description,
          date: taskWithId.date,
          startTime: taskWithId.startTime,
          endTime: taskWithId.endTime,
          isCompleted: taskWithId.isCompleted,
          reminderTime: taskWithId.reminderTime,
        );
        await remoteDatasource.addTask(model);
        
        // Cập nhật trạng thái đồng bộ thành công
        await isar.writeTxn(() async {
          localModel.syncStatus = 'synced';
          await isar.taskIsarModels.put(localModel);
        });
      } catch (e) {
        debugPrint('Lỗi thêm task lên server, lưu tạm offline: $e');
      }
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    final isar = IsarService.isar;
    
    // Tìm bản ghi local cũ để cập nhật
    final existingModel = await isar.taskIsarModels.filter().uuidEqualTo(task.id).findFirst();
    if (existingModel == null) return;

    // Giữ nguyên trạng thái pending_insert nếu task chưa từng sync lên server
    final newSyncStatus = existingModel.syncStatus == 'pending_insert' ? 'pending_insert' : 'pending_update';

    final updatedModel = TaskIsarModel.fromDomain(task, syncStatus: newSyncStatus);
    updatedModel.id = existingModel.id; // Giữ nguyên ID local của Isar

    // 1. Cập nhật local
    await isar.writeTxn(() async {
      await isar.taskIsarModels.put(updatedModel);
    });

    final localTasks = await _getLocalTasks();
    _tasksCache = localTasks;
    _tasksController.add(localTasks);

    // 2. Gửi API nếu online
    if (connectionService.isOnline) {
      try {
        final model = TaskModel(
          id: task.id,
          userId: '',
          title: task.title,
          description: task.description,
          date: task.date,
          startTime: task.startTime,
          endTime: task.endTime,
          isCompleted: task.isCompleted,
          reminderTime: task.reminderTime,
        );
        await remoteDatasource.updateTask(model);

        await isar.writeTxn(() async {
          updatedModel.syncStatus = 'synced';
          await isar.taskIsarModels.put(updatedModel);
        });
      } catch (e) {
        debugPrint('Lỗi cập nhật task lên server, lưu tạm offline: $e');
      }
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    final isar = IsarService.isar;
    final existingModel = await isar.taskIsarModels.filter().uuidEqualTo(id).findFirst();
    if (existingModel == null) return;

    // 1. Cập nhật local ngay lập tức
    if (existingModel.syncStatus == 'pending_insert') {
      // Nếu task chưa từng đồng bộ, xóa cứng local luôn
      await isar.writeTxn(() async {
        await isar.taskIsarModels.delete(existingModel.id);
      });
    } else {
      // Nếu đã từng đồng bộ, chuyển sang trạng thái chờ xóa (Soft Delete)
      await isar.writeTxn(() async {
        existingModel.syncStatus = 'pending_delete';
        existingModel.updatedAt = DateTime.now();
        await isar.taskIsarModels.put(existingModel);
      });
    }

    final localTasks = await _getLocalTasks();
    _tasksCache = localTasks;
    _tasksController.add(localTasks);

    // 2. Gửi API xóa nếu online
    if (connectionService.isOnline && existingModel.syncStatus != 'pending_insert') {
      try {
        await remoteDatasource.deleteTask(id);
        
        // Xóa cứng local sau khi Cloud xóa thành công
        await isar.writeTxn(() async {
          await isar.taskIsarModels.delete(existingModel.id);
        });
      } catch (e) {
        debugPrint('Lỗi xóa task trên server, chờ sync offline: $e');
      }
    }
  }

  /// Đồng bộ toàn bộ các task đang chờ xử lý offline lên server
  Future<void> syncAllPending() async {
    if (!connectionService.isOnline) return;
    
    final isar = IsarService.isar;

    // 1. Đồng bộ lệnh XÓA
    final pendingDeletes = await isar.taskIsarModels
        .filter()
        .syncStatusEqualTo('pending_delete')
        .findAll();
    
    for (final model in pendingDeletes) {
      try {
        await remoteDatasource.deleteTask(model.uuid);
        await isar.writeTxn(() async {
          await isar.taskIsarModels.delete(model.id);
        });
      } catch (e) {
        debugPrint('Lỗi đồng bộ xóa task ${model.uuid}: $e');
      }
    }

    // 2. Đồng bộ lệnh THÊM MỚI
    final pendingInserts = await isar.taskIsarModels
        .filter()
        .syncStatusEqualTo('pending_insert')
        .findAll();
    
    for (final model in pendingInserts) {
      try {
        final domainTask = model.toDomain();
        final apiModel = TaskModel(
          id: domainTask.id,
          userId: '',
          title: domainTask.title,
          description: domainTask.description,
          date: domainTask.date,
          startTime: domainTask.startTime,
          endTime: domainTask.endTime,
          isCompleted: domainTask.isCompleted,
          reminderTime: domainTask.reminderTime,
        );
        await remoteDatasource.addTask(apiModel);
        
        await isar.writeTxn(() async {
          model.syncStatus = 'synced';
          await isar.taskIsarModels.put(model);
        });
      } catch (e) {
        debugPrint('Lỗi đồng bộ thêm task ${model.uuid}: $e');
      }
    }

    // 3. Đồng bộ lệnh CẬP NHẬT
    final pendingUpdates = await isar.taskIsarModels
        .filter()
        .syncStatusEqualTo('pending_update')
        .findAll();
    
    for (final model in pendingUpdates) {
      try {
        final domainTask = model.toDomain();
        final apiModel = TaskModel(
          id: domainTask.id,
          userId: '',
          title: domainTask.title,
          description: domainTask.description,
          date: domainTask.date,
          startTime: domainTask.startTime,
          endTime: domainTask.endTime,
          isCompleted: domainTask.isCompleted,
          reminderTime: domainTask.reminderTime,
        );
        await remoteDatasource.updateTask(apiModel);
        
        await isar.writeTxn(() async {
          model.syncStatus = 'synced';
          await isar.taskIsarModels.put(model);
        });
      } catch (e) {
        debugPrint('Lỗi đồng bộ cập nhật task ${model.uuid}: $e');
      }
    }
  }
}