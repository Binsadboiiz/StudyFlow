import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/features/task/domain/entities/task.dart';

/// A dialog widget used to add a new task to the schedule for a specific day.
class AddScheduleTaskDialog extends StatefulWidget {
  /// The specific day selected for the new task.
  final DateTime selectedDay;
  
  /// An optional initial starting hour for the new task.
  final int? initialHour;
  
  const AddScheduleTaskDialog({super.key, required this.selectedDay, this.initialHour});
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
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: ext.cardBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('New Schedule', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface)),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(color: isDark ? AppColors.surfaceDark : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.close, size: 18, color: ext.subtext),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(DateFormat('EEEE, dd MMMM yyyy').format(widget.selectedDay), style: TextStyle(fontSize: 13, color: ext.subtext, fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            TextField(
              controller: _titleController,
              autofocus: true,
              style: TextStyle(color: theme.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Task title...',
                hintStyle: TextStyle(color: ext.subtext),
                filled: true,
                fillColor: ext.inputFill,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildTimePicker(label: 'Start', time: _startTime, icon: Icons.play_circle_outline_rounded, onTap: () => _pickTime(isStart: true))),
              const SizedBox(width: 12),
              Expanded(child: _buildTimePicker(label: 'End', time: _endTime, icon: Icons.stop_circle_outlined, onTap: () => _pickTime(isStart: false))),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _onSubmit,
                child: const Text('Add to Schedule', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a customized time picker button.
  Widget _buildTimePicker({required String label, required TimeOfDay? time, required IconData icon, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: ext.inputFill, borderRadius: BorderRadius.circular(14), border: Border.all(color: theme.dividerColor)),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: ext.subtext)),
            const SizedBox(height: 2),
            Text(
              time != null ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}' : '--:--',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
            ),
          ]),
        ]),
      ),
    );
  }

  /// Opens a time picker dialog to select start or end time.
  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : (_endTime ?? _startTime);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) setState(() { if (isStart) { _startTime = picked; } else { _endTime = picked; } });
  }

  /// Submits the new task details and closes the dialog.
  void _onSubmit() {
    if (_titleController.text.trim().isEmpty) return;
    final day = widget.selectedDay;
    final startDateTime = DateTime(day.year, day.month, day.day, _startTime.hour, _startTime.minute);
    DateTime? endDateTime;
    if (_endTime != null) endDateTime = DateTime(day.year, day.month, day.day, _endTime!.hour, _endTime!.minute);
    final task = Task(id: '', title: _titleController.text.trim(), description: '', date: DateTime(day.year, day.month, day.day), startTime: startDateTime, endTime: endDateTime);
    Navigator.pop(context, task);
  }
}
