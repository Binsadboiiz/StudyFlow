import 'package:flutter/material.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/domain/usecase/add__task.dart';
import 'package:studyflow/features/task/domain/usecase/delete_task.dart';
import 'package:studyflow/features/task/domain/usecase/get_task.dart';
import 'package:studyflow/features/task/domain/usecase/update_task.dart';

/// ViewModel quản lý trạng thái của màn hình Schedule (Lịch trình tuần).
/// Load tasks cho 7 ngày trong tuần và hỗ trợ điều hướng qua lại giữa các tuần.
class ScheduleViewmodel extends ChangeNotifier {
  final AddTask addTaskUseCase;
  final DeleteTask deleteTaskUseCase;
  final GetTask getTaskUseCase;
  final UpdateTask updateTaskUseCase;

  ScheduleViewmodel({
    required this.addTaskUseCase,
    required this.deleteTaskUseCase,
    required this.getTaskUseCase,
    required this.updateTaskUseCase,
  }) {
    _initWeek();
  }

  // --- STATE ---
  DateTime _currentWeekStart = DateTime.now(); // Ngày đầu tuần (Thứ 2)
  DateTime _selectedDay = DateTime.now(); // Ngày đang chọn trên tab bar
  Map<String, List<Task>> _weeklyTasks = {}; // Key = 'yyyy-MM-dd', value = tasks
  bool _isLoading = false;

  // --- GETTERS ---
  DateTime get currentWeekStart => _currentWeekStart;
  DateTime get selectedDay => _selectedDay;
  bool get isLoading => _isLoading;

  /// Lấy danh sách 7 ngày trong tuần hiện tại (Mon-Sun)
  List<DateTime> get weekDays {
    return List.generate(7, (i) =>
      DateTime(_currentWeekStart.year, _currentWeekStart.month, _currentWeekStart.day + i),
    );
  }

  /// Lấy tasks của một ngày cụ thể
  List<Task> getTasksForDay(DateTime day) {
    final key = _dateKey(day);
    return _weeklyTasks[key] ?? [];
  }

  /// Lấy tasks của ngày đang chọn
  List<Task> get selectedDayTasks => getTasksForDay(_selectedDay);

  /// Khởi tạo tuần hiện tại
  void _initWeek() {
    _currentWeekStart = _getMonday(DateTime.now());
    _selectedDay = DateTime.now();
    loadWeekTasks();
  }

  /// Chọn một ngày trên tab bar
  Future<void> selectDay(DateTime day) async {
    _selectedDay = day;
    notifyListeners();
  }

  /// Điều hướng tuần (offset: -1 = tuần trước, 1 = tuần sau)
  Future<void> navigateWeek(int offset) async {
    _currentWeekStart = DateTime(
      _currentWeekStart.year,
      _currentWeekStart.month,
      _currentWeekStart.day + (offset * 7),
    );
    _selectedDay = _currentWeekStart;
    await loadWeekTasks();
  }

  /// Load tasks cho cả 7 ngày trong tuần
  Future<void> loadWeekTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _weeklyTasks = {};
      for (final day in weekDays) {
        final tasks = await getTaskUseCase(day);
        _weeklyTasks[_dateKey(day)] = tasks;
      }
    } catch (e) {
      _weeklyTasks = {};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Thêm task mới vào schedule
  Future<void> addScheduleTask(Task task) async {
    await addTaskUseCase(task);
    await loadWeekTasks();
  }

  /// Xóa task
  Future<void> deleteScheduleTask(int id) async {
    await deleteTaskUseCase(id);
    await loadWeekTasks();
  }

  /// Toggle hoàn thành
  Future<void> toggleScheduleTask(Task task) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await updateTaskUseCase(updated);
    await loadWeekTasks();
  }

  /// Lấy ngày thứ 2 của tuần chứa [date]
  DateTime _getMonday(DateTime date) {
    final weekday = date.weekday; // 1=Mon, 7=Sun
    return DateTime(date.year, date.month, date.day - (weekday - 1));
  }

  /// Tạo key dạng 'yyyy-MM-dd' cho Map
  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
