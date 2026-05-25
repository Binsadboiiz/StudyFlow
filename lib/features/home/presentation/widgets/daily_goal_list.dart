import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import '../viewmodels/home_viewmodel.dart';
import 'package:studyflow/features/task/presentation/widgets/task_form_modal.dart';
import 'package:studyflow/features/auth/presentation/viewmodels/auth_viewmodel.dart';

/// Widget hiển thị danh sách các mục tiêu (Tasks) dưới dạng List (từng hàng/row) bên dưới lịch.
/// Sử dụng Column thay vì ListView để có thể scroll cùng với Calendar trong CustomScrollView.
class DailyGoalList extends StatelessWidget {
  const DailyGoalList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    // Consumer lắng nghe dữ liệu từ HomeViewModel
    return Consumer<HomeViewModel>(
      builder: (context, viewModel, child) {
        // 1. Trạng thái Đang tải dữ liệu
        if (viewModel.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Trạng thái Không có dữ liệu
        if (viewModel.dailyTasks.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'No goals for this day. Take a rest!',
                style: TextStyle(color: ext.subtext),
              ),
            ),
          );
        }

        // 3. Trạng thái Có dữ liệu
        return Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 100.0),
          child: Column(
            children: List.generate(viewModel.dailyTasks.length, (index) {
              final task = viewModel.dailyTasks[index];

              return Padding(
                padding: EdgeInsets.only(bottom: index < viewModel.dailyTasks.length - 1 ? 12.0 : 0),
                child: GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => TaskFormModal(task: task),
                  ),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    color: task.isCompleted
                        ? (isDark ? AppColors.accent.withValues(alpha: 0.15) : Colors.green.shade100)
                        : ext.cardBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (!task.isCompleted) {
                                context.read<AuthViewmodel>().updateStreak(DateTime.now());
                              }
                              viewModel.toggleTaskCompletion(task);
                            },
                            child: Icon(
                              task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                              color: task.isCompleted ? AppColors.accent : ext.subtext,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: theme.colorScheme.onSurface,
                                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                if (task.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    task.description,
                                    style: TextStyle(fontSize: 13, color: ext.subtext),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
