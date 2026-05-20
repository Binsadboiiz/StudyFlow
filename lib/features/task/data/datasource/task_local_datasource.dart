import 'package:isar/isar.dart';
import 'package:studyflow/features/auth/data/models/session_model.dart';
import 'package:studyflow/features/task/data/models/task_model.dart';

class TaskLocalDatasource {
  final Isar isar;

  TaskLocalDatasource(this.isar);

  Future<int?> _getCurrentUserId() async {
    final session = await isar.sessionModels.get(0);
    return session?.userId;
  }

  Future<List<TaskModel>> getTasksForDate(DateTime date) async {
    final userId = await _getCurrentUserId();
    if (userId == null) return [];

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    return await isar.taskModels.filter()
      .userIdEqualTo(userId)
      .dateBetween(startOfDay, endOfDay)
      .findAll();
  }

  Future<void> addTask(TaskModel task) async {
    final userId = await _getCurrentUserId();
    if (userId != null) {
      task.userId = userId;
    }
    await isar.writeTxn(() async {
      await isar.taskModels.put(task);
    });
  }

  Future<void> updateTask(TaskModel updatedTask) async {
    final userId = await _getCurrentUserId();
    if (userId != null) {
      updatedTask.userId = userId;
    }
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