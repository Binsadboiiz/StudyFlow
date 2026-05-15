import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/repositories/task_repository.dart';

class GetTask {
  final TaskRepository repository;

  GetTask(this.repository);

  Future<List<Task>> call(DateTime date) async {
    return repository.getTasksForDate(date);
  }
}