import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/widgets/glass_card.dart';

/// Hộp thoại chúc mừng người dùng thăng cấp (Level Up).
class LevelUpDialog extends StatelessWidget {
  final int newLevel;

  const LevelUpDialog({super.key, required this.newLevel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        borderRadius: 30,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hiệu ứng Vòng sáng xoay & Ngôi sao vàng lớn
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .rotate(duration: 10.seconds),
                const Text(
                  '🏆',
                  style: TextStyle(fontSize: 64),
                )
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut)
                    .shake(delay: 500.ms, duration: 500.ms),
              ],
            ),
            const SizedBox(height: 24),

            // Chữ LEVEL UP!
            const Text(
              'LEVEL UP!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.amber,
                letterSpacing: 2,
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 12),

            // Thông điệp chúc mừng
            Text(
              'Congratulations on your achievement! You have reached a new level.',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Level $newLevel',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            )
                .animate(delay: 200.ms)
                .fadeIn()
                .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
            const SizedBox(height: 16),

            Text(
              'Keep up the great work! You have earned a level-up reward.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 28),

            // Nút Xác nhận
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Awesome! 🌟',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
