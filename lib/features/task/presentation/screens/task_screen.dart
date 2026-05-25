import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/presentation/viewmodels/task_viewmodel.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:studyflow/features/task/presentation/widgets/task_form_modal.dart';

/// `TaskScreen` là màn hình quản lý công việc hàng ngày.
/// Cho phép người dùng xem danh sách công việc theo từng ngày, thêm/sửa/xóa và đánh dấu hoàn thành.
class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  void initState() {
    super.initState();
    final vm = context.read<TaskViewmodel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      vm.loadTask(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TaskViewmodel>();
    final today = DateTime.now();
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Tasks', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                      const SizedBox(height: 4),
                      Text(
                        '${vm.tasks.where((t) => !t.isCompleted).length} remaining · ${vm.tasks.where((t) => t.isCompleted).length} completed',
                        style: TextStyle(fontSize: 14, color: ext.subtext, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  _buildDateChip(context, vm, today),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildDateSelector(vm, today),
            const SizedBox(height: 16),
            if (vm.tasks.isNotEmpty)
              Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: _buildProgressBar(vm)),
            const SizedBox(height: 8),
            Expanded(child: vm.tasks.isEmpty ? _buildEmptyState() : _buildTaskList(vm)),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip(BuildContext context, TaskViewmodel vm, DateTime today) {
    final isToday = _isSameDay(vm.selectedDate, today);
    return GestureDetector(
      onTap: () => _pickDate(context, vm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.accent),
            const SizedBox(width: 6),
            Text(
              isToday ? 'Today' : DateFormat('dd MMM').format(vm.selectedDate),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(TaskViewmodel vm, DateTime today) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 14,
        itemBuilder: (context, index) {
          final date = DateTime(today.year, today.month, today.day + index);
          final isSelected = _isSameDay(date, vm.selectedDate);
          final isCurrentDay = _isSameDay(date, today);
          return GestureDetector(
            onTap: () => vm.selectDate(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: 54,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : ext.cardBackground,
                borderRadius: BorderRadius.circular(16),
                border: isCurrentDay && !isSelected ? Border.all(color: AppColors.accent, width: 1.5) : null,
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('EEE').format(date).toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? Colors.white.withValues(alpha: 0.8) : ext.subtext)),
                  const SizedBox(height: 6),
                  Text('${date.day}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : theme.colorScheme.onSurface)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBar(TaskViewmodel vm) {
    final total = vm.tasks.length;
    final completed = vm.tasks.where((t) => t.isCompleted).length;
    final progress = total > 0 ? completed / total : 0.0;
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ext.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Progress', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ext.subtext)),
          Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.accent)),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: progress, backgroundColor: isDark ? AppColors.surfaceDark : Colors.grey.shade200, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent), minHeight: 8),
        ),
      ]),
    );
  }

  Widget _buildEmptyState() {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.task_alt_rounded, size: 64, color: ext.subtext.withValues(alpha: 0.5)),
        const SizedBox(height: 16),
        Text('No tasks for this day', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: ext.subtext)),
        const SizedBox(height: 8),
        Text('Tap + to add a new task', style: TextStyle(fontSize: 14, color: ext.subtext)),
        const SizedBox(height: 80),
      ]),
    );
  }

  Widget _buildTaskList(TaskViewmodel vm) {
    final pendingTasks = vm.tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = vm.tasks.where((t) => t.isCompleted).toList();
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return ListView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 100),
      children: [
        ...pendingTasks.map((task) => _buildTaskCard(task, vm)),
        if (completedTasks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Row(children: [
              Icon(Icons.check_circle_outline, size: 18, color: ext.subtext),
              const SizedBox(width: 8),
              Text('Completed (${completedTasks.length})', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ext.subtext)),
            ]),
          ),
          ...completedTasks.map((task) => _buildTaskCard(task, vm)),
        ],
      ],
    );
  }

  Widget _buildTaskCard(Task task, TaskViewmodel vm) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;
    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => vm.deleteTask(task.id, task.date),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(color: Colors.red.shade400, borderRadius: BorderRadius.circular(16)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: ext.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => TaskFormModal(task: task)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                GestureDetector(
                  onTap: () {
                    if (!task.isCompleted) {
                      context.read<AuthViewmodel>().updateStreak(DateTime.now());
                    }
                    vm.toggleTask(task);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 26, height: 26,
                    decoration: BoxDecoration(
                      color: task.isCompleted ? AppColors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: task.isCompleted ? AppColors.accent : (isDark ? Colors.grey.shade600 : Colors.grey.shade300), width: 2),
                    ),
                    child: task.isCompleted ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(task.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: task.isCompleted ? ext.subtext : theme.colorScheme.onSurface, decoration: task.isCompleted ? TextDecoration.lineThrough : null, decorationColor: ext.subtext)),
                    if (task.hasTimeSlot) ...[
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.schedule_rounded, size: 14, color: task.isCompleted ? ext.subtext.withValues(alpha: 0.5) : AppColors.accent.withValues(alpha: 0.7)),
                        const SizedBox(width: 4),
                        Text(_formatTimeRange(task.startTime!, task.endTime), style: TextStyle(fontSize: 12, color: ext.subtext, fontWeight: FontWeight.w500)),
                      ]),
                    ],
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(task.description, style: TextStyle(fontSize: 12, color: ext.subtext), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ]),
                ),
                if (task.hasTimeSlot)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: task.isCompleted ? (isDark ? AppColors.surfaceDark : Colors.grey.shade100) : AppColors.accent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(DateFormat('HH:mm').format(task.startTime!), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: task.isCompleted ? ext.subtext : AppColors.accent)),
                  ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, TaskViewmodel vm) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.selectedDate.isBefore(DateTime(today.year, today.month, today.day)) ? DateTime(today.year, today.month, today.day) : vm.selectedDate,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(today.year + 1, today.month, today.day),
    );
    if (picked != null) await vm.selectDate(picked);
  }

  String _formatTimeRange(DateTime start, DateTime? end) {
    final startStr = DateFormat('HH:mm').format(start);
    if (end != null) return '$startStr - ${DateFormat('HH:mm').format(end)}';
    return startStr;
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}