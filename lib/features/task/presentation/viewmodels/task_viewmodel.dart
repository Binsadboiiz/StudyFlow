import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studyflow/core/utils/safe_change_notifier.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/usecase/add__task.dart';
import 'package:studyflow/features/task/domain/usecase/delete_task.dart';
import 'package:studyflow/features/task/domain/usecase/get_task.dart';
import 'package:studyflow/features/task/domain/usecase/update_task.dart';
import 'package:studyflow/core/network/network_checker.dart';
import 'package:studyflow/core/services/notification/local_notification_helper.dart';

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

  /// Flag indicating whether the initial task fetch is in progress.
  bool _isLoading = true;
  /// Getter for loading status.
  bool get isLoading => _isLoading;

  /// Constructor initializes the ViewModel with required use cases
  /// and starts listening to the task stream.
  TaskViewmodel({
    required this.addTaskUseCase,
    required this.deleteTaskUseCase,
    required this.getTaskUseCase,
    required this.updateTaskUseCase,
  }) {
    _init();
  }

  Future<void> _init() async {
    bool isConnected = await NetworkChecker.isServerReachable(timeoutSeconds: 30);
    if (!isConnected) {
      _isLoading = false;
      notifyListenersSafely();
      return;
    }

    _taskSubscription = getTaskUseCase().listen((taskData) {
      _allTasks = taskData;
      _isLoading = false;
      _updateTasks();
      _syncLocalNotifications();
      notifyListenersSafely();
    }, onError: (e) {
      _isLoading = false;
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

  /// Synchronizes local push notifications with tasks in the list.
  void _syncLocalNotifications() {
    try {
      for (final task in _allTasks) {
        if (task.reminderTime != null) {
          if (task.isCompleted || task.reminderTime!.isBefore(DateTime.now())) {
            LocalNotificationHelper.cancelNotification(task.id);
          } else {
            LocalNotificationHelper.scheduleTaskReminder(
              taskId: task.id,
              title: 'Reminder of work appointment: ${task.title}',
              body: task.description.isNotEmpty
                  ? task.description
                  : 'Time to do your work!',
              reminderTime: task.reminderTime!,
            );
          }
        }
      }
      _scheduleDailyReminderIfTasksIncomplete();
    } catch (e) {
      debugPrint('Error syncing local notifications: $e');
    }
  }

  /// Schedules daily incomplete tasks reminder at 20:00 PM.
  void _scheduleDailyReminderIfTasksIncomplete() {
    final today = DateTime.now();
    final hasIncompleteToday = _allTasks.any((t) =>
        t.date.year == today.year &&
        t.date.month == today.month &&
        t.date.day == today.day &&
        !t.isCompleted);

    if (hasIncompleteToday) {
      LocalNotificationHelper.scheduleDailyReminder(
        id: 9999, // Static ID for daily reminder
        hour: 20,
        minute: 0,
        title: 'Daily reminder',
        body: 'You still have some tasks today that have not been completed. Let\'s get them done!',
      );
    } else {
      LocalNotificationHelper.cancelDailyReminder(9999);
    }
  }

  /// Adds a new task by calling the corresponding use case.
  Future<void> addTask(Task task) async {
    await addTaskUseCase(task);
  }

  /// Deletes a task by ID. Requires the task's date to possibly update state if needed.
  Future<void> deleteTask(String id, DateTime date) async {
    await deleteTaskUseCase(id);
    LocalNotificationHelper.cancelNotification(id);
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