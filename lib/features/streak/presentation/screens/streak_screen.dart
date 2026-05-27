import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';

/// Screen displaying the user's study streak.
///
/// This screen includes:
/// - A counter showing the total number of current consecutive streak days.
/// - A calendar visually marking the days the user completed their tasks (indicated by a fire icon).
class StreakScreen extends StatefulWidget {
  const StreakScreen({super.key});

  @override
  State<StreakScreen> createState() => _StreakScreenState();
}

class _StreakScreenState extends State<StreakScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;
    
    final authVm = context.watch<AuthViewmodel>();
    final user = authVm.currentUser;
    final streakCount = user?.streak ?? 0;
    final streakHistory = user?.streakHistory ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Streaks', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Prominent streak counter
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: AppColors.accent,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$streakCount Days',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Keep it up!',
                        style: TextStyle(
                          fontSize: 16,
                          color: ext.subtext,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Calendar view
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    headerStyle: HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                      titleTextStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      leftChevronIcon: Icon(Icons.chevron_left, color: theme.colorScheme.onSurface),
                      rightChevronIcon: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: ext.subtext, fontWeight: FontWeight.bold),
                      weekendStyle: TextStyle(color: ext.subtext, fontWeight: FontWeight.bold),
                    ),
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      defaultTextStyle: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
                      weekendTextStyle: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
                      todayDecoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
                    ),
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, focusedDay) {
                        return _buildCalendarDay(day, streakHistory, theme, ext);
                      },
                      todayBuilder: (context, day, focusedDay) {
                        return _buildCalendarDay(day, streakHistory, theme, ext, isToday: true);
                      },
                      outsideBuilder: (context, day, focusedDay) {
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a specific day cell on the calendar.
  /// 
  /// Display logic:
  /// - If the day is in the streak history (`streakHistory`), it highlights the cell with a fire icon.
  /// - If it is the current day (`isToday`), it highlights the border/color for easy recognition.
  /// - If it is a normal day without a streak, it displays the day number as plain text.
  Widget _buildCalendarDay(DateTime day, List<String> streakHistory, ThemeData theme, AppThemeExtension ext, {bool isToday = false}) {
    final dateStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    final hasStreak = streakHistory.contains(dateStr);

    if (hasStreak) {
      return Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.accent,
            size: 24,
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isToday ? AppColors.accent.withValues(alpha: 0.2) : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: isToday ? AppColors.accent : theme.colorScheme.onSurface,
            fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
