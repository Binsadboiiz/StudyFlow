import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/repositories/task_repository.dart';

class AddTask {
  final TaskRepository repository;

  AddTask(this.repository);

  Future<void> call(Task task) async {
    await repository.addTask(task);
  }
}