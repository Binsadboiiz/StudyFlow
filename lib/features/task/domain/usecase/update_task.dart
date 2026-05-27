import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/repositories/task_repository.dart';

/// Use case for updating an existing task in the system.
/// This encapsulates the logic required to modify a task.
class UpdateTask {
  /// The repository that handles data operations for tasks.
  final TaskRepository repository;

  /// Creates an [UpdateTask] use case with the given [TaskRepository].
  UpdateTask(this.repository);

  /// Executes the use case to update the given [task].
  Future<void> call(Task task) async {
    await repository.updateTask(task);
  }
}