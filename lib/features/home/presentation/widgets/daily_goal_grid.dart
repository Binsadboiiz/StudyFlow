import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';

/// Widget hiển thị danh sách các mục tiêu (Tasks) dưới dạng Grid bên dưới lịch.
class DailyGoalGrid extends StatelessWidget {
  const DailyGoalGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer lắng nghe dữ liệu từ HomeViewModel
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        // 1. Trạng thái Đang tải dữ liệu: Hiển thị vòng quay loading
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Trạng thái Không có dữ liệu: Hiển thị câu thông báo
        if (viewModel.dailyTasks.isEmpty) {
          return const Center(
            child: Text('No goals for this day. Take a rest!'),
          );
        }

        // 3. Trạng thái Có dữ liệu: Hiển thị danh sách task dưới dạng Grid
        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          // Cấu hình bố cục Grid (2 cột)
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Hiển thị 2 ô trên 1 hàng
            crossAxisSpacing: 16.0, // Khoảng cách giữa các cột
            mainAxisSpacing: 16.0, // Khoảng cách giữa các hàng
            childAspectRatio: 1.2, // Tỷ lệ khung hình (chiều rộng / chiều cao) của mỗi ô
          ),
          itemCount: viewModel.dailyTasks.length, // Tổng số lượng ô
          itemBuilder: (context, index) {
            // Lấy task tại vị trí thứ 'index'
            final task = viewModel.dailyTasks[index];
            
            // GestureDetector giúp bắt sự kiện tap (ấn) vào cả khối Card
            return GestureDetector(
              onTap: () {
                // Gọi viewmodel để đổi trạng thái hoàn thành (check/uncheck)
                viewModel.toggleTaskCompletion(task);
              },
              child: Card(
                elevation: 4, // Độ nổi của Card tạo hiệu ứng bóng đổ
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                // Nếu task đã xong thì đổi nền thành xanh nhạt, chưa xong thì màu trắng
                color: task.isCompleted ? Colors.green.shade100 : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon checkmark hiển thị ở góc trên cùng bên trái
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            task.isCompleted
                                ? Icons.check_circle // Biểu tượng đã check
                                : Icons.circle_outlined, // Biểu tượng chưa check (hình tròn rỗng)
                            color: task.isCompleted ? Colors.green : Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Tên của task
                      Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          // Thêm đường gạch ngang chữ nếu task đã hoàn thành
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis, // Cắt chữ bằng dấu ... nếu quá dài
                      ),
                      const SizedBox(height: 4),
                      // Phần mô tả của task (Expanded giúp nó chiếm phần khoảng trống còn lại)
                      Expanded(
                        child: Text(
                          task.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
