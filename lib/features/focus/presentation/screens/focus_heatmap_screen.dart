import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/features/focus/data/models/focus_session_model.dart';
import 'package:studyflow/features/focus/data/repositories/focus_repository.dart';

class FocusHeatmapScreen extends StatefulWidget {
  const FocusHeatmapScreen({super.key});

  @override
  State<FocusHeatmapScreen> createState() => _FocusHeatmapScreenState();
}

class _FocusHeatmapScreenState extends State<FocusHeatmapScreen> {
  final FocusRepository _repository = FocusRepository();
  
  bool _isLoading = true;
  bool _is30Days = false; // false = 7 days, true = 30 days
  bool _isAreaChart = true; // false = Bar chart, true = Area chart
  
  List<DailyFocusHeatmapModel> _chartData = [];
  List<FocusSessionModel> _sessions = [];
  
  // Analytics variables
  int _totalFocusMinutes = 0;
  double _avgSessionMinutes = 0.0;
  int _completedSessionsCount = 0;
  int _activeDaysCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final today = DateTime.now();
      final daysRange = _is30Days ? 30 : 7;
      final startDate = today.subtract(Duration(days: daysRange - 1));
      
      // Start of start day and end of today
      final queryStart = DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0);
      final queryEnd = DateTime(today.year, today.month, today.day, 23, 59, 59);

      // Fetch heatmap data and all sessions in parallel
      final results = await Future.wait([
        _repository.getHeatmapData(queryStart, queryEnd),
        _repository.getFocusSessions(),
      ]);

      final heatmapRaw = results[0] as List<DailyFocusHeatmapModel>;
      final sessionsRaw = results[1] as List<FocusSessionModel>;

      // 1. Build complete list of daily heatmap data filling missing days with 0
      final Map<String, DailyFocusHeatmapModel> rawMap = {
        for (var h in heatmapRaw) 
          DateFormat('yyyy-MM-dd').format(h.date): h
      };

      final List<DailyFocusHeatmapModel> filledData = [];
      for (int i = 0; i < daysRange; i++) {
        final date = startDate.add(Duration(days: i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        
        if (rawMap.containsKey(dateKey)) {
          filledData.add(rawMap[dateKey]!);
        } else {
          filledData.add(DailyFocusHeatmapModel(date: date, totalMinutes: 0));
        }
      }

      // 2. Filter focus sessions within date range
      final rangeSessions = sessionsRaw.where((session) {
        return session.startTime.isAfter(queryStart) && session.startTime.isBefore(queryEnd);
      }).toList();

      // 3. Compute stats
      int totalMinutes = 0;
      int activeDays = 0;
      for (var day in filledData) {
        totalMinutes += day.totalMinutes;
        if (day.totalMinutes > 0) {
          activeDays++;
        }
      }

      final totalSessions = rangeSessions.length;
      final avgSession = totalSessions > 0 ? (totalMinutes / totalSessions) : 0.0;

      setState(() {
        _chartData = filledData;
        _sessions = rangeSessions;
        _totalFocusMinutes = totalMinutes;
        _avgSessionMinutes = avgSession;
        _completedSessionsCount = totalSessions;
        _activeDaysCount = activeDays;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching focus chart data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTotalTime(int minutes) {
    if (minutes < 60) return '$minutes mins';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Focus Analytics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          color: AppColors.accent,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Selector for Time Range & Chart Type
                _buildSelectors(theme, ext),
                
                const SizedBox(height: 20),
                
                // 2. Main Chart Card
                _buildChartCard(theme, ext),
                
                const SizedBox(height: 24),
                
                // 3. Stats Section Title
                Text(
                  'Overview Metrics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ).animate().fadeIn(duration: 300.ms),
                
                const SizedBox(height: 12),
                
                // 4. Stats Grid
                _buildStatsGrid(theme, ext),
                
                const SizedBox(height: 28),
                
                // 5. Focus Logs Title
                Text(
                  'Focus History Logs',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ).animate().fadeIn(duration: 300.ms),
                
                const SizedBox(height: 12),
                
                // 6. Logs List
                _buildSessionsList(theme, ext),
                
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectors(ThemeData theme, AppThemeExtension ext) {
    return Column(
      children: [
        // Time range segment buttons (Last 7 Days vs Last 30 Days)
        Row(
          children: [
            Expanded(
              child: _buildSegmentButton(
                text: 'Last 7 Days',
                isActive: !_is30Days,
                onTap: () {
                  if (_is30Days) {
                    setState(() {
                      _is30Days = false;
                    });
                    _fetchData();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSegmentButton(
                text: 'Last 30 Days',
                isActive: _is30Days,
                onTap: () {
                  if (!_is30Days) {
                    setState(() {
                      _is30Days = true;
                    });
                    _fetchData();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Chart style toggles
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Chart Style',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark 
                    ? Colors.white.withValues(alpha: 0.05) 
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  _buildChartStyleToggle(
                    icon: Icons.show_chart_rounded,
                    isActive: _isAreaChart,
                    onTap: () => setState(() => _isAreaChart = true),
                  ),
                  const SizedBox(width: 4),
                  _buildChartStyleToggle(
                    icon: Icons.bar_chart_rounded,
                    isActive: !_isAreaChart,
                    onTap: () => setState(() => _isAreaChart = false),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0.0);
  }

  Widget _buildSegmentButton({required String text, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive 
              ? AppColors.accent 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? AppColors.accent : Colors.grey.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.grey.shade500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildChartStyleToggle({required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey.shade500,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildChartCard(ThemeData theme, AppThemeExtension ext) {
    if (_isLoading) {
      return GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    if (_chartData.isEmpty) {
      return GlassCard(
        borderRadius: 24,
        padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        child: Column(
          children: [
            Icon(Icons.query_stats_rounded, size: 48, color: ext.subtext.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              'No focus logs found for this range.',
              style: TextStyle(color: ext.subtext, fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.fromLTRB(12, 24, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isAreaChart ? 'Area Focus Trend' : 'Bar Session Distribution',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Tap on data points to view details',
                  style: TextStyle(
                    fontSize: 12,
                    color: ext.subtext,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: _isAreaChart ? _buildAreaChart(theme) : _buildBarChart(theme),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 450.ms).scale(begin: const Offset(0.97, 0.97));
  }

  Widget _buildAreaChart(ThemeData theme) {
    final spots = _chartData.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.totalMinutes.toDouble());
    }).toList();

    double maxY = _chartData.map((e) => e.totalMinutes).reduce((a, b) => a > b ? a : b).toDouble();
    maxY = maxY < 30 ? 30 : maxY * 1.25;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.06),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (val, meta) => _getBottomTitleWidget(val, meta, _chartData, _is30Days, theme),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (val, meta) {
                if (val == 0) return const SizedBox();
                return Text(
                  '${val.toInt()}m',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (_chartData.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (group) => AppColors.accent.withValues(alpha: 0.9),
            tooltipBorder: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1),
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date = _chartData[spot.x.toInt()].date;
                final dateStr = DateFormat('EEE, MMM d').format(date);
                return LineTooltipItem(
                  '${spot.y.round()} mins\n',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  children: [
                    TextSpan(
                      text: dateStr,
                      style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.normal, fontSize: 10),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3.5,
            color: AppColors.accent,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.4),
                  AppColors.accent.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            dotData: FlDotData(
              show: !_is30Days, // hide dots on 30 day range to avoid clutter
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.accent,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(ThemeData theme) {
    double maxY = _chartData.map((e) => e.totalMinutes).reduce((a, b) => a > b ? a : b).toDouble();
    maxY = maxY < 30 ? 30 : maxY * 1.25;

    final barGroups = _chartData.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.totalMinutes.toDouble(),
            gradient: LinearGradient(
              colors: [
                AppColors.accent,
                AppColors.accentLight.withValues(alpha: 0.8),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            width: _is30Days ? 6.0 : 16.0,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: maxY,
              color: theme.brightness == Brightness.dark
                  ? Colors.white.withValues(alpha: 0.03)
                  : Colors.black.withValues(alpha: 0.03),
            ),
          ),
        ],
      );
    }).toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppColors.accent.withValues(alpha: 0.9),
            tooltipBorder: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 1),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = _chartData[group.x.toInt()].date;
              final dateStr = DateFormat('EEE, MMM d').format(date);
              return BarTooltipItem(
                '${rod.toY.round()} mins\n',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                children: [
                  TextSpan(
                    text: dateStr,
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.normal, fontSize: 10),
                  ),
                ],
              );
            },
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 4,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.brightness == Brightness.dark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.06),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (val, meta) => _getBottomTitleWidget(val, meta, _chartData, _is30Days, theme),
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (val, meta) {
                if (val == 0) return const SizedBox();
                return Text(
                  '${val.toInt()}m',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  Widget _getBottomTitleWidget(double value, TitleMeta meta, List<DailyFocusHeatmapModel> data, bool is30Days, ThemeData theme) {
    final index = value.toInt();
    if (index < 0 || index >= data.length) {
      return const SizedBox();
    }
    final date = data[index].date;
    String text;
    if (is30Days) {
      if (index % 6 == 0 || index == data.length - 1) {
        text = '${date.day}/${date.month}';
      } else {
        return const SizedBox();
      }
    } else {
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      text = days[date.weekday - 1];
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Text(
        text,
        style: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatsGrid(ThemeData theme, AppThemeExtension ext) {
    if (_isLoading) {
      return const SizedBox();
    }

    final activeRatio = _chartData.isEmpty ? '0%' : '${((_activeDaysCount / _chartData.length) * 100).round()}%';

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.1,
      children: [
        _buildStatCard(
          title: 'Total Focused',
          value: _formatTotalTime(_totalFocusMinutes),
          icon: Icons.timer_outlined,
          iconColor: Colors.orangeAccent,
          theme: theme,
          ext: ext,
        ),
        _buildStatCard(
          title: 'Avg / Session',
          value: '${_avgSessionMinutes.round()} mins',
          icon: Icons.hourglass_bottom_rounded,
          iconColor: Colors.blueAccent,
          theme: theme,
          ext: ext,
        ),
        _buildStatCard(
          title: 'Completed',
          value: '$_completedSessionsCount sessions',
          icon: Icons.check_circle_outline_rounded,
          iconColor: AppColors.accent,
          theme: theme,
          ext: ext,
        ),
        _buildStatCard(
          title: 'Active Days',
          value: '$_activeDaysCount days ($activeRatio)',
          icon: Icons.calendar_today_rounded,
          iconColor: Colors.purpleAccent,
          theme: theme,
          ext: ext,
        ),
      ],
    ).animate().fadeIn(duration: 500.ms, delay: 100.ms);
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required ThemeData theme,
    required AppThemeExtension ext,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: 16,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: ext.subtext,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsList(ThemeData theme, AppThemeExtension ext) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }

    if (_sessions.isEmpty) {
      return GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No focus session history available.',
            style: TextStyle(color: ext.subtext, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _sessions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final session = _sessions[index];
        final timeFormatter = DateFormat('HH:mm');
        final dateFormatter = DateFormat('MMM d, yyyy');
        
        final durationText = '${session.durationMinutes}m';
        final isPomodoro = session.mode.toLowerCase() == 'pomodoro';
        
        return GlassCard(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isPomodoro
                      ? Colors.redAccent.withValues(alpha: 0.12)
                      : AppColors.accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPomodoro ? Icons.alarm_rounded : Icons.hourglass_bottom_rounded,
                  color: isPomodoro ? Colors.redAccent : AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${session.mode} Session',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${timeFormatter.format(session.startTime)} - ${timeFormatter.format(session.endTime)}  •  ${dateFormatter.format(session.startTime)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: ext.subtext,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isPomodoro
                      ? Colors.redAccent.withValues(alpha: 0.08)
                      : AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  durationText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPomodoro ? Colors.redAccent : AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 350.ms, delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
      },
    );
  }
}
