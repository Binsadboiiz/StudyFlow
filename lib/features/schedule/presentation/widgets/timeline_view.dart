import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';

class TimelineView extends StatelessWidget {
  final List<Task> tasks;
  final DateTime selectedDay;
  final Function(int hour) onHourTapped;
  final Function(Task task) onTaskToggle;
  final Function(Task task) onTaskDelete;

  const TimelineView({
    super.key,
    required this.tasks,
    required this.selectedDay,
    required this.onHourTapped,
    required this.onTaskToggle,
    required this.onTaskDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(left: 8, right: 16, top: 8, bottom: 100),
      itemCount: 24,
      itemBuilder: (context, index) {
        final hour = index;
        final hourTasks = _getTasksForHour(hour);
        return _buildHourRow(context, hour, hourTasks);
      },
    );
  }

  List<Task> _getTasksForHour(int hour) {
    return tasks.where((task) {
      if (task.startTime == null) return false;
      return task.startTime!.hour == hour;
    }).toList()
      ..sort((a, b) => a.startTime!.minute.compareTo(b.startTime!.minute));
  }

  Widget _buildHourRow(BuildContext context, int hour, List<Task> hourTasks) {
    final now = DateTime.now();
    final isCurrentHour = _isSameDay(selectedDay, now) && now.hour == hour;
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    return IntrinsicHeight(
      child: GestureDetector(
        onTap: () => onHourTapped(hour),
        behavior: HitTestBehavior.opaque,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 52,
              child: Padding(
                padding: const EdgeInsets.only(top: 2, right: 8),
                child: Text(
                  '${hour.toString().padLeft(2, '0')}:00',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isCurrentHour ? FontWeight.bold : FontWeight.w500,
                    color: isCurrentHour ? AppColors.accent : ext.subtext,
                  ),
                ),
              ),
            ),
            Column(children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: isCurrentHour ? AppColors.accent : hourTasks.isNotEmpty ? AppColors.accent.withValues(alpha: 0.5) : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                  shape: BoxShape.circle,
                  boxShadow: isCurrentHour ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.3), blurRadius: 6)] : null,
                ),
              ),
              Expanded(child: Container(width: 2, color: isCurrentHour ? AppColors.accent.withValues(alpha: 0.3) : theme.dividerColor)),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 60),
                child: hourTasks.isEmpty
                    ? _buildEmptySlot(context, isCurrentHour)
                    : Column(children: hourTasks.map((task) => _buildTimelineTaskCard(context, task)).toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlot(BuildContext context, bool isCurrentHour) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isCurrentHour ? AppColors.accent.withValues(alpha: 0.15) : (isDark ? AppColors.dividerDark : Colors.grey.shade100))),
      ),
      child: isCurrentHour
          ? Row(children: [
              Container(width: 4, height: 20, decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text('Now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent.withValues(alpha: 0.7))),
            ])
          : null,
    );
  }

  Widget _buildTimelineTaskCard(BuildContext context, Task task) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: task.isCompleted
            ? (isDark ? AppColors.surfaceDark : Colors.grey.shade100)
            : AppColors.accent.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: task.isCompleted ? theme.dividerColor : AppColors.accent.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onTaskToggle(task),
          onLongPress: () => onTaskDelete(task),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Container(
                width: 4, height: 36,
                decoration: BoxDecoration(color: task.isCompleted ? ext.subtext : AppColors.accent, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(task.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: task.isCompleted ? ext.subtext : theme.colorScheme.onSurface, decoration: task.isCompleted ? TextDecoration.lineThrough : null)),
                  const SizedBox(height: 2),
                  Text(_formatTimeRange(task.startTime!, task.endTime), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: task.isCompleted ? ext.subtext : AppColors.accent.withValues(alpha: 0.8))),
                ]),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: task.isCompleted ? ext.subtext : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: task.isCompleted ? ext.subtext : AppColors.accent.withValues(alpha: 0.5), width: 2),
                ),
                child: task.isCompleted ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
              ),
            ]),
          ),
        ),
      ),
    );
  }

  String _formatTimeRange(DateTime start, DateTime? end) {
    final startStr = DateFormat('HH:mm').format(start);
    if (end != null) return '$startStr - ${DateFormat('HH:mm').format(end)}';
    return startStr;
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
