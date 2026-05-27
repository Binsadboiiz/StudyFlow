import 'package:studyflow/features/task/domain/repositories/task_repository.dart';

/// Use case for deleting a task from the system.
/// This encapsulates the logic required to remove an existing task.
class DeleteTask {
  /// The repository that handles data operations for tasks.
  final TaskRepository repository;
  
  /// Creates a [DeleteTask] use case with the given [TaskRepository].
  DeleteTask(this.repository);

  /// Executes the use case to delete a task with the given [id].
  Future<void> call(String id) async {
    await repository.deleteTask(id);
  }
}