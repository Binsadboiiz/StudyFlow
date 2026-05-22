import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';

class DayTabBar extends StatelessWidget {
  final List<DateTime> weekDays;
  final DateTime selectedDay;
  final DateTime currentWeekStart;
  final ValueChanged<DateTime> onDaySelected;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  const DayTabBar({
    super.key,
    required this.weekDays,
    required this.selectedDay,
    required this.currentWeekStart,
    required this.onDaySelected,
    required this.onPreviousWeek,
    required this.onNextWeek,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final weekEnd = DateTime(currentWeekStart.year, currentWeekStart.month, currentWeekStart.day + 6);
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavButton(context, Icons.chevron_left_rounded, onPreviousWeek),
              GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    '${DateFormat('dd MMM').format(currentWeekStart)} - ${DateFormat('dd MMM').format(weekEnd)}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.accent),
                  ),
                ),
              ),
              _buildNavButton(context, Icons.chevron_right_rounded, onNextWeek),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 72,
          child: Row(
            children: weekDays.map((day) {
              final isSelected = _isSameDay(day, selectedDay);
              final isToday = _isSameDay(day, today);
              return Expanded(
                child: GestureDetector(
                  onTap: () => onDaySelected(day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : isToday ? AppColors.accent.withValues(alpha: 0.08) : ext.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                      border: isToday && !isSelected ? Border.all(color: AppColors.accent, width: 1.5) : null,
                      boxShadow: isSelected ? [BoxShadow(color: AppColors.accent.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 3))] : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('EEE').format(day).toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isSelected ? Colors.white.withValues(alpha: 0.8) : ext.subtext, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text('${day.day}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : isToday ? AppColors.accent : theme.colorScheme.onSurface)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton(BuildContext context, IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ext.cardBackground,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, color: ext.icon, size: 22),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}
