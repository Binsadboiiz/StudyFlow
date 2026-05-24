import 'dart:async';
import 'package:flutter/material.dart';
import 'package:studyflow/core/utils/safe_change_notifier.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/usecase/add__task.dart';
import 'package:studyflow/features/task/domain/usecase/delete_task.dart';
import 'package:studyflow/features/task/domain/usecase/get_task.dart';
import 'package:studyflow/features/task/domain/usecase/update_task.dart';

class TaskViewmodel extends ChangeNotifier with SafeChangeNotifier {
  final AddTask addTaskUseCase;
  final DeleteTask deleteTaskUseCase;
  final GetTask getTaskUseCase;
  final UpdateTask updateTaskUseCase;

  StreamSubscription? _taskSubscription;
  List<Task> _allTasks = [];

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

  List<Task> tasks = [];
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    _updateTasks();
    notifyListenersSafely();
  }

  Future<void> loadTask(DateTime date) async {
    _selectedDate = date;
    _updateTasks();
    notifyListenersSafely();
  }

  void _updateTasks() {
    tasks = _allTasks.where((task) {
      return task.date.year == _selectedDate.year &&
             task.date.month == _selectedDate.month &&
             task.date.day == _selectedDate.day;
    }).toList();
  }

  Future<void> addTask(Task task) async {
    await addTaskUseCase(task);
  }

  Future<void> deleteTask(String id, DateTime date) async {
    await deleteTaskUseCase(id);
  }

  Future<void> toggleTask(Task task) async {
    final updateTask = task.copyWith(
      isCompleted: !task.isCompleted,
    );
    await updateTaskUseCase(updateTask);
  }

  Future<void> updateTask(Task task) async {
    await updateTaskUseCase(task);
  }
}