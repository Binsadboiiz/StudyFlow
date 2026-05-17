import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';

/// Widget hiển thị danh sách các mục tiêu (Tasks) dưới dạng List (từng hàng/row) bên dưới lịch.
/// Sử dụng Column thay vì ListView để có thể scroll cùng với Calendar trong CustomScrollView.
class DailyGoalList extends StatelessWidget {
  const DailyGoalList({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer lắng nghe dữ liệu từ HomeViewModel
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        // 1. Trạng thái Đang tải dữ liệu
        if (viewModel.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Trạng thái Không có dữ liệu
        if (viewModel.dailyTasks.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: Text('No goals for this day. Take a rest!'),
            ),
          );
        }

        // 3. Trạng thái Có dữ liệu: Hiển thị danh sách task dưới dạng Column (mỗi task là 1 hàng ngang)
        // Dùng Column thay vì ListView để nằm trong CustomScrollView mà không bị conflict scroll
        return Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: 100.0, // Thêm khoảng trống dưới cùng để không bị che bởi BottomAppBar
          ),
          child: Column(
            children: List.generate(viewModel.dailyTasks.length, (index) {
              final task = viewModel.dailyTasks[index];

              return Padding(
                padding: EdgeInsets.only(bottom: index < viewModel.dailyTasks.length - 1 ? 12.0 : 0),
                child: GestureDetector(
                  onTap: () {
                    // Gọi viewmodel để đổi trạng thái hoàn thành (check/uncheck)
                    viewModel.toggleTaskCompletion(task);
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    color: task.isCompleted ? Colors.green.shade100 : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều dọc
                        children: [
                          // Icon checkmark bên trái
                          Icon(
                            task.isCompleted
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: task.isCompleted ? Colors.green : Colors.grey,
                            size: 28,
                          ),
                          const SizedBox(width: 16.0),
                          
                          // Nội dung chính (Tiêu đề và mô tả) chiếm phần còn lại
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                // Chỉ hiển thị mô tả nếu nó không rỗng
                                if (task.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    task.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
