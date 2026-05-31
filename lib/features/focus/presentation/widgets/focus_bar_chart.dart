import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:studyflow/features/focus/data/models/focus_session_model.dart';
import 'package:studyflow/features/focus/data/repositories/focus_repository.dart';

class FocusBarChart extends StatefulWidget {
  const FocusBarChart({super.key});

  @override
  State<FocusBarChart> createState() => _FocusBarChartState();
}

class _FocusBarChartState extends State<FocusBarChart> {
  final FocusRepository _repository = FocusRepository();
  List<DailyFocusHeatmapModel> _data = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(const Duration(days: 6)); // Last 7 days
    
    final data = await _repository.getHeatmapData(startDate, endDate);
    
    // Fill missing days with 0
    List<DailyFocusHeatmapModel> filledData = [];
    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final existing = data.where((d) => 
        '${d.date.year}-${d.date.month.toString().padLeft(2, '0')}-${d.date.day.toString().padLeft(2, '0')}' == dateStr
      ).firstOrNull;
      
      if (existing != null) {
        filledData.add(existing);
      } else {
        filledData.add(DailyFocusHeatmapModel(date: date, totalMinutes: 0));
      }
    }
    
    setState(() {
      _data = filledData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    double maxY = _data.isEmpty ? 60 : (_data.map((e) => e.totalMinutes).reduce((a, b) => a > b ? a : b).toDouble() * 1.2);
    if (maxY < 60) maxY = 60; // minimum Y axis

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => theme.colorScheme.primary.withValues(alpha: 0.8),
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.round()} min\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: _data[group.x.toInt()].date.toString().substring(0, 10),
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  final date = _data[value.toInt()].date;
                  final dayIndex = date.weekday - 1;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      days[dayIndex],
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 30,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: theme.dividerColor.withValues(alpha: 0.5),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: _data.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: item.totalMinutes.toDouble(),
                  color: theme.colorScheme.primary,
                  width: 16,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
