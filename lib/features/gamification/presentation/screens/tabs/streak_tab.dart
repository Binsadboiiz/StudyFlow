import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:studyflow/features/gamification/presentation/viewmodels/gamification_viewmodel.dart';
import 'package:studyflow/l10n/app_localizations.dart';

/// Tab hiển thị số ngày streak và Lịch học tập ngọn lửa của người dùng.
class StreakTab extends StatefulWidget {
  const StreakTab({super.key});

  @override
  State<StreakTab> createState() => _StreakTabState();
}

class _StreakTabState extends State<StreakTab> {
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    final authVm = context.watch<AuthViewmodel>();
    final gamificationVm = context.watch<GamificationViewModel>();

    final user = authVm.currentUser;
    final streakHistory = user?.streakHistory ?? [];

    final summary = gamificationVm.summary;
    final streakCount = summary?.streak ?? user?.streak ?? 0;
    final todayFocus = summary?.focusedMinutesToday ?? 0;
    final dailyTarget = summary?.dailyTargetMinutes ?? user?.dailyTargetMinutes ?? 60;
    final progress = (todayFocus / dailyTarget).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        children: [
          // Thống kê tóm tắt Streak và Tiến trình hôm nay
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            borderRadius: 24,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Cột 1: Streak Count
                    Column(
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.orangeAccent,
                          size: 56,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.days(streakCount),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.currentStreak,
                          style: TextStyle(
                            fontSize: 12,
                            color: ext.subtext,
                          ),
                        ),
                      ],
                    ),
                    // Đường phân chia dọc
                    Container(
                      width: 1.5,
                      height: 70,
                      color: theme.dividerColor.withValues(alpha: 0.5),
                    ),
                    // Cột 2: Mục tiêu hôm nay
                    Column(
                      children: [
                        const Icon(
                          Icons.insights_rounded,
                          color: AppColors.accent,
                          size: 56,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$todayFocus/$dailyTarget',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!.minutesFocusedToday,
                          style: TextStyle(
                            fontSize: 12,
                            color: ext.subtext,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Thanh tiến trình học tập trong ngày
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.dailyGoalProgress,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Lịch học tập chi tiết
          GlassCard(
            borderRadius: 24,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
                  child: Text(
                    AppLocalizations.of(context)!.studyHistory,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                TableCalendar(
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
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    leftChevronIcon: Icon(Icons.chevron_left, color: theme.colorScheme.onSurface),
                    rightChevronIcon: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: ext.subtext, fontWeight: FontWeight.bold, fontSize: 12),
                    weekendStyle: TextStyle(color: ext.subtext, fontWeight: FontWeight.bold, fontSize: 12),
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
              ],
            ),
          ),
          const SizedBox(height: 100), // Khoảng trống cho dock navigation
        ],
      ),
    );
  }

  Widget _buildCalendarDay(DateTime day, List<String> streakHistory, ThemeData theme, AppThemeExtension ext, {bool isToday = false}) {
    final dateStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";
    final hasStreak = streakHistory.contains(dateStr);

    if (hasStreak) {
      return Container(
        margin: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.orangeAccent,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.local_fire_department_rounded,
            color: Colors.white,
            size: 20,
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
