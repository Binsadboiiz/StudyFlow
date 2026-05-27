import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studyflow/core/utils/safe_change_notifier.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/usecase/add__task.dart';
import 'package:studyflow/features/task/domain/usecase/delete_task.dart';
import 'package:studyflow/features/task/domain/usecase/get_task.dart';
import 'package:studyflow/features/task/domain/usecase/update_task.dart';

/// ViewModel responsible for managing the state and business logic related to tasks.
/// Uses Clean Architecture use cases to interact with the repository.
class TaskViewmodel extends ChangeNotifier with SafeChangeNotifier {
  /// Use case to add a new task.
  final AddTask addTaskUseCase;
  
  /// Use case to delete an existing task.
  final DeleteTask deleteTaskUseCase;
  
  /// Use case to retrieve a stream of tasks.
  final GetTask getTaskUseCase;
  
  /// Use case to update an existing task.
  final UpdateTask updateTaskUseCase;

  /// Subscription to listen to real-time updates from the task stream.
  StreamSubscription? _taskSubscription;
  
  /// Internal list holding all tasks fetched from the data source.
  List<Task> _allTasks = [];

  /// Constructor initializes the ViewModel with required use cases
  /// and starts listening to the task stream.
  TaskViewmodel({
    required this.addTaskUseCase,
    required this.deleteTaskUseCase,
    required this.getTaskUseCase,
    required this.updateTaskUseCase,
  }) {
    _taskSubscription = getTaskUseCase().listen((taskData) {
      _allTasks = taskData;
      _updateTasks();
      notifyListenersSafely();
    });
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }

  /// List of tasks filtered for the currently selected date.
  List<Task> tasks = [];
  
  DateTime _selectedDate = DateTime.now();
  
  /// The currently selected date to view tasks for.
  DateTime get selectedDate => _selectedDate;

  /// Selects a new date and filters the tasks accordingly.
  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    _updateTasks();
    notifyListenersSafely();
  }

  /// Loads tasks for a specific date (used during initialization).
  Future<void> loadTask(DateTime date) async {
    _selectedDate = date;
    _updateTasks();
    notifyListenersSafely();
  }

  /// Filters [_allTasks] to only include tasks that match [_selectedDate].
  void _updateTasks() {
    tasks = _allTasks.where((task) {
      return task.date.year == _selectedDate.year &&
             task.date.month == _selectedDate.month &&
             task.date.day == _selectedDate.day;
    }).toList();
  }

  /// Adds a new task by calling the corresponding use case.
  Future<void> addTask(Task task) async {
    await addTaskUseCase(task);
  }

  /// Deletes a task by ID. Requires the task's date to possibly update state if needed.
  Future<void> deleteTask(String id, DateTime date) async {
    await deleteTaskUseCase(id);
  }

  /// Toggles the completion status of a task and updates it in the repository.
  Future<void> toggleTask(Task task) async {
    final updateTask = task.copyWith(
      isCompleted: !task.isCompleted,
    );
    await updateTaskUseCase(updateTask);
  }

  /// Updates an existing task with new data.
  Future<void> updateTask(Task task) async {
    await updateTaskUseCase(task);
  }
}