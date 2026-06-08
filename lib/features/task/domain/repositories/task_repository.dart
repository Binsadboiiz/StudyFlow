import '../entities/task.dart';

/// Interface defining data retrieval/storage operations related to Task.
/// The Domain Layer only defines this interface without knowing where data comes from (API or Local Database).
/// This helps separate the application logic from the underlying database technology.
abstract class TaskRepository {
  /// Retrieves all tasks for the user as a Stream (Real-time updates).
  Stream<List<Task>> getTasksStream();
  
  /// Adds a new task to the system.
  Future<void> addTask(Task task);
  
  /// Updates information of an existing task (e.g., marking it as completed/uncompleted).
  Future<void> updateTask(Task task);
  
  /// Deletes a task based on its ID.
  Future<void> deleteTask(String id);

  /// Forces a refresh of tasks from remote datasource.
  Future<void> refresh();
}
