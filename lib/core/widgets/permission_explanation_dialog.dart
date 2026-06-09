import 'package:flutter/material.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/widgets/glass_card.dart';

/// A premium bilingual dialog explaining the necessity of Notification and Alarm permissions
/// to prevent task reminders from drifting to UTC.
class PermissionExplanationDialog extends StatelessWidget {
  final VoidCallback onGrant;
  final VoidCallback onDismiss;

  const PermissionExplanationDialog({
    super.key,
    required this.onGrant,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Material(
          color: Colors.transparent,
          child: GlassCard(
            borderRadius: 28,
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Premium Icon Header with subtle ambient glow
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.accent,
                        AppColors.accentLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.alarm_on_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Timezone & Reminders\nTimezone & Reminders',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Divider
                Container(
                  height: 1,
                  width: 80,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 16),

                // Vietnamese explanation
                Text(
                  'Để tránh việc các lời nhắc (Reminder) học tập sử dụng múi giờ UTC mặc định gây lệch giờ, StudyFlow cần bạn cấp quyền gửi Thông báo và Lời nhắc chính xác.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),

                // English explanation
                Text(
                  'To prevent reminders from using the default UTC timezone and drifting from your local time, StudyFlow needs Notification and Exact Alarm permissions.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: ext.subtext,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Actions
                Row(
                  children: [
                    // Dismiss button
                    Expanded(
                      child: TextButton(
                        onPressed: onDismiss,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Later',
                          style: TextStyle(
                            color: ext.subtext,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Grant button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onGrant,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Allow',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
