import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/features/home/presentation/screens/home_screen.dart';
import 'package:studyflow/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:studyflow/features/task/presentation/screens/task_screen.dart';
import 'package:studyflow/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:studyflow/features/schedule/presentation/viewmodels/schedule_viewmodel.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/presentation/viewmodels/task_viewmodel.dart';

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
    const Center(child: Text('Settings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
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
    return Scaffold(
      extendBody: true, // Cho phép nội dung tràn xuống dưới BottomAppBar
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskModal(context),
        backgroundColor: const Color(0xFF2E7D32), 
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10.0, // Khoảng cách lõm xuống
        color: Colors.white,
        elevation: 10,
        shadowColor: Colors.black45,
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
        // Đồng bộ dữ liệu: reload ViewModel của tab khi chuyển sang
        _reloadTabData(index);
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
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade400,
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
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade400,
              ),
              child: Text(navItem.label),
            ),
          ],
        ),
      ),
    );
  }

  // Hàm hiển thị Modal thêm Task mới (với date picker + time picker)
  void _showAddTaskModal(BuildContext context) {
    final titleController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Để modal đẩy lên khi bàn phím xuất hiện
      backgroundColor: Colors.transparent, // Làm nền trong suốt để bo góc đẹp hơn
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final today = DateTime.now();

            return SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom, // Tránh bàn phím che
                  left: 20,
                  right: 20,
                  top: 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Thanh kéo nhỏ ở trên cùng (UI UX hiện đại)
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Add new task',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 20),
                    // ===== TITLE INPUT =====
                    TextField(
                      controller: titleController,
                      autofocus: true, // Tự động mở bàn phím
                      decoration: InputDecoration(
                        hintText: 'What do you want to do...?',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ===== DATE PICKER CHIP =====
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate.isBefore(DateTime(today.year, today.month, today.day))
                              ? DateTime(today.year, today.month, today.day)
                              : selectedDate,
                          firstDate: DateTime(today.year, today.month, today.day),
                          lastDate: DateTime(today.year + 1, today.month, today.day),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF2E7D32),
                                  onPrimary: Colors.white,
                                  surface: Colors.white,
                                  onSurface: Colors.black87,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF2E7D32)),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date',
                                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isSameDay(selectedDate, today)
                                      ? 'Today, ${DateFormat('dd MMM yyyy').format(selectedDate)}'
                                      : DateFormat('EEEE, dd MMM yyyy').format(selectedDate),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ===== TIME PICKERS =====
                    Row(
                      children: [
                        // Start time
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: startTime ?? TimeOfDay.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF2E7D32),
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setModalState(() {
                                  startTime = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.schedule_rounded, size: 18, color: Color(0xFF2E7D32)),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Start',
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        startTime != null
                                            ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
                                            : 'Optional',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: startTime != null ? Colors.black87 : Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // End time
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: endTime ?? (startTime != null 
                                    ? TimeOfDay(hour: (startTime!.hour + 1) % 24, minute: startTime!.minute)
                                    : TimeOfDay.now()),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: Color(0xFF2E7D32),
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                setModalState(() {
                                  endTime = picked;
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.schedule_rounded, size: 18, color: Color(0xFF2E7D32)),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'End',
                                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w600),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        endTime != null
                                            ? '${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}'
                                            : 'Optional',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: endTime != null ? Colors.black87 : Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ===== ADD BUTTON =====
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) return;
                          
                          final vm = context.read<TaskViewmodel>();

                          // Build startTime/endTime DateTime objects
                          DateTime? startDateTime;
                          DateTime? endDateTime;
                          if (startTime != null) {
                            startDateTime = DateTime(
                              selectedDate.year, selectedDate.month, selectedDate.day,
                              startTime!.hour, startTime!.minute,
                            );
                          }
                          if (endTime != null) {
                            endDateTime = DateTime(
                              selectedDate.year, selectedDate.month, selectedDate.day,
                              endTime!.hour, endTime!.minute,
                            );
                          }

                          final task = Task(
                            id: DateTime.now().millisecondsSinceEpoch,
                            title: titleController.text.trim(),
                            description: "",
                            date: DateTime(selectedDate.year, selectedDate.month, selectedDate.day),
                            startTime: startDateTime,
                            endTime: endDateTime,
                          );
                          
                          await vm.addTask(task);
                          // Đồng bộ: reload Schedule và Home sau khi thêm task
                          if (context.mounted) {
                            context.read<ScheduleViewmodel>().loadWeekTasks();
                            context.read<HomeViewModel>().refreshTasks();
                            Navigator.pop(context); // Đóng modal sau khi thêm xong
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Added new task!'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Color(0xFF2E7D32),
                              ),
                            );
                          }
                        },
                        child: const Text('Add now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

/// Model cho navigation item
class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
