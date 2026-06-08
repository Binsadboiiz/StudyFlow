import 'dart:async';
import 'package:studyflow/features/task/data/datasource/task_remote_datasource.dart';
import 'package:studyflow/features/task/data/models/task_model.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/repositories/task_repository.dart';

/// Implementation of the [TaskRepository] interface using .NET API.
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDatasource remoteDatasource;

  // In-memory cache of tasks
  List<Task>? _tasksCache;

  // Broadcast StreamController to notify all view models/listeners of task changes
  final StreamController<List<Task>> _tasksController = StreamController<List<Task>>.broadcast();
  bool _isFetching = false;

  TaskRepositoryImpl(this.remoteDatasource);

  /// Fetches tasks from remote datasource, updates the local cache, and emits to stream
  Future<void> _fetchAndEmit() async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      final models = await remoteDatasource.getTasks();
      final tasks = models.map((model) => Task(
        id: model.id,
        title: model.title,
        description: model.description,
        date: model.date,
        startTime: model.startTime,
        endTime: model.endTime,
        isCompleted: model.isCompleted,
        reminderTime: model.reminderTime,
      )).toList();

      _tasksCache = tasks;
      _tasksController.add(tasks);
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
  Stream<List<Task>> getTasksStream() {
    // Trigger an initial asynchronous fetch from remote
    _fetchAndEmit();

    // Create a listener controller that pushes cache immediately, then forwards updates
    late StreamController<List<Task>> listenerController;
    StreamSubscription<List<Task>>? subscription;

    listenerController = StreamController<List<Task>>(
      onListen: () {
        if (_tasksCache != null) {
          listenerController.add(_tasksCache!);
        }
        subscription = _tasksController.stream.listen(
          (data) => listenerController.add(data),
          onError: (err) => listenerController.addError(err),
          onDone: () => listenerController.close(),
        );
      },
      onCancel: () {
        subscription?.cancel();
      },
    );

    return listenerController.stream;
  }

  @override
  Future<void> addTask(Task task) async {
    final model = TaskModel(
      id: task.id,
      userId: '', // ID này sẽ được API tự động lấy qua Firebase Token
      title: task.title,
      description: task.description,
      date: task.date,
      startTime: task.startTime,
      endTime: task.endTime,
      isCompleted: task.isCompleted,
      reminderTime: task.reminderTime,
    );
    await remoteDatasource.addTask(model);
    await _fetchAndEmit();
  }

  @override
  Future<void> updateTask(Task task) async {
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
    await _fetchAndEmit();
  }

  @override
  Future<void> deleteTask(String id) async {
    await remoteDatasource.deleteTask(id);
    await _fetchAndEmit();
  }
}