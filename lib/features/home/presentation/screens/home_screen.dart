import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/home_calendar.dart';
import '../widgets/daily_goal_list.dart';
import '../../../../features/task/presentation/screens/task_screen.dart';

/// Màn hình chính của ứng dụng (View trong MVVM).
/// Nhiệm vụ duy nhất của nó là ghép nối các Widget nhỏ hơn lại với nhau
/// để tạo thành một màn hình hoàn chỉnh, không chứa logic nghiệp vụ phức tạp ở đây.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Để background tràn lên trên dưới AppBar
      // AppBar hiện đại với hiệu ứng kính mờ (Glassmorphism)
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.2),
        elevation: 0,
        toolbarHeight: 80,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const CircleAvatar(
                radius: 22,
                backgroundColor: Colors.blueAccent,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Have a good day,',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'StudyFlow 👋',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.black87),
                onPressed: () {},
              ),
            ),
          )
        ],
      ),
      
      // Nội dung chính: Toàn bộ màn hình scroll được (Calendar + Task list)
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/backgrounds/background_app.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          bottom: false, // Không cần thiết lập SafeArea cho bottom vì có extendBody rồi
          child: CustomScrollView(
            slivers: [
              // Khoảng trống đẩy nội dung xuống dưới AppBar
              const SliverToBoxAdapter(
                child: SizedBox(height: 70),
              ),
              // 1. Phần Widget hiển thị lịch
              const SliverToBoxAdapter(
                child: HomeCalendar(),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 8),
              ),
              // 2. Phần Widget hiển thị danh sách mục tiêu hằng ngày
              // Dùng SliverFillRemaining với hasScrollBody: false để DailyGoalList
              // chiếm phần còn lại và scroll cùng Calendar
              const SliverToBoxAdapter(
                child: DailyGoalList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
