import 'package:flutter/material.dart';
import 'package:studyflow/core/utils/safe_change_notifier.dart';
import '../../../../features/task/domain/entities/task.dart';
import '../../../../features/task/domain/repositories/task_repository.dart';

/// ViewModel chịu trách nhiệm xử lý logic và lưu trữ state (trạng thái) cho màn hình Home.
/// Extends ChangeNotifier để có thể thông báo cho UI (View) biết khi nào cần build lại.
class HomeViewModel extends ChangeNotifier with SafeChangeNotifier {
  final TaskRepository _taskRepository;

  // Constructor nhận vào một TaskRepository (Dependency Injection).
  // Ngay khi khởi tạo, gọi hàm load dữ liệu của ngày hiện tại ngay lập tức.
  HomeViewModel({required TaskRepository taskRepository})
      : _taskRepository = taskRepository {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasksForSelectedDate();
    });
  }

  // --- CÁC BIẾN STATE NỘI BỘ (Private) ---
  DateTime _selectedDate = DateTime.now(); // Ngày người dùng đang click chọn trên lịch
  DateTime _focusedDate = DateTime.now();  // Ngày để lịch biết tháng/tuần nào đang được focus
  List<Task> _dailyTasks = [];             // Danh sách task hiển thị trên UI bên dưới lịch
  bool _isLoading = false;                 // Cờ cho biết đang tải dữ liệu hay không (để hiện vòng tròn quay)

  // --- CÁC GETTER CHO UI ---
  // UI chỉ được phép đọc dữ liệu qua các getter này, không được phép sửa trực tiếp (bảo vệ state).
  DateTime get selectedDate => _selectedDate;
  DateTime get focusedDate => _focusedDate;
  List<Task> get dailyTasks => _dailyTasks;
  bool get isLoading => _isLoading;

  /// Hàm được gọi khi người dùng bấm vào một ngày cụ thể trên Calendar
  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    _selectedDate = selectedDay;
    _focusedDate = focusedDay;
    _loadTasksForSelectedDate(); // Tải lại danh sách task của ngày mới chọn
  }

  /// Gọi Repository để lấy dữ liệu (tasks) tương ứng với ngày đang chọn (_selectedDate)
  Future<void> _loadTasksForSelectedDate() async {
    _isLoading = true; // Bật cờ loading
    notifyListenersSafely();

    try {
      // Gọi repository lấy dữ liệu (chỗ này sau này có thể là gọi Isar db hoặc API)
      _dailyTasks = await _taskRepository.getTasksForDate(_selectedDate);
    } catch (e) {
      _dailyTasks = [];
      // Có thể xử lý hiển thị popup báo lỗi ở đây
    } finally {
      _isLoading = false; // Tắt cờ loading
      notifyListenersSafely();
    }
  }

  /// Public method để các ViewModel khác có thể trigger reload (đồng bộ dữ liệu)
  Future<void> refreshTasks() async {
    await _loadTasksForSelectedDate();
  }

  /// Hàm đổi trạng thái hoàn thành (Check/Uncheck) của một task khi người dùng ấn vào task đó
  Future<void> toggleTaskCompletion(Task task) async {
    // Tạo bản sao của task hiện tại nhưng đảo ngược trạng thái isCompleted (true thành false, false thành true)
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    
    // Gọi repository để lưu thay đổi xuống database
    await _taskRepository.updateTask(updatedTask);
    
    // Sau khi cập nhật DB thành công, tải lại danh sách để UI hiển thị dấu checkmark
    await _loadTasksForSelectedDate();
  }
}
