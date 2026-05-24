import '../entities/task.dart';

/// Interface (Giao thức) định nghĩa các thao tác lấy/lưu dữ liệu liên quan đến Task.
/// Domain Layer chỉ định nghĩa interface này, không quan tâm nó lấy dữ liệu từ đâu (API hay Database local).
/// Giúp tách biệt logic ứng dụng khỏi công nghệ cơ sở dữ liệu.
abstract class TaskRepository {
  /// Lấy tất cả task của người dùng dưới dạng Stream (Real-time updates)
  Stream<List<Task>> getTasksStream();
  
  /// Thêm một task mới vào hệ thống
  Future<void> addTask(Task task);
  
  /// Cập nhật thông tin một task đã có (ví dụ như đánh dấu hoàn thành/chưa hoàn thành)
  Future<void> updateTask(Task task);
  
  /// Xóa một task dựa vào ID
  Future<void> deleteTask(String id);
}
