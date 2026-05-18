import 'package:flutter/material.dart';
import 'package:studyflow/core/utils/safe_change_notifier.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/usecase/add__task.dart';
import 'package:studyflow/features/task/domain/usecase/delete_task.dart';
import 'package:studyflow/features/task/domain/usecase/get_task.dart';
import 'package:studyflow/features/task/domain/usecase/update_task.dart';

/// ViewModel chịu trách nhiệm quản lý trạng thái của màn hình Task (TaskScreen)
/// Cung cấp dữ liệu (tasks) và các phương thức xử lý logic (thêm, sửa, xóa) cho View.
class TaskViewmodel extends ChangeNotifier with SafeChangeNotifier {
  // Các UseCase chứa logic nghiệp vụ tương ứng
  final AddTask addTaskUseCase;
  final DeleteTask deleteTaskUseCase;
  final GetTask getTaskUseCase;
  final UpdateTask updateTaskUseCase;

  TaskViewmodel({
    required this.addTaskUseCase,
    required this.deleteTaskUseCase,
    required this.getTaskUseCase,
    required this.updateTaskUseCase,
  });

  // Danh sách các công việc hiện tại (State của View)
  List<Task> tasks = [];

  // Ngày đang được chọn trên TaskScreen (mặc định = hôm nay)
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  /// Chọn ngày mới và tải lại danh sách task cho ngày đó
  Future<void> selectDate(DateTime date) async {
    _selectedDate = date;
    await loadTask(date);
  }

  /// Tải danh sách công việc theo ngày
  Future<void> loadTask(DateTime date) async {
    _selectedDate = date;
    tasks = await getTaskUseCase(date);
    notifyListenersSafely();
  }

  /// Thêm một công việc mới và tải lại danh sách
  Future<void> addTask(Task task) async {
    await addTaskUseCase(task);
    await loadTask(task.date);
  }

  /// Xóa một công việc theo ID và tải lại danh sách
  Future<void> deleteTask(int id, DateTime date) async {
    await deleteTaskUseCase(id);
    await loadTask(date);
  }

  /// Đánh dấu hoàn thành / chưa hoàn thành công việc và tải lại danh sách
  Future<void> toggleTask(Task task) async {
    final updateTask = task.copyWith(
      isCompleted: !task.isCompleted,
    );
    await updateTaskUseCase(updateTask);
    await loadTask(task.date);
  }
}