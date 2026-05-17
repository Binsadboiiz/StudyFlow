import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/presentation/viewmodels/task_viewmodel.dart';

/// Màn hình quản lý các công việc (Task) - Giao diện hiện đại.
/// Đây là View trong kiến trúc MVVM, chỉ làm nhiệm vụ hiển thị và nhận tương tác từ người dùng.
class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  @override
  void initState() {
    super.initState();
    // Dùng Future.microtask để đảm bảo context đã sẵn sàng trước khi gọi ViewModel.
    Future.microtask(() {
      context.read<TaskViewmodel>().loadTask(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TaskViewmodel>();
    final today = DateTime.now();

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Tasks',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vm.tasks.where((t) => !t.isCompleted).length} remaining · ${vm.tasks.where((t) => t.isCompleted).length} completed',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // Nút chọn ngày
                  _buildDateChip(context, vm, today),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ===== HORIZONTAL DATE SELECTOR =====
            _buildDateSelector(vm, today),
            const SizedBox(height: 16),

            // ===== PROGRESS BAR =====
            if (vm.tasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildProgressBar(vm),
              ),
            const SizedBox(height: 8),

            // ===== TASK LIST =====
            Expanded(
              child: vm.tasks.isEmpty
                  ? _buildEmptyState()
                  : _buildTaskList(vm),
            ),
          ],
        ),
      ),
    );
  }

  /// Chip hiển thị ngày đang chọn + cho phép mở Date Picker
  Widget _buildDateChip(BuildContext context, TaskViewmodel vm, DateTime today) {
    final isToday = _isSameDay(vm.selectedDate, today);

    return GestureDetector(
      onTap: () => _pickDate(context, vm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32).withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF2E7D32).withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: Color(0xFF2E7D32),
            ),
            const SizedBox(width: 6),
            Text(
              isToday ? 'Today' : DateFormat('dd MMM').format(vm.selectedDate),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Horizontal scrollable date selector (7 ngày từ hôm nay)
  Widget _buildDateSelector(TaskViewmodel vm, DateTime today) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 14, // Hiển thị 14 ngày tiếp theo
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
                color: isSelected
                    ? const Color(0xFF2E7D32)
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: isCurrentDay && !isSelected
                    ? Border.all(color: const Color(0xFF2E7D32), width: 1.5)
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2E7D32).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Progress bar hiển thị tiến độ hoàn thành
  Widget _buildProgressBar(TaskViewmodel vm) {
    final total = vm.tasks.length;
    final completed = vm.tasks.where((t) => t.isCompleted).length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  /// Empty state khi không có task
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks for this day',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add a new task',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 80), // Offset for BottomAppBar
        ],
      ),
    );
  }

  /// Task list hiển thị dạng card hiện đại
  Widget _buildTaskList(TaskViewmodel vm) {
    // Tách task chưa hoàn thành lên trước, đã hoàn thành xuống sau
    final pendingTasks = vm.tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = vm.tasks.where((t) => t.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 100),
      children: [
        // Pending tasks
        ...pendingTasks.map((task) => _buildTaskCard(task, vm)),
        // Completed section
        if (completedTasks.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 8),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, size: 18, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                Text(
                  'Completed (${completedTasks.length})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
          ...completedTasks.map((task) => _buildTaskCard(task, vm)),
        ],
      ],
    );
  }

  /// Card hiển thị mỗi task
  Widget _buildTaskCard(Task task, TaskViewmodel vm) {
    return Dismissible(
      key: Key('task_${task.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => vm.deleteTask(task.id, task.date),
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => vm.toggleTask(task),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Checkbox tùy chỉnh
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: task.isCompleted
                          ? const Color(0xFF2E7D32)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: task.isCompleted
                            ? const Color(0xFF2E7D32)
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  // Nội dung task
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: task.isCompleted
                                ? Colors.grey.shade400
                                : Colors.grey.shade800,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: Colors.grey.shade400,
                          ),
                        ),
                        if (task.hasTimeSlot) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: task.isCompleted
                                    ? Colors.grey.shade300
                                    : const Color(0xFF2E7D32).withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatTimeRange(task.startTime!, task.endTime),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: task.isCompleted
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Time badge
                  if (task.hasTimeSlot)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? Colors.grey.shade100
                            : const Color(0xFF2E7D32).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        DateFormat('HH:mm').format(task.startTime!),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: task.isCompleted
                              ? Colors.grey.shade400
                              : const Color(0xFF2E7D32),
                        ),
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

  /// Mở Date Picker (chỉ cho chọn từ hôm nay trở đi)
  Future<void> _pickDate(BuildContext context, TaskViewmodel vm) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.selectedDate.isBefore(DateTime(today.year, today.month, today.day))
          ? DateTime(today.year, today.month, today.day)
          : vm.selectedDate,
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
      await vm.selectDate(picked);
    }
  }

  /// Format time range display
  String _formatTimeRange(DateTime start, DateTime? end) {
    final startStr = DateFormat('HH:mm').format(start);
    if (end != null) {
      final endStr = DateFormat('HH:mm').format(end);
      return '$startStr - $endStr';
    }
    return startStr;
  }

  /// So sánh 2 ngày có cùng ngày không (bỏ qua giờ/phút/giây)
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}