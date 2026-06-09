import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/services/notification/app_notification.dart';
import 'package:studyflow/core/services/notification/notification_service.dart';
import 'package:studyflow/core/services/notification/notification_type.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/presentation/viewmodels/task_viewmodel.dart';
import 'package:studyflow/features/schedule/presentation/viewmodels/schedule_viewmodel.dart';
import 'package:studyflow/features/home/presentation/viewmodels/home_viewmodel.dart';

/// A modal bottom sheet used to create a new task or edit an existing one.
/// It provides form fields for task title, description, date, and optional start/end times.
class TaskFormModal extends StatefulWidget {
  /// The task to edit. If null, a new task will be created.
  final Task? task;
  const TaskFormModal({super.key, this.task});
  @override
  State<TaskFormModal> createState() => _TaskFormModalState();
}

class _TaskFormModalState extends State<TaskFormModal> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late DateTime _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _selectedDate = task?.date ?? DateTime.now();
    if (task?.startTime != null) {
      _startTime = TimeOfDay.fromDateTime(task!.startTime!);
    }
    if (task?.endTime != null) {
      _endTime = TimeOfDay.fromDateTime(task!.endTime!);
    }
    if (task?.reminderTime != null) {
      _reminderTime = TimeOfDay.fromDateTime(task!.reminderTime!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future<void> _deleteTask(BuildContext context) async {
    final vm = context.read<TaskViewmodel>();
    final scheduleVm = context.read<ScheduleViewmodel>();
    final homeVm = context.read<HomeViewModel>();
    final navigator = Navigator.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).extension<AppThemeExtension>()!.subtext,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await vm.deleteTask(widget.task!.id, widget.task!.date);
      scheduleVm.loadWeekTasks();
      homeVm.refreshTasks();
      navigator.pop();
      NotificationService.instance.show(
        AppNotification(
          message: 'Task deleted successfully!',
          type: NotificationType.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isEditMode = widget.task != null;
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: ext.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48),
                Text(
                  isEditMode ? 'Edit task' : 'Add new task',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                isEditMode && widget.task?.isCompleted != true
                    ? IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                          size: 24,
                        ),
                        onPressed: () => _deleteTask(context),
                      )
                    : const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              autofocus: !isEditMode,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'What do you want to do...?',
                filled: true,
                fillColor: ext.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.accent,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              minLines: 1,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Add details / description...',
                filled: true,
                fillColor: ext.inputFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: AppColors.accent,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Date picker
            GestureDetector(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate:
                      _selectedDate.isBefore(
                        DateTime(today.year, today.month, today.day),
                      )
                      ? DateTime(today.year, today.month, today.day)
                      : _selectedDate,
                  firstDate: DateTime(today.year, today.month, today.day),
                  lastDate: DateTime(today.year + 1, today.month, today.day),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: ext.inputFill,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: TextStyle(
                            fontSize: 11,
                            color: ext.subtext,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isSameDay(_selectedDate, today)
                              ? 'Today, ${DateFormat('dd MMM yyyy').format(_selectedDate)}'
                              : DateFormat(
                                  'EEEE, dd MMM yyyy',
                                ).format(_selectedDate),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: ext.subtext, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Time pickers
            Row(
              children: [
                Expanded(
                  child: _buildTimePicker(context, 'Start', _startTime, true),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildTimePicker(context, 'End', _endTime, false),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildReminderPicker(context),
            const SizedBox(height: 20),
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  if (_titleController.text.trim().isEmpty) return;

                  final now = DateTime.now();
                  final todayDate = DateTime(now.year, now.month, now.day);
                  final selectedDateOnly = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                  );
                  final isToday = selectedDateOnly.isAtSameMomentAs(todayDate);

                  if (isToday && _startTime != null) {
                    final startDateTimeVal = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      _startTime!.hour,
                      _startTime!.minute,
                    );
                    if (startDateTimeVal.isBefore(now)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Start time cannot be in the past!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                  }

                  if (_endTime != null) {
                    if (_endTime!.hour == 0 && _endTime!.minute == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'End time cannot be 00:00 (please use up to 23:59)!',
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                    if (_startTime != null) {
                      final startMin =
                          _startTime!.hour * 60 + _startTime!.minute;
                      final endMin = _endTime!.hour * 60 + _endTime!.minute;
                      if (endMin <= startMin) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('End time must be after start time!'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                    }
                  }

                  if (isToday && _reminderTime != null) {
                    final reminderDateTimeVal = DateTime(
                      now.year,
                      now.month,
                      now.day,
                      _reminderTime!.hour,
                      _reminderTime!.minute,
                    );
                    if (reminderDateTimeVal.isBefore(now)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reminder time cannot be in the past!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }
                  }

                  final vm = context.read<TaskViewmodel>();
                  final scheduleVm = context.read<ScheduleViewmodel>();
                  final homeVm = context.read<HomeViewModel>();
                  final navigator = Navigator.of(context);
                  DateTime? startDateTime;
                  DateTime? endDateTime;
                  DateTime? reminderDateTime;
                  if (_startTime != null) {
                    startDateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _startTime!.hour,
                      _startTime!.minute,
                    );
                  }
                  if (_endTime != null) {
                    endDateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _endTime!.hour,
                      _endTime!.minute,
                    );
                  }
                  if (_reminderTime != null) {
                    reminderDateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _reminderTime!.hour,
                      _reminderTime!.minute,
                    );
                  }
                  if (isEditMode) {
                    final updatedTask = widget.task!.copyWith(
                      title: _titleController.text.trim(),
                      description: _descriptionController.text.trim(),
                      date: DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                      ),
                      startTime: startDateTime,
                      endTime: endDateTime,
                      reminderTime: reminderDateTime,
                    );
                    await vm.updateTask(updatedTask);
                  } else {
                    final newTask = Task(
                      id: '',
                      title: _titleController.text.trim(),
                      description: _descriptionController.text.trim(),
                      date: DateTime(
                        _selectedDate.year,
                        _selectedDate.month,
                        _selectedDate.day,
                      ),
                      startTime: startDateTime,
                      endTime: endDateTime,
                      reminderTime: reminderDateTime,
                    );
                    await vm.addTask(newTask);
                  }
                  scheduleVm.loadWeekTasks();
                  homeVm.refreshTasks();
                  navigator.pop();
                  if (isEditMode) {
                    NotificationService.instance.show(
                      AppNotification(
                        message: 'Task updated!',
                        type: NotificationType.success,
                      ),
                    );
                  } else {
                    NotificationService.instance.show(
                      AppNotification(
                        message: 'Added new task!',
                        type: NotificationType.success,
                      ),
                    );
                  }
                },
                child: Text(
                  isEditMode ? 'Save changes' : 'Add now',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderPicker(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _reminderTime ?? TimeOfDay.now(),
        );
        if (picked != null) {
          setState(() {
            _reminderTime = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: ext.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.notifications_active_outlined,
              size: 18,
              color: AppColors.accent,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reminder',
                  style: TextStyle(
                    fontSize: 11,
                    color: ext.subtext,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _reminderTime != null
                      ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
                      : 'None / No Reminder',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _reminderTime != null
                        ? theme.colorScheme.onSurface
                        : ext.subtext,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (_reminderTime != null)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _reminderTime = null;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.clear, color: ext.subtext, size: 18),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(
    BuildContext context,
    String label,
    TimeOfDay? time,
    bool isStart,
  ) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time ?? TimeOfDay.now(),
        );
        if (picked != null) {
          setState(() {
            if (isStart) {
              _startTime = picked;
            } else {
              _endTime = picked;
            }
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: ext.inputFill,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.dividerColor),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.schedule_rounded,
              size: 18,
              color: AppColors.accent,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: ext.subtext,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time != null
                      ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                      : 'Optional',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: time != null
                        ? theme.colorScheme.onSurface
                        : ext.subtext,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
