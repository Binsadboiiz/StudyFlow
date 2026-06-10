import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/features/task/presentation/screens/task_screen.dart';
import 'package:studyflow/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:studyflow/l10n/app_localizations.dart';

/// Màn hình kết hợp quản lý Task và Schedule thông qua Tabs
class TaskScheduleHubScreen extends StatefulWidget {
  const TaskScheduleHubScreen({super.key});

  @override
  State<TaskScheduleHubScreen> createState() => _TaskScheduleHubScreenState();
}

class _TaskScheduleHubScreenState extends State<TaskScheduleHubScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: 8),
              // TabBar container
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: ext.subtext.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: TabBar(
                        dividerColor: Colors.transparent,
                        indicatorSize: TabBarIndicatorSize.tab,
                        splashBorderRadius: BorderRadius.circular(20),
                        indicator: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: ext.subtext,
                        labelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        tabs: [
                          Tab(text: AppLocalizations.of(context)!.tasks),
                          Tab(text: AppLocalizations.of(context)!.schedule),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Tab contents
              const Expanded(
                child: TabBarView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    TaskScreen(isNested: true),
                    ScheduleScreen(isNested: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
