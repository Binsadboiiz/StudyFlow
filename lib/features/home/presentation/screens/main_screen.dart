import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/features/home/presentation/screens/home_screen.dart';
import 'package:studyflow/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:studyflow/features/task/presentation/screens/task_screen.dart';
import 'package:studyflow/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:studyflow/features/schedule/presentation/viewmodels/schedule_viewmodel.dart';
import 'package:studyflow/features/task/presentation/viewmodels/task_viewmodel.dart';
import 'package:studyflow/features/home/presentation/screens/settings_screen.dart';
import 'package:studyflow/features/task/presentation/widgets/task_form_modal.dart';
import 'package:studyflow/core/theme/app_colors.dart';

/// `MainScreen` là màn hình gốc chứa thanh điều hướng dưới (Bottom Navigation Bar)
/// và quản lý việc chuyển đổi giữa các màn hình chính của ứng dụng: Home, Task, Schedule, Settings.
/// Màn hình này cũng chứa nút FloatingActionButton (FAB) để thêm nhanh công việc.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TaskScreen(),
    const ScheduleScreen(),
    const SettingsScreen(),
  ];

  // Labels cho BottomAppBar items
  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_outlined, label: 'Home'),
    _NavItem(icon: Icons.article_outlined, label: 'Tasks'),
    _NavItem(icon: Icons.calendar_view_week_rounded, label: 'Schedule'),
    _NavItem(icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBody: true, // Cho phép nội dung tràn xuống dưới BottomAppBar
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const TaskFormModal(),
        ),
        backgroundColor: AppColors.accent,
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0, // Khoảng cách lõm xuống
        color: theme.bottomAppBarTheme.color,
        elevation: 10,
        shadowColor: isDark ? Colors.black87 : Colors.black45,
        child: SizedBox(
          height: 65,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nhóm icon bên trái
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(navItem: _navItems[0], index: 0),
                    _buildNavItem(navItem: _navItems[1], index: 1),
                  ],
                ),
              ),
              // Khoảng trống ở giữa cho FloatingActionButton
              const SizedBox(width: 48),
              // Nhóm icon bên phải
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(navItem: _navItems[2], index: 2),
                    _buildNavItem(navItem: _navItems[3], index: 3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm tạo từng nút trong BottomAppBar kèm animation + subtitle
  Widget _buildNavItem({required _NavItem navItem, required int index}) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unselectedColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (_currentIndex == index) return;
        setState(() {
          _currentIndex = index;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _reloadTabData(index);
        });
      },
      child: SizedBox(
        height: double.infinity,
        width: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon với hiệu ứng phóng to khi được chọn
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              transform: Matrix4.identity()..scale(isSelected ? 1.15 : 1.0),
              child: Icon(
                navItem.icon,
                color: isSelected ? AppColors.accent : unselectedColor,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            // Subtitle text
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.accent : unselectedColor,
              ),
              child: Text(navItem.label),
            ),
          ],
        ),
      ),
    );
  }

  /// Reload data cho tab vừa chuyển sang để đảm bảo đồng bộ
  void _reloadTabData(int tabIndex) {
    switch (tabIndex) {
      case 0: // Home
        context.read<HomeViewModel>().refreshTasks();
        break;
      case 1: // Tasks
        context.read<TaskViewmodel>().loadTask(
          context.read<TaskViewmodel>().selectedDate,
        );
        break;
      case 2: // Schedule
        context.read<ScheduleViewmodel>().loadWeekTasks();
        break;
    }
  }

}

/// Model cho navigation item
class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
