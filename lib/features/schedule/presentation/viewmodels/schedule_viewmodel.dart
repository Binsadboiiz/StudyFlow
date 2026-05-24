import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studyflow/core/utils/safe_change_notifier.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/usecase/add__task.dart';
import 'package:studyflow/features/task/domain/usecase/delete_task.dart';
import 'package:studyflow/features/task/domain/usecase/get_task.dart';
import 'package:studyflow/features/task/domain/usecase/update_task.dart';

class ScheduleViewmodel extends ChangeNotifier with SafeChangeNotifier {
  final AddTask addTaskUseCase;
  final DeleteTask deleteTaskUseCase;
  final GetTask getTaskUseCase;
  final UpdateTask updateTaskUseCase;

  StreamSubscription? _taskSubscription;
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
    _taskSubscription = getTaskUseCase().listen((tasks) {
      _allTasks = tasks;
      _updateWeeklyTasks();
      _isLoading = false;
      notifyListenersSafely();
    });
  }

  @override
  void dispose() {
    _taskSubscription?.cancel();
    super.dispose();
  }

  DateTime _currentWeekStart = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  Map<String, List<Task>> _weeklyTasks = {};
  bool _isLoading = false;

  DateTime get currentWeekStart => _currentWeekStart;
  DateTime get selectedDay => _selectedDay;
  bool get isLoading => _isLoading;

  List<DateTime> get weekDays {
    return List.generate(7, (i) =>
      DateTime(_currentWeekStart.year, _currentWeekStart.month, _currentWeekStart.day + i),
    );
  }

  List<Task> getTasksForDay(DateTime day) {
    final key = _dateKey(day);
    return _weeklyTasks[key] ?? [];
  }

  List<Task> get selectedDayTasks => getTasksForDay(_selectedDay);

  Future<void> selectDay(DateTime day) async {
    _selectedDay = day;
    notifyListenersSafely();
  }

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
    // Handled by stream
  }

  Future<void> addScheduleTask(Task task) async {
    await addTaskUseCase(task);
  }

  Future<void> deleteScheduleTask(String id) async {
    await deleteTaskUseCase(id);
  }

  Future<void> toggleScheduleTask(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await updateTaskUseCase(updated);
  }

  DateTime _getMonday(DateTime date) {
    final weekday = date.weekday;
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
