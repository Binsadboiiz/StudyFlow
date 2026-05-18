import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';

/// Dialog thêm task mới với time picker cho Schedule screen.
/// Cho phép nhập title, chọn giờ bắt đầu & kết thúc.
class AddScheduleTaskDialog extends StatefulWidget {
  final DateTime selectedDay;
  final int? initialHour; // Giờ khởi tạo khi tap vào một slot giờ cụ thể

  const AddScheduleTaskDialog({
    super.key,
    required this.selectedDay,
    this.initialHour,
  });

  @override
  State<AddScheduleTaskDialog> createState() => _AddScheduleTaskDialogState();
}

class _AddScheduleTaskDialogState extends State<AddScheduleTaskDialog> {
  final _titleController = TextEditingController();
  late TimeOfDay _startTime;
  TimeOfDay? _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = TimeOfDay(hour: widget.initialHour ?? TimeOfDay.now().hour, minute: 0);
    _endTime = TimeOfDay(hour: (_startTime.hour + 1) % 24, minute: 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'New Schedule',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.close, size: 18, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Hiển thị ngày
            Text(
              DateFormat('EEEE, dd MMMM yyyy').format(widget.selectedDay),
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // ===== TITLE INPUT =====
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Task title...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF2E7D32),
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),

            // ===== TIME PICKERS =====
            Row(
              children: [
                // Start time
                Expanded(
                  child: _buildTimePicker(
                    label: 'Start',
                    time: _startTime,
                    icon: Icons.play_circle_outline_rounded,
                    onTap: () => _pickTime(isStart: true),
                  ),
                ),
                const SizedBox(width: 12),
                // End time
                Expanded(
                  child: _buildTimePicker(
                    label: 'End',
                    time: _endTime,
                    icon: Icons.stop_circle_outlined,
                    onTap: () => _pickTime(isStart: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ===== ADD BUTTON =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _onSubmit,
                child: const Text(
                  'Add to Schedule',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? time,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time != null
                      ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
                      : '--:--',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : (_endTime ?? _startTime);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
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
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _onSubmit() {
    if (_titleController.text.trim().isEmpty) return;

    final day = widget.selectedDay;
    final startDateTime = DateTime(
      day.year, day.month, day.day,
      _startTime.hour, _startTime.minute,
    );
    DateTime? endDateTime;
    if (_endTime != null) {
      endDateTime = DateTime(
        day.year, day.month, day.day,
        _endTime!.hour, _endTime!.minute,
      );
    }

    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch,
      title: _titleController.text.trim(),
      description: '',
      date: DateTime(day.year, day.month, day.day),
      startTime: startDateTime,
      endTime: endDateTime,
    );

    Navigator.pop(context, task);
  }
}
