import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/repositories/task_repository.dart';
import 'package:studyflow/features/task/data/datasource/task_local_datasource.dart';
import 'package:studyflow/features/task/data/models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDatasource localDatasource;

  TaskRepositoryImpl(this.localDatasource);

  @override
  Future<List<Task>> getTasksForDate(DateTime date) async {
    final models = await localDatasource.getTasksForDate(date);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addTask(Task task) async {
    final model = TaskModel.fromEntity(task);
    await localDatasource.addTask(model);
  }

  @override
  Future<void> updateTask(Task task) async {
    final model = TaskModel.fromEntity(task);
    await localDatasource.updateTask(model);
  }

  @override
  Future<void> deleteTask(int id) async {
    await localDatasource.deleteTask(id);
  }
}