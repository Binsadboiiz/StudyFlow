import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/features/gamification/data/models/badge_model.dart';
import 'package:studyflow/features/gamification/presentation/viewmodels/gamification_viewmodel.dart';

import 'package:studyflow/shared/widgets/loading/badge_skeleton.dart';

/// Tab hiển thị danh sách các Huy hiệu / Thành tích của người dùng.
class BadgesTab extends StatelessWidget {
  const BadgesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final gamificationVm = context.watch<GamificationViewModel>();

    if (gamificationVm.isLoadingBadges) {
      return const BadgeSkeleton();
    }

    final badges = gamificationVm.badges;

    if (badges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No achievement data available yet. Start studying to earn badges!',
              style: TextStyle(color: ext.subtext, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return _buildBadgeItem(context, badge, theme, ext);
      },
    );
  }

  Widget _buildBadgeItem(BuildContext context, BadgeModel badge, ThemeData theme, AppThemeExtension ext) {
    final iconData = _getIconData(badge.iconUrl);
    final color = _getBadgeColor(badge.metricType);

    return GestureDetector(
      onTap: () => _showBadgeDetail(context, badge),
      child: GlassCard(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon huy hiệu (Mờ xám nếu chưa mở khóa)
            Opacity(
              opacity: badge.isUnlocked ? 1.0 : 0.35,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (badge.isUnlocked ? color : Colors.grey).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: badge.isUnlocked ? color : ext.subtext,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Tên huy hiệu
            Text(
              badge.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: badge.isUnlocked ? FontWeight.bold : FontWeight.w500,
                color: badge.isUnlocked 
                    ? theme.colorScheme.onSurface 
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 4),
            // Tag Trạng thái nhỏ
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (badge.isUnlocked ? AppColors.accent : Colors.grey.shade800).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                badge.isUnlocked ? 'Unlocked' : 'Locked',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: badge.isUnlocked ? AppColors.accent : ext.subtext,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hiển thị BottomSheet chi tiết huy hiệu
  void _showBadgeDetail(BuildContext context, BadgeModel badge) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final iconData = _getIconData(badge.iconUrl);
    final color = _getBadgeColor(badge.metricType);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (modalContext) => Consumer<GamificationViewModel>(
        builder: (context, vm, child) {
          final isFeatured = vm.summary?.featuredBadgeId == badge.id;
          final isWorking = vm.isActionInProgress;
          
          return Container(
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chỉ báo trượt
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ext.subtext.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                // Biểu tượng lớn rực rỡ
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: (badge.isUnlocked ? color : Colors.grey).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: (badge.isUnlocked ? color : Colors.grey).withValues(alpha: 0.2),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    iconData,
                    color: badge.isUnlocked ? color : Colors.grey,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  badge.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  badge.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: ext.subtext,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                // Phần thưởng & Ngày mở khóa
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reward Earned:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const Row(
                      children: [
                        Icon(Icons.flash_on_rounded, color: Colors.amber, size: 18),
                        Text(
                          ' +50 XP ',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.monetization_on_rounded, color: Colors.orangeAccent, size: 18),
                        Text(
                          ' +50 Coins',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orangeAccent),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      badge.isUnlocked
                          ? 'Unlocked (${DateFormat('dd/MM/yyyy').format(badge.earnedAt ?? DateTime.now())})'
                          : 'Locked',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: badge.isUnlocked ? AppColors.accent : Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Nút Đặt làm Danh hiệu nổi bật / Gỡ danh hiệu nổi bật (nếu đã mở khoá)
                if (badge.isUnlocked) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isWorking
                          ? null
                          : () async {
                              final success = await vm.setFeaturedBadge(isFeatured ? null : badge.id);
                              if (success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isFeatured
                                          ? 'Featured badge removed.'
                                          : '"${badge.name}" set as featured badge!',
                                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    backgroundColor: AppColors.accent,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFeatured 
                            ? Colors.redAccent.withValues(alpha: 0.15) 
                            : color.withValues(alpha: 0.85),
                        foregroundColor: isFeatured ? Colors.redAccent : Colors.white,
                        side: isFeatured ? const BorderSide(color: Colors.redAccent, width: 1.5) : null,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      icon: isWorking
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Icon(
                              isFeatured
                                  ? Icons.bookmark_remove_rounded
                                  : Icons.bookmark_added_rounded,
                              size: 20,
                            ),
                      label: Text(
                        isWorking
                            ? 'Processing...'
                            : (isFeatured ? 'Remove Featured Badge' : 'Set as Featured Badge'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Nút đóng
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(modalContext),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ext.subtext,
                      side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Đóng',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getIconData(String iconKey) {
    switch (iconKey) {
      case 'school':
        return Icons.school_rounded;
      case 'workspace_premium':
        return Icons.workspace_premium_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'military_tech':
        return Icons.military_tech_rounded;
      case 'timer':
        return Icons.timer_rounded;
      case 'hourglass_full':
        return Icons.hourglass_full_rounded;
      case 'self_improvement':
        return Icons.self_improvement_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'done_outline':
        return Icons.done_all_rounded;
      case 'playlist_add_check':
        return Icons.task_alt_rounded;
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'verified':
        return Icons.verified_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  Color _getBadgeColor(String metricType) {
    switch (metricType) {
      case 'Level':
        return Colors.purpleAccent;
      case 'FocusMinutes':
        return AppColors.accent;
      case 'TasksCompleted':
        return Colors.blueAccent;
      case 'StreakDays':
        return Colors.orangeAccent;
      default:
        return Colors.amber;
    }
  }
}
