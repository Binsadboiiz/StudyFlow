import '../../domain/entities/task.dart';
import '../../domain/repositories/task_repository.dart';

/// Class thực thi (Implementation) của TaskRepository.
/// Thuộc phần Data Layer. Hiện tại đang sử dụng dữ liệu giả (Mock) để test giao diện.
/// Sau này sẽ thay thế class này bằng IsarTaskRepositoryImpl để lưu dữ liệu thực tế vào máy.
class MockTaskRepositoryImpl implements TaskRepository {
  // Danh sách dữ liệu giả định sẵn để hiển thị ngay khi mở app
  final List<Task> _mockTasks = [
    Task(
      id: 1,
      title: 'Read Clean Architecture',
      description: 'Read chapter 1 and 2 of Clean Architecture book',
      date: DateTime.now(),
    ),
    Task(
      id: 2,
      title: 'Practice Flutter',
      description: 'Build a small app using Provider',
      date: DateTime.now(),
      isCompleted: true, // Task này đã được đánh dấu hoàn thành sẵn
    ),
    Task(
      id: 3,
      title: 'Exercise',
      description: '30 minutes of cardio',
      date: DateTime.now().add(const Duration(days: 1)), // Task dành cho ngày mai
    ),
  ];

  @override
  Future<List<Task>> getTasksForDate(DateTime date) async {
    // Giả lập độ trễ của mạng hoặc database (300ms) để UI có thời gian hiện vòng tròn loading
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Lọc ra và trả về các task có ngày/tháng/năm trùng với ngày được truyền vào
    return _mockTasks.where((task) => 
      task.date.year == date.year &&
      task.date.month == date.month &&
      task.date.day == date.day
    ).toList();
  }

  @override
  Future<void> addTask(Task task) async {
    // Giả lập delay và thêm task vào danh sách
    await Future.delayed(const Duration(milliseconds: 300));
    _mockTasks.add(task);
  }

  @override
  Future<void> updateTask(Task task) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Tìm vị trí của task cần cập nhật trong danh sách
    final index = _mockTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _mockTasks[index] = task; // Ghi đè task cũ bằng task mới (chứa trạng thái cập nhật)
    }
  }

  @override
  Future<void> deleteTask(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockTasks.removeWhere((t) => t.id == id); // Xóa task khỏi danh sách dựa trên ID
  }
}
