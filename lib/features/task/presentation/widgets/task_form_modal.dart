import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';
import 'package:studyflow/features/task/presentation/viewmodels/task_viewmodel.dart';
import 'package:studyflow/features/schedule/presentation/viewmodels/schedule_viewmodel.dart';
import 'package:studyflow/features/home/presentation/viewmodels/home_viewmodel.dart';

/// Modal bottom sheet reusable cho việc tạo mới (Add) hoặc chỉnh sửa (Edit) Task.
class TaskFormModal extends StatefulWidget {
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

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _selectedDate = task?.date ?? DateTime.now();
    
    if (task?.startTime != null) {
      _startTime = TimeOfDay.fromDateTime(task!.startTime!);
    }
    if (task?.endTime != null) {
      _endTime = TimeOfDay.fromDateTime(task!.endTime!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _deleteTask(BuildContext context) async {
    final vm = context.read<TaskViewmodel>();
    final scheduleVm = context.read<ScheduleViewmodel>();
    final homeVm = context.read<HomeViewModel>();
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await vm.deleteTask(widget.task!.id, widget.task!.date);
      
      scheduleVm.loadWeekTasks();
      homeVm.refreshTasks();
      
      navigator.pop(); // Đóng modal form
      
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Task deleted successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final isEditMode = widget.task != null;

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
            // Thanh kéo nhỏ ở trên cùng
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            
            // Header: Title + Nút Delete (nếu là Edit mode)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 48), // Giữ khoảng trống để cân đối title
                Text(
                  isEditMode ? 'Edit task' : 'Add new task',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                isEditMode
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 24),
                        onPressed: () => _deleteTask(context),
                      )
                    : const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 20),

            // ===== TITLE INPUT =====
            TextField(
              controller: _titleController,
              autofocus: !isEditMode, // Tự động mở bàn phím khi thêm mới
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
            const SizedBox(height: 12),

            // ===== DESCRIPTION INPUT =====
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Add details / description...',
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
                  initialDate: _selectedDate.isBefore(DateTime(today.year, today.month, today.day))
                      ? DateTime(today.year, today.month, today.day)
                      : _selectedDate,
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
                  setState(() {
                    _selectedDate = picked;
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
                          _isSameDay(_selectedDate, today)
                              ? 'Today, ${DateFormat('dd MMM yyyy').format(_selectedDate)}'
                              : DateFormat('EEEE, dd MMM yyyy').format(_selectedDate),
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
                        initialTime: _startTime ?? TimeOfDay.now(),
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
                        setState(() {
                          _startTime = picked;
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
                                _startTime != null
                                    ? '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}'
                                    : 'Optional',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: _startTime != null ? Colors.black87 : Colors.grey.shade400,
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
                        initialTime: _endTime ?? (_startTime != null 
                            ? TimeOfDay(hour: (_startTime!.hour + 1) % 24, minute: _startTime!.minute)
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
                        setState(() {
                          _endTime = picked;
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
                                _endTime != null
                                    ? '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}'
                                    : 'Optional',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: _endTime != null ? Colors.black87 : Colors.grey.shade400,
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

            // ===== SUBMIT BUTTON =====
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
                  if (_titleController.text.trim().isEmpty) return;
                  
                  final vm = context.read<TaskViewmodel>();
                  final scheduleVm = context.read<ScheduleViewmodel>();
                  final homeVm = context.read<HomeViewModel>();
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  // Build startTime/endTime DateTime objects
                  DateTime? startDateTime;
                  DateTime? endDateTime;
                  if (_startTime != null) {
                    startDateTime = DateTime(
                      _selectedDate.year, _selectedDate.month, _selectedDate.day,
                      _startTime!.hour, _startTime!.minute,
                    );
                  }
                  if (_endTime != null) {
                    endDateTime = DateTime(
                      _selectedDate.year, _selectedDate.month, _selectedDate.day,
                      _endTime!.hour, _endTime!.minute,
                    );
                  }

                  if (isEditMode) {
                    // Chế độ Edit
                    final updatedTask = widget.task!.copyWith(
                      title: _titleController.text.trim(),
                      description: _descriptionController.text.trim(),
                      date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
                      startTime: startDateTime,
                      endTime: endDateTime,
                    );
                    await vm.updateTask(updatedTask);
                  } else {
                    // Chế độ Add
                    final newTask = Task(
                      id: DateTime.now().millisecondsSinceEpoch,
                      title: _titleController.text.trim(),
                      description: _descriptionController.text.trim(),
                      date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day),
                      startTime: startDateTime,
                      endTime: endDateTime,
                    );
                    await vm.addTask(newTask);
                  }

                  scheduleVm.loadWeekTasks();
                  homeVm.refreshTasks();
                  
                  navigator.pop(); // Đóng modal

                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(isEditMode ? 'Task updated!' : 'Added new task!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                  );
                },
                child: Text(
                  isEditMode ? 'Save changes' : 'Add now', 
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
