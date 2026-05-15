import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/repositories/task_repository.dart';

class UpdateTask {
  final TaskRepository repository;

  UpdateTask(this.repository);

  Future<void> call(Task task) async {
    await repository.updateTask(task);
  }
}