import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/features/home/presentation/screens/home_screen.dart';
import 'package:studyflow/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:studyflow/features/task/presentation/screens/task_screen.dart';
import 'package:studyflow/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:studyflow/features/streak/presentation/screens/streak_screen.dart';
import 'package:studyflow/features/schedule/presentation/viewmodels/schedule_viewmodel.dart';
import 'package:studyflow/features/task/presentation/viewmodels/task_viewmodel.dart';
import 'package:studyflow/features/home/presentation/screens/settings_screen.dart';
import 'package:studyflow/features/task/presentation/widgets/task_form_modal.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/features/focus/presentation/screens/focus_screen.dart';

/// `MainScreen` is the root screen containing the bottom navigation bar
/// and managing navigation between the main screens of the app.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  // Labels for bottom navigation items using rounded icons for premium look
  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.grid_view_rounded, label: 'Home'),
    _NavItem(icon: Icons.hourglass_empty_rounded, label: 'Focus'),
    _NavItem(icon: Icons.assignment_rounded, label: 'Tasks'),
    _NavItem(icon: Icons.event_note_rounded, label: 'Schedule'),
    _NavItem(icon: Icons.local_fire_department_rounded, label: 'Streak'),
    _NavItem(icon: Icons.settings_rounded, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    const screens = [
      HomeScreen(),
      FocusScreen(),
      TaskScreen(),
      ScheduleScreen(),
      StreakScreen(),
      SettingsScreen(),
    ];
    final currentIndex = _currentIndex.clamp(0, screens.length - 1);

    return Scaffold(
      extendBody: true, // Content flows behind the floating dock
      backgroundColor: Colors.transparent,
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 14.0, right: 14.0, bottom: 14.0),
          child: GlassCard(
            borderRadius: 32,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  // Left icon group
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(navItem: _navItems[0], index: 0),
                        _buildNavItem(navItem: _navItems[1], index: 1),
                        _buildNavItem(navItem: _navItems[2], index: 2),
                      ],
                    ),
                  ),
                  
                  // Center Floating Action Button (integrated in dock)
                  GestureDetector(
                    onTap: () => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const TaskFormModal(),
                    ),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, AppColors.accentLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),

                  // Right icon group
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavItem(navItem: _navItems[3], index: 3),
                        _buildNavItem(navItem: _navItems[4], index: 4),
                        _buildNavItem(navItem: _navItems[5], index: 5),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to create each button in the dock with a modern scale animation
  Widget _buildNavItem({required _NavItem navItem, required int index}) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unselectedColor = isDark ? Colors.grey.shade500 : const Color.fromARGB(255, 51, 51, 51);

    return Expanded(
      child: GestureDetector(
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with zoom effect when selected
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              transform: Matrix4.identity()..scaleByDouble(isSelected ? 1.2 : 1.0, isSelected ? 1.2 : 1.0, 1.0, 1.0),
              child: Icon(
                navItem.icon,
                color: isSelected ? AppColors.accent : unselectedColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            // Tab subtitle
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.accent : unselectedColor,
              ),
              child: Text(
                navItem.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reloads data for the newly selected tab to ensure synchronization
  void _reloadTabData(int tabIndex) {
    switch (tabIndex) {
      case 0: // Home
        context.read<HomeViewModel>().refreshTasks();
        break;
      case 2: // Tasks
        context.read<TaskViewmodel>().loadTask(
          context.read<TaskViewmodel>().selectedDate,
        );
        break;
      case 3: // Schedule
        context.read<ScheduleViewmodel>().loadWeekTasks();
        break;
    }
  }
}

/// Model for a navigation item
class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
