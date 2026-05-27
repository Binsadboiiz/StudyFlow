import 'package:studyflow/features/task/data/datasource/task_remote_datasource.dart';
import 'package:studyflow/features/task/data/models/task_model.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/repositories/task_repository.dart';

/// Implementation of the [TaskRepository] interface.
/// This class acts as a bridge between the data layer and domain layer,
/// handling the conversion between [TaskModel] and [Task].
class TaskRepositoryImpl implements TaskRepository {
  /// The remote data source used to perform network or database operations.
  final TaskRemoteDatasource remoteDatasource;

  /// Creates a [TaskRepositoryImpl] with the given [TaskRemoteDatasource].
  TaskRepositoryImpl(this.remoteDatasource);

  @override
  Stream<List<Task>> getTasksStream() {
    // Listen to the remote stream and map the incoming task models to domain entities.
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
    // Convert the domain entity into a data model before sending it to the remote source.
    final model = TaskModel(
      id: task.id,
      userId: '', // The user ID is handled directly by the datasource.
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
    // Convert the domain entity into a data model to perform an update.
    final model = TaskModel(
      id: task.id,
      userId: '', // Kept empty since update generally does not override the user ID.
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
    // Pass the task ID to the remote data source for deletion.
    await remoteDatasource.deleteTask(id);
  }
}