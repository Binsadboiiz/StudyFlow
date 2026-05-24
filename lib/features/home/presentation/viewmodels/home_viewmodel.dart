import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studyflow/core/utils/safe_change_notifier.dart';
import '../../../../features/task/domain/entities/task.dart';
import '../../../../features/task/domain/repositories/task_repository.dart';

class HomeViewModel extends ChangeNotifier with SafeChangeNotifier {
  final TaskRepository _taskRepository;
  StreamSubscription? _taskSubscription;
  List<Task> _allTasks = [];

  HomeViewModel({required TaskRepository taskRepository})
      : _taskRepository = taskRepository {
    _isLoading = true;
    _taskSubscription = _taskRepository.getTasksStream().listen((tasks) {
      _allTasks = tasks;
      _updateDailyTasks();
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
  List<Task> _dailyTasks = [];
  bool _isLoading = false;

  DateTime get selectedDate => _selectedDate;
  DateTime get focusedDate => _focusedDate;
  List<Task> get dailyTasks => _dailyTasks;
  bool get isLoading => _isLoading;

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDate = selectedDay;
    _focusedDate = focusedDay;
    _updateDailyTasks();
    notifyListenersSafely();
  }

  void _updateDailyTasks() {
    _dailyTasks = _allTasks.where((task) {
      return task.date.year == _selectedDate.year &&
             task.date.month == _selectedDate.month &&
             task.date.day == _selectedDate.day;
    }).toList();
  }

  Future<void> refreshTasks() async {
    // Stream auto updates, no manual refresh needed
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await _taskRepository.updateTask(updatedTask);
  }
}
