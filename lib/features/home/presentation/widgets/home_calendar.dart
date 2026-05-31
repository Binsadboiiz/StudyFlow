import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import '../viewmodels/home_viewmodel.dart';

/// A widget that displays the Calendar in the upper half of the Home screen.
class HomeCalendar extends StatelessWidget {
  const HomeCalendar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GlassCard(
            padding: const EdgeInsets.all(8.0),
            borderRadius: 24.0,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: viewModel.focusedDate,
              selectedDayPredicate: (day) => isSameDay(viewModel.selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(viewModel.selectedDate, selectedDay)) {
                  viewModel.onDaySelected(selectedDay, focusedDay);
                }
              },
              calendarFormat: viewModel.calendarFormat,
              onFormatChanged: (format) {
                viewModel.onFormatChanged(format);
              },
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
                weekendStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w600),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500),
                weekendTextStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                outsideTextStyle: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
