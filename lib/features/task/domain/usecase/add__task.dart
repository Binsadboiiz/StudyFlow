import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/repositories/task_repository.dart';

/// Use case for adding a new task to the system.
/// This encapsulates the logic required to create a new task.
class AddTask {
  /// The repository that handles data operations for tasks.
  final TaskRepository repository;

  /// Creates an [AddTask] use case with the given [TaskRepository].
  AddTask(this.repository);

  /// Executes the use case to add the given [task].
  Future<void> call(Task task) async {
    await repository.addTask(task);
  }
}