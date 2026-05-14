/// Lớp đại diện cho một mục tiêu/công việc hằng ngày (Entity trong Clean Architecture).
/// Đây là lớp dữ liệu cốt lõi, không phụ thuộc vào bất kỳ framework hoặc UI nào.
class Task {
  final int id; // ID duy nhất của task (sử dụng kiểu int để dễ dàng tương thích với Isar Database sau này)
  final String title; // Tiêu đề ngắn gọn của mục tiêu
  final String description; // Mô tả chi tiết thêm nếu cần
  final DateTime date; // Ngày thực hiện mục tiêu này
  final bool isCompleted; // Trạng thái hoàn thành (true là đã xong, false là chưa xong)

  // Constructor yêu cầu cung cấp các thông tin cơ bản, mặc định chưa hoàn thành (isCompleted = false)
  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });

  /// Hàm hỗ trợ tạo ra một bản sao (copy) của Task hiện tại với một vài thuộc tính thay đổi.
  /// Rất hữu ích khi chúng ta muốn thay đổi trạng thái (ví dụ: cập nhật isCompleted thành true)
  /// mà không làm thay đổi object gốc (Đảm bảo tính bất biến - Immutable state).
  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    bool? isCompleted,
  }) {
    return Task(
      id: id ?? this.id, // Nếu không truyền giá trị mới vào thì giữ nguyên giá trị cũ
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
