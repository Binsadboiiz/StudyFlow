import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget hiển thị tab bar 7 ngày trong tuần (Mon-Sun) cho Schedule.
/// Cho phép chọn ngày, điều hướng tuần, và highlight ngày hiện tại.
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
    // Tính ngày cuối tuần (Sunday)
    final weekEnd = DateTime(
      currentWeekStart.year,
      currentWeekStart.month,
      currentWeekStart.day + 6,
    );

    return Column(
      children: [
        // ===== HEADER: Week navigation =====
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Nút tuần trước
              _buildNavButton(Icons.chevron_left_rounded, onPreviousWeek),
              // Label tuần
              GestureDetector(
                onTap: () {}, // Có thể mở week picker sau
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${DateFormat('dd MMM').format(currentWeekStart)} - ${DateFormat('dd MMM').format(weekEnd)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
              // Nút tuần sau
              _buildNavButton(Icons.chevron_right_rounded, onNextWeek),
            ],
          ),
        ),
        const SizedBox(height: 4),

        // ===== DAY TABS =====
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
                      color: isSelected
                          ? const Color(0xFF2E7D32)
                          : isToday
                              ? const Color(0xFF2E7D32).withOpacity(0.08)
                              : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: isToday && !isSelected
                          ? Border.all(color: const Color(0xFF2E7D32), width: 1.5)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF2E7D32).withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(day).toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white.withOpacity(0.8)
                                : Colors.grey.shade500,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? const Color(0xFF2E7D32)
                                    : Colors.grey.shade800,
                          ),
                        ),
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

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.grey.shade700, size: 22),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
