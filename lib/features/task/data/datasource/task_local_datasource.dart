import 'package:studyflow/features/task/data/models/task_model.dart';

class TaskLocalDatasource {
  final List<TaskModel> _tasks = [];

  Future<List<TaskModel>> getTasksForDate(DateTime date) async {
    return _tasks.where((task) {
      return task.date.year == date.year &&
        task.date.month == date.month &&
        task.date.day == date.day;
    }).toList();
  }

  Future<void> addTask(TaskModel task) async {
    _tasks.add(task);
  }

  Future<void> updateTask(TaskModel updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);

    if(index != -1) {
      _tasks[index] = updatedTask;
    }
  }

  Future<void> deleteTask(int id) async {
    _tasks.removeWhere((task) => task.id == id);
  }
}