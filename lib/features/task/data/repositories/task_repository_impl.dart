import 'package:studyflow/features/task/data/datasource/task_remote_datasource.dart';
import 'package:studyflow/features/task/data/models/task_model.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/repositories/task_repository.dart';

/// Implementation of the [TaskRepository] interface using .NET API.
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDatasource remoteDatasource;

  TaskRepositoryImpl(this.remoteDatasource);

  @override
  Stream<List<Task>> getTasksStream() {
    // API calls return Futures, but to keep compatibility with UI (StreamBuilder/BLoC),
    // we wrap the Future in a Stream. (Later you might want to change this to a Future in Domain layer).
    return Stream.fromFuture(remoteDatasource.getTasks()).map((models) {
      return models.map((model) => Task(
        id: model.id,
        title: model.title,
        description: model.description,
        date: model.date,
        startTime: model.startTime,
        endTime: model.endTime,
        isCompleted: model.isCompleted,
        reminderTime: model.reminderTime,
      )).toList();
    });
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
  }

  @override
  Future<void> deleteTask(String id) async {
    await remoteDatasource.deleteTask(id);
  }
}