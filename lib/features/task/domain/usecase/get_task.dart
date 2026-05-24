import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/repositories/task_repository.dart';

class GetTask {
  final TaskRepository repository;

  GetTask(this.repository);

  Stream<List<Task>> call() {
    return repository.getTasksStream();
  }
}