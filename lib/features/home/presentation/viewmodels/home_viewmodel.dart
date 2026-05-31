import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studyflow/core/utils/safe_change_notifier.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../features/task/domain/entities/task.dart';
import '../../../../features/task/domain/repositories/task_repository.dart';
import 'package:studyflow/core/network/network_checker.dart';

/// Viewmodel for managing the state of the Home screen.
class HomeViewModel extends ChangeNotifier with SafeChangeNotifier {
  final TaskRepository _taskRepository;
  StreamSubscription? _taskSubscription;
  List<Task> _allTasks = [];

  HomeViewModel({required TaskRepository taskRepository})
      : _taskRepository = taskRepository {
    _isLoading = true;
    _init();
  }

  Future<void> _init() async {
    bool isConnected = await NetworkChecker.isServerReachable();
    if (!isConnected) {
      _isLoading = false;
      notifyListenersSafely();
      return;
    }

    _taskSubscription = _taskRepository.getTasksStream().listen((tasks) {
      _allTasks = tasks;
      _updateDailyTasks();
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

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<Task> _dailyTasks = [];
  bool _isLoading = false;

  /// The currently selected date on the calendar.
  DateTime get selectedDate => _selectedDate;
  
  /// The currently focused date on the calendar.
  DateTime get focusedDate => _focusedDate;

  /// The current calendar format.
  CalendarFormat get calendarFormat => _calendarFormat;
  
  /// The list of tasks for the selected date.
  List<Task> get dailyTasks => _dailyTasks;
  
  /// Whether the viewmodel is currently loading data.
  bool get isLoading => _isLoading;

  /// Handles the event when a day is selected on the calendar.
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDate = selectedDay;
    _focusedDate = focusedDay;
    _updateDailyTasks();
    notifyListenersSafely();
  }

  /// Handles the event when the calendar format is changed.
  void onFormatChanged(CalendarFormat format) {
    if (_calendarFormat != format) {
      _calendarFormat = format;
      notifyListenersSafely();
    }
  }

  void _updateDailyTasks() {
    _dailyTasks = _allTasks.where((task) {
      return task.date.year == _selectedDate.year &&
             task.date.month == _selectedDate.month &&
             task.date.day == _selectedDate.day;
    }).toList();
  }

  /// Refreshes the tasks.
  Future<void> refreshTasks() async {
    // Stream auto updates, no manual refresh needed
  }

  /// Toggles the completion status of a [task].
  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await _taskRepository.updateTask(updatedTask);
  }
}
