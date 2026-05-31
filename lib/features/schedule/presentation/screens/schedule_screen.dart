import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:studyflow/features/schedule/presentation/viewmodels/schedule_viewmodel.dart';
import 'package:studyflow/features/schedule/presentation/widgets/day_tab_bar.dart';
import 'package:studyflow/features/schedule/presentation/widgets/timeline_view.dart';
import 'package:studyflow/features/schedule/presentation/widgets/add_schedule_task_dialog.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/presentation/viewmodels/task_viewmodel.dart';
import 'package:studyflow/shared/widgets/loading/task_skeleton.dart';
import 'package:studyflow/core/widgets/glass_card.dart';

/// [ScheduleScreen] is a screen for viewing the weekly schedule.
/// It provides users with an overview of tasks throughout the 7 days,
/// supports navigating between weeks, and displays tasks in a Timeline format.
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScheduleViewmodel>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Schedule', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                  GestureDetector(
                    onTap: () => _showAddDialog(context, vm),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.add_rounded, color: AppColors.accent, size: 22),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            DayTabBar(
              weekDays: vm.weekDays,
              selectedDay: vm.selectedDay,
              currentWeekStart: vm.currentWeekStart,
              onDaySelected: (day) => vm.selectDay(day),
              onPreviousWeek: () => vm.navigateWeek(-1),
              onNextWeek: () => vm.navigateWeek(1),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildDaySummary(vm),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: vm.isLoading
                  ? TaskSkeleton.buildList(count: 3)
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

  /// Builds a summary of tasks for the selected day.
  Widget _buildDaySummary(ScheduleViewmodel vm) {
    final tasks = vm.selectedDayTasks;
    final scheduledTasks = tasks.where((t) => t.hasTimeSlot).length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final theme = Theme.of(context);

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: 14,
      child: Row(children: [
        _buildSummaryItem(icon: Icons.event_note_rounded, value: '$scheduledTasks', label: 'Scheduled'),
        Container(width: 1, height: 30, color: theme.dividerColor, margin: const EdgeInsets.symmetric(horizontal: 16)),
        _buildSummaryItem(icon: Icons.check_circle_outline, value: '$completed', label: 'Done'),
        Container(width: 1, height: 30, color: theme.dividerColor, margin: const EdgeInsets.symmetric(horizontal: 16)),
        _buildSummaryItem(icon: Icons.pending_outlined, value: '${tasks.length - completed}', label: 'Pending'),
      ]),
    );
  }

  /// Builds an individual summary item (e.g., Scheduled, Done, Pending).
  Widget _buildSummaryItem({required IconData icon, required String value, required String label}) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    return Expanded(
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.accent.withValues(alpha: 0.7)),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
          Text(label, style: TextStyle(fontSize: 10, color: ext.subtext, fontWeight: FontWeight.w500)),
        ]),
      ]),
    );
  }

  /// Shows the dialog to add a new task to the schedule.
  Future<void> _showAddDialog(BuildContext context, ScheduleViewmodel vm, {int? initialHour}) async {
    final result = await showDialog<Task>(context: context, builder: (context) => AddScheduleTaskDialog(selectedDay: vm.selectedDay, initialHour: initialHour));
    if (result != null) {
      await vm.addScheduleTask(result);
      if (context.mounted) {
        context.read<TaskViewmodel>().loadTask(context.read<TaskViewmodel>().selectedDate);
        context.read<HomeViewModel>().refreshTasks();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task added to schedule!'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.accent));
      }
    }
  }

  /// Shows a confirmation dialog before deleting a task.
  Future<void> _confirmDelete(BuildContext context, ScheduleViewmodel vm, Task task) async {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task'),
        content: Text('Delete "${task.title}" from schedule?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: TextStyle(color: ext.subtext))),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await vm.deleteScheduleTask(task.id);
      if (context.mounted) {
        context.read<TaskViewmodel>().loadTask(context.read<TaskViewmodel>().selectedDate);
        context.read<HomeViewModel>().refreshTasks();
      }
    }
  }
}
