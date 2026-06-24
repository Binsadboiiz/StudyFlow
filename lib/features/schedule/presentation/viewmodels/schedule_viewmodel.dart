import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studyflow/core/utils/safe_change_notifier.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/usecase/add__task.dart';
import 'package:studyflow/features/task/domain/usecase/delete_task.dart';
import 'package:studyflow/features/task/domain/usecase/get_task.dart';
import 'package:studyflow/features/task/domain/usecase/update_task.dart';
import 'package:studyflow/core/network/network_checker.dart';

/// View model for managing the state of the schedule screen.
class ScheduleViewmodel extends ChangeNotifier with SafeChangeNotifier {
  /// Use case for adding a new task.
  final AddTask addTaskUseCase;
  /// Use case for deleting an existing task.
  final DeleteTask deleteTaskUseCase;
  /// Use case for retrieving tasks.
  final GetTask getTaskUseCase;
  /// Use case for updating an existing task.
  final UpdateTask updateTaskUseCase;

  /// Subscription to the task stream.
  StreamSubscription? _taskSubscription;
  /// List of all tasks retrieved from the use case.
  List<Task> _allTasks = [];

  ScheduleViewmodel({
    required this.addTaskUseCase,
    required this.deleteTaskUseCase,
    required this.getTaskUseCase,
    required this.updateTaskUseCase,
  }) {
    _currentWeekStart = _getMonday(DateTime.now());
    _selectedDay = DateTime.now();
    _isLoading = true;
    _init();
  }

  Future<void> _init() async {
    bool isConnected = await NetworkChecker.isServerReachable(timeoutSeconds: 30);
    if (!isConnected) {
      _isLoading = false;
      notifyListenersSafely();
      return;
    }

    _taskSubscription = getTaskUseCase().listen((tasks) {
      _allTasks = tasks;
      _updateWeeklyTasks();
      _isLoading = false;
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

  /// The start date of the currently displayed week.
  DateTime _currentWeekStart = DateTime.now();
  
  /// The date of the currently selected day.
  DateTime _selectedDay = DateTime.now();
  
  /// A map grouping tasks by their date strings.
  Map<String, List<Task>> _weeklyTasks = {};
  
  /// Indicates whether the task data is currently loading.
  bool _isLoading = false;

  /// Gets the start date of the current week.
  DateTime get currentWeekStart => _currentWeekStart;
  
  /// Gets the currently selected day.
  DateTime get selectedDay => _selectedDay;
  
  /// Returns the current loading state.
  bool get isLoading => _isLoading;

  /// Generates a list of [DateTime] objects representing the 7 days of the current week.
  List<DateTime> get weekDays {
    return List.generate(7, (i) =>
      DateTime(_currentWeekStart.year, _currentWeekStart.month, _currentWeekStart.day + i),
    );
  }

  /// Retrieves the list of tasks scheduled for a specific [day].
  List<Task> getTasksForDay(DateTime day) {
    final key = _dateKey(day);
    return _weeklyTasks[key] ?? [];
  }

  /// Gets the list of tasks scheduled for the currently selected day.
  List<Task> get selectedDayTasks => getTasksForDay(_selectedDay);

  /// Updates the selected day and notifies listeners.
  Future<void> selectDay(DateTime day) async {
    _selectedDay = day;
    notifyListenersSafely();
  }

  /// Navigates to a different week by applying the given [offset] (in weeks).
  Future<void> navigateWeek(int offset) async {
    _currentWeekStart = DateTime(
      _currentWeekStart.year,
      _currentWeekStart.month,
      _currentWeekStart.day + (offset * 7),
    );
    _selectedDay = _currentWeekStart;
    _updateWeeklyTasks();
    notifyListenersSafely();
  }

  /// Groups the list of all tasks by date for the current week.
  void _updateWeeklyTasks() {
    _weeklyTasks = {};
    for (final day in weekDays) {
      final key = _dateKey(day);
      _weeklyTasks[key] = _allTasks.where((task) {
        return task.date.year == day.year &&
               task.date.month == day.month &&
               task.date.day == day.day;
      }).toList();
    }
  }

  Future<void> loadWeekTasks() async {
    await getTaskUseCase.repository.refresh();
  }

  /// Adds a new [task] to the schedule.
  Future<void> addScheduleTask(Task task) async {
    await addTaskUseCase(task);
  }

  /// Deletes a scheduled task by its [id].
  Future<void> deleteScheduleTask(String id) async {
    await deleteTaskUseCase(id);
  }

  /// Toggles the completion status of the given [task].
  Future<void> toggleScheduleTask(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await updateTaskUseCase(updated);
  }

  /// Calculates the Monday of the week for the given [date].
  DateTime _getMonday(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  /// Returns a string key formatted as YYYY-MM-DD for the given [date].
  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Clears in-memory schedule task lists upon logout
  void clear() {
    _allTasks = [];
    _weeklyTasks = {};
    _currentWeekStart = _getMonday(DateTime.now());
    _selectedDay = DateTime.now();
    _isLoading = false;
    notifyListenersSafely();
  }
}
