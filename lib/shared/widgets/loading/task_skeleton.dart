import 'package:flutter/material.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/shared/widgets/loading/skeleton.dart';

/// A custom skeleton widget that simulates the UI layout of a task item card.
/// It is displayed while tasks are being fetched from repositories.
class TaskSkeleton extends StatelessWidget {
  /// Creates a [TaskSkeleton] widget.
  const TaskSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ext.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkbox placeholder
          const Skeleton(
            width: 26,
            height: 26,
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          const SizedBox(width: 14),
          // Title & Details placeholders
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title placeholder
                const Skeleton(
                  width: 140,
                  height: 16,
                ),
                const SizedBox(height: 8),
                // Time slots or details placeholder row
                Row(
                  children: [
                    const Skeleton(
                      width: 14,
                      height: 14,
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    const SizedBox(width: 6),
                    const Skeleton(
                      width: 70,
                      height: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Description placeholder
                const Skeleton(
                  width: double.infinity,
                  height: 12,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          // Time badge / status placeholder
          const Skeleton(
            width: 48,
            height: 24,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ],
      ),
    );
  }

  /// Helper method to build a static list of task skeletons.
  static Widget buildList({int count = 4}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: count,
      itemBuilder: (context, index) => const TaskSkeleton(),
    );
  }
}
