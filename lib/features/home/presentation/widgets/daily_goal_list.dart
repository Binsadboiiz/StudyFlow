import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/services/notification/app_notification.dart';
import 'package:studyflow/core/services/notification/notification_service.dart';
import 'package:studyflow/core/services/notification/notification_type.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import '../viewmodels/home_viewmodel.dart';
import 'package:studyflow/features/task/presentation/widgets/task_form_modal.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studyflow/shared/widgets/loading/task_skeleton.dart';
import 'package:studyflow/core/widgets/glass_card.dart';

/// A widget that displays the list of daily goals (Tasks) as a List (row by row) below the calendar.
/// It uses a [Column] instead of a [ListView] so that it can be scrolled together with the Calendar in a [CustomScrollView].
class DailyGoalList extends StatelessWidget {
  const DailyGoalList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    // Consumer to listen for data from HomeViewModel
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        // 1. Loading state
        if (viewModel.isLoading) {
          return Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
            child: Column(
              children: List.generate(3, (index) => const TaskSkeleton()),
            ),
          );
        }

        // 2. Empty data state
        if (viewModel.dailyTasks.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Icon(
                        Icons.check_circle_outline_rounded,
                        size: 80,
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      )
                      .animate(
                        onPlay: (controller) =>
                            controller.repeat(reverse: true),
                      )
                      .scaleXY(
                        begin: 0.9,
                        end: 1.1,
                        duration: 1500.ms,
                        curve: Curves.easeInOut,
                      )
                      .fade(begin: 0.5, end: 1.0, duration: 1500.ms),
                  const SizedBox(height: 24),
                  Text(
                    'No goals for this day',
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Take a rest and enjoy your day!',
                    style: TextStyle(color: ext.subtext, fontSize: 14),
                  ),
                ],
              ),
            ),
          );
        }

        // 3. Data available state
        return Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: 100.0,
          ),
          child: Column(
            children: List.generate(viewModel.dailyTasks.length, (index) {
              final task = viewModel.dailyTasks[index];

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < viewModel.dailyTasks.length - 1 ? 12.0 : 0,
                ),
                child:
                    GestureDetector(
                          onTap: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => TaskFormModal(task: task),
                          ),
                          child: GlassCard(
                            padding: const EdgeInsets.all(16.0),
                            borderRadius: 16.0,
                            color: task.isCompleted ? AppColors.accent : null,
                            opacity: task.isCompleted ? 0.15 : 0.06,
                            border: task.isCompleted
                                ? Border.all(
                                    color: AppColors.accent.withValues(
                                      alpha: 0.4,
                                    ),
                                    width: 1.2,
                                  )
                                : null,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    if (!task.isCompleted) {
                                      await context
                                          .read<AuthViewmodel>()
                                          .updateStreak(DateTime.now());
                                    }
                                    await viewModel.toggleTaskCompletion(task);
                                    if (!task.isCompleted) {
                                      NotificationService.instance.show(
                                        AppNotification(
                                          message:
                                              'Task completed! +10 XP, +10 coins',
                                          type: NotificationType.success,
                                        ),
                                      );
                                    }
                                  },
                                  child:
                                      Icon(
                                            task.isCompleted
                                                ? Icons.check_circle
                                                : Icons.circle_outlined,
                                            color: task.isCompleted
                                                ? AppColors.accent
                                                : ext.subtext,
                                            size: 28,
                                          )
                                          .animate(
                                            target: task.isCompleted ? 1 : 0,
                                          )
                                          .scaleXY(end: 1.2, duration: 150.ms)
                                          .then()
                                          .scaleXY(end: 1.0, duration: 150.ms),
                                ),
                                const SizedBox(width: 16.0),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        task.title,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: task.isCompleted
                                              ? ext.subtext
                                              : theme.colorScheme.onSurface,
                                          decoration: task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      if (task.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          task.description,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: ext.subtext,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .animate()
                        .fade(delay: (50 * index).ms)
                        .slideX(begin: 0.2, end: 0, delay: (50 * index).ms),
              );
            }),
          ),
        );
      },
    );
  }
}
