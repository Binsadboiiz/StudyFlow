import 'package:isar/isar.dart';
import 'package:studyflow/features/task/data/models/task_model.dart';

class TaskLocalDatasource {
  final Isar isar;

  TaskLocalDatasource(this.isar);

  Future<List<TaskModel>> getTasksForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    return await isar.taskModels.filter()
      .dateBetween(startOfDay, endOfDay)
      .findAll();
  }

  Future<void> addTask(TaskModel task) async {
    await isar.writeTxn(() async {
      await isar.taskModels.put(task);
    });
  }

  Future<void> updateTask(TaskModel updatedTask) async {
    await isar.writeTxn(() async {
      await isar.taskModels.put(updatedTask);
    });
  }

  Future<void> deleteTask(int id) async {
    await isar.writeTxn(() async {
      await isar.taskModels.delete(id);
    });
  }
}