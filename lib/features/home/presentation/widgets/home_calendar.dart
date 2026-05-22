import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../viewmodels/home_viewmodel.dart';

/// Widget hiển thị phần Lịch (Calendar) ở nửa trên của màn hình Home.
class HomeCalendar extends StatelessWidget {
  const HomeCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return TableCalendar(
          firstDay: DateTime.utc(2020, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: viewModel.focusedDate,
          selectedDayPredicate: (day) => isSameDay(viewModel.selectedDate, day),
          onDaySelected: (selectedDay, focusedDay) {
            if (!isSameDay(viewModel.selectedDate, selectedDay)) {
              viewModel.onDaySelected(selectedDay, focusedDay);
            }
          },
          calendarFormat: CalendarFormat.month,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
            CalendarFormat.twoWeeks: '2 Weeks',
            CalendarFormat.week: 'Week',
          },
          headerStyle: HeaderStyle(
            formatButtonVisible: true,
            titleCentered: true,
            titleTextStyle: TextStyle(
              color: theme.colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            leftChevronIcon: Icon(Icons.chevron_left, color: theme.colorScheme.onSurface),
            rightChevronIcon: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface),
            formatButtonTextStyle: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13),
            formatButtonDecoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
            weekendStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w600),
          ),
          calendarStyle: CalendarStyle(
            defaultTextStyle: TextStyle(color: theme.colorScheme.onSurface),
            weekendTextStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
            outsideTextStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            todayDecoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
