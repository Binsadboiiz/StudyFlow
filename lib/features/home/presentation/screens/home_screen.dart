import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../widgets/home_calendar.dart';
import '../widgets/daily_goal_list.dart';

/// Màn hình chính của ứng dụng (View trong MVVM).
/// Nhiệm vụ duy nhất của nó là ghép nối các Widget nhỏ hơn lại với nhau
/// để tạo thành một màn hình hoàn chỉnh, không chứa logic nghiệp vụ phức tạp ở đây.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthViewmodel>().currentUser;
    final displayName = user?.fullName ?? 'Guest';
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true, // Để background tràn lên trên dưới AppBar
      // AppBar hiện đại với hiệu ứng kính mờ (Glassmorphism)
      appBar: AppBar(
        backgroundColor: isDark 
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.2),
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
                border: Border.all(
                  color: isDark ? Colors.grey.shade700 : Colors.white, 
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage('assets/images/8b4635fd93dc6e874f686435da83a210.jpg'),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Have a good day,',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$displayName 👋',
                  style: TextStyle(
                    fontSize: 20,
                    color: theme.colorScheme.onSurface,
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
                color: isDark 
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.notifications_none_rounded, 
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () {},
              ),
            ),
          )
        ],
      ),
      
      // Nội dung chính: Toàn bộ màn hình scroll được (Calendar + Task list)
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : null,
          image: isDark ? null : const DecorationImage(
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
