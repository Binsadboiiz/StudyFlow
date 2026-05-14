import 'package:flutter/material.dart';
import '../widgets/home_calendar.dart';
import '../widgets/daily_goal_grid.dart';

/// Màn hình chính của ứng dụng (View trong MVVM).
/// Nhiệm vụ duy nhất của nó là ghép nối các Widget nhỏ hơn lại với nhau
/// để tạo thành một màn hình hoàn chỉnh, không chứa logic nghiệp vụ phức tạp ở đây.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar hiển thị thanh tiêu đề ở trên cùng
      appBar: AppBar(
        title: const Text('StudyFlow', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      
      // Nội dung chính của màn hình: Được xếp dọc bằng Column
      body: const Column(
        children: [
          // 1. Phần Widget hiển thị lịch (chiếm khoảng trống vừa đủ ở trên)
          HomeCalendar(),
          SizedBox(height: 8), // Khoảng cách nhỏ giữa lịch và danh sách
          
          // 2. Phần Widget hiển thị danh sách mục tiêu hằng ngày.
          // Expanded bắt buộc DailyGoalGrid phải chiếm TOÀN BỘ khoảng trống còn lại bên dưới lịch
          Expanded(child: DailyGoalGrid()),
        ],
      ),
      
      // Nút hình tròn nổi ở góc dưới bên phải (Dùng để thêm Task mới)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Mở màn hình/popup để thêm Task mới
          // Tạm thời hiển thị một dòng thông báo nhỏ (SnackBar) dưới đáy màn hình
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Task: Coming Soon!')),
          );
        },
        child: const Icon(Icons.add), // Icon dấu cộng
      ),
    );
  }
}
