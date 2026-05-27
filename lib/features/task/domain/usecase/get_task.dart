import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/repositories/task_repository.dart';

/// Use case for retrieving tasks from the system.
/// This encapsulates the logic required to fetch a stream of tasks.
class GetTask {
  /// The repository that handles data operations for tasks.
  final TaskRepository repository;

  /// Creates a [GetTask] use case with the given [TaskRepository].
  GetTask(this.repository);

  /// Executes the use case to get a stream of all tasks.
  Stream<List<Task>> call() {
    return repository.getTasksStream();
  }
}