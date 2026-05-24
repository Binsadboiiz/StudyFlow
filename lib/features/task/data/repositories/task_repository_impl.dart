import 'package:studyflow/features/task/data/datasource/task_remote_datasource.dart';
import 'package:studyflow/features/task/data/models/task_model.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDatasource remoteDatasource;

  TaskRepositoryImpl(this.remoteDatasource);

  @override
  Stream<List<Task>> getTasksStream() {
    return remoteDatasource.getTasksStream().map((models) {
      return models.map((model) => Task(
        id: model.id,
        title: model.title,
        description: model.description,
        date: model.date,
        startTime: model.startTime,
        endTime: model.endTime,
        isCompleted: model.isCompleted,
      )).toList();
    });
  }

  @override
  Future<void> addTask(Task task) async {
    final model = TaskModel(
      id: task.id,
      userId: '', // handled by datasource
      title: task.title,
      description: task.description,
      date: task.date,
      startTime: task.startTime,
      endTime: task.endTime,
      isCompleted: task.isCompleted,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await remoteDatasource.addTask(model);
  }

  @override
  Future<void> updateTask(Task task) async {
    final model = TaskModel(
      id: task.id,
      userId: '', // keep it empty or retrieve existing, doesn't matter since update doesn't usually override user ID
      title: task.title,
      description: task.description,
      date: task.date,
      startTime: task.startTime,
      endTime: task.endTime,
      isCompleted: task.isCompleted,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await remoteDatasource.updateTask(model);
  }

  @override
  Future<void> deleteTask(String id) async {
    await remoteDatasource.deleteTask(id);
  }
}