import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:studyflow/features/schedule/presentation/viewmodels/schedule_viewmodel.dart';
import 'package:studyflow/features/schedule/presentation/widgets/day_tab_bar.dart';
import 'package:studyflow/features/schedule/presentation/widgets/timeline_view.dart';
import 'package:studyflow/features/schedule/presentation/widgets/add_schedule_task_dialog.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/presentation/viewmodels/task_viewmodel.dart';

/// Màn hình Schedule hiển thị bảng lịch trình 7 ngày trong tuần.
/// Cho phép xem timeline theo giờ và thêm task vào khung giờ cụ thể.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScheduleViewmodel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // ===== HEADER =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Schedule',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  // Nút thêm task nhanh
                  GestureDetector(
                    onTap: () => _showAddDialog(context, vm),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Color(0xFF2E7D32),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ===== DAY TAB BAR =====
            DayTabBar(
              weekDays: vm.weekDays,
              selectedDay: vm.selectedDay,
              currentWeekStart: vm.currentWeekStart,
              onDaySelected: (day) => vm.selectDay(day),
              onPreviousWeek: () => vm.navigateWeek(-1),
              onNextWeek: () => vm.navigateWeek(1),
            ),
            const SizedBox(height: 12),

            // ===== SUMMARY =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildDaySummary(vm),
            ),
            const SizedBox(height: 8),

            // ===== TIMELINE =====
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
                  : TimelineView(
                      tasks: vm.selectedDayTasks,
                      selectedDay: vm.selectedDay,
                      onHourTapped: (hour) => _showAddDialog(context, vm, initialHour: hour),
                      onTaskToggle: (task) async {
                        await vm.toggleScheduleTask(task);
                        if (!context.mounted) return;
                        final taskVm = context.read<TaskViewmodel>();
                        final homeVm = context.read<HomeViewModel>();
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!context.mounted) return;
                          taskVm.loadTask(taskVm.selectedDate);
                          homeVm.refreshTasks();
                        });
                      },
                      onTaskDelete: (task) => _confirmDelete(context, vm, task),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Summary card cho ngày đang chọn
  Widget _buildDaySummary(ScheduleViewmodel vm) {
    final tasks = vm.selectedDayTasks;
    final scheduledTasks = tasks.where((t) => t.hasTimeSlot).length;
    final completed = tasks.where((t) => t.isCompleted).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildSummaryItem(
            icon: Icons.event_note_rounded,
            value: '$scheduledTasks',
            label: 'Scheduled',
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          _buildSummaryItem(
            icon: Icons.check_circle_outline,
            value: '$completed',
            label: 'Done',
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          _buildSummaryItem(
            icon: Icons.pending_outlined,
            value: '${tasks.length - completed}',
            label: 'Pending',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF2E7D32).withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Mở dialog thêm task
  Future<void> _showAddDialog(BuildContext context, ScheduleViewmodel vm, {int? initialHour}) async {
    final result = await showDialog<Task>(
      context: context,
      builder: (context) => AddScheduleTaskDialog(
        selectedDay: vm.selectedDay,
        initialHour: initialHour,
      ),
    );
    if (result != null) {
      await vm.addScheduleTask(result);
      // Đồng bộ sang Task và Home
      if (context.mounted) {
        context.read<TaskViewmodel>().loadTask(context.read<TaskViewmodel>().selectedDate);
        context.read<HomeViewModel>().refreshTasks();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task added to schedule!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    }
  }

  /// Xác nhận xóa task (long press)
  Future<void> _confirmDelete(BuildContext context, ScheduleViewmodel vm, Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}" from schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await vm.deleteScheduleTask(task.id);
      // Đồng bộ sang Task và Home
      if (context.mounted) {
        context.read<TaskViewmodel>().loadTask(context.read<TaskViewmodel>().selectedDate);
        context.read<HomeViewModel>().refreshTasks();
      }
    }
  }
}
