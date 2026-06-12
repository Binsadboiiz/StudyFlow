import 'package:flutter/material.dart';
import 'package:studyflow/l10n/app_localizations.dart';

/// Widget hiển thị danh hiệu nổi bật (Huy hiệu nổi bật) của người dùng bên cạnh tên.
/// Được thiết kế với viền phát sáng nhẹ, gradient vàng hoàng kim/cam mang lại cảm giác cao cấp.
class FeaturedBadgeTag extends StatelessWidget {
  /// Tên của danh hiệu/huy hiệu.
  final String badgeName;

  /// Từ khóa biểu tượng (ví dụ: 'school', 'bolt', 'timer',...).
  final String? iconKey;

  /// Kích cỡ chữ cho tag.
  final double fontSize;

  /// Kích cỡ icon cho tag.
  final double iconSize;

  /// Kích thước lớn hơn (phù hợp cho trang cá nhân Profile hoặc BottomSheet).
  final bool isLarge;

  const FeaturedBadgeTag({
    super.key,
    required this.badgeName,
    this.iconKey,
    this.fontSize = 10,
    this.iconSize = 12,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconData(iconKey);

    // Sử dụng gradient cầu vồng
    final gradientColors = isLarge
        ? [
            Colors.redAccent,
            Colors.orangeAccent,
            Colors.greenAccent,
            Colors.blueAccent,
            Colors.purpleAccent,
          ]
        : [
            Colors.redAccent.withValues(alpha: 0.2),
            Colors.orangeAccent.withValues(alpha: 0.2),
            Colors.greenAccent.withValues(alpha: 0.2),
            Colors.blueAccent.withValues(alpha: 0.2),
            Colors.purpleAccent.withValues(alpha: 0.2),
          ];

    final textColor = isLarge ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final borderColor = Colors.purpleAccent.withValues(alpha: 0.5);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12 : 8,
        vertical: isLarge ? 6 : 3,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: borderColor,
          width: isLarge ? 1.5 : 1,
        ),
        boxShadow: isLarge
            ? [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            color: textColor,
            size: isLarge ? 16 : iconSize,
          ),
          const SizedBox(width: 4),
          Text(
            _getLocalBadgeName(context, badgeName),
            style: TextStyle(
              fontSize: isLarge ? 12 : fontSize,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Ánh xạ key từ Backend thành IconData tương ứng trong Flutter.
  IconData _getIconData(String? iconKey) {
    if (iconKey == null) return Icons.workspace_premium_rounded;
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

  /// Dịch tên huy hiệu từ tiếng Anh (DB) sang ngôn ngữ hiện tại của app.
  String _getLocalBadgeName(BuildContext context, String name) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return name;
    switch (name) {
      case 'Noob No More':
        return l10n.badge_noob_no_more_name;
      case 'Touching Grass? Never':
        return l10n.badge_touching_grass_never_name;
      case 'Certified Brainrot':
        return l10n.badge_certified_brainrot_name;
      case 'Main Character Energy':
        return l10n.badge_main_character_energy_name;
      case 'Locked In':
        return l10n.badge_locked_in_name;
      case 'Distraction Who?':
        return l10n.badge_distraction_who_name;
      case 'Sigma Study Grind':
        return l10n.badge_sigma_study_grind_name;
      case 'Ultra Instinct':
        return l10n.badge_ultra_instinct_name;
      case 'The First W':
        return l10n.badge_the_first_w_name;
      case 'Task Destroyer':
        return l10n.badge_task_destroyer_name;
      case 'Productivity Monster':
        return l10n.badge_productivity_monster_name;
      case 'Day One or One Day?':
        return l10n.badge_day_one_or_one_day_name;
      case 'Built Different':
        return l10n.badge_built_different_name;
      case 'Grassless Legend':
        return l10n.badge_grassless_legend_name;
      default:
        return name;
    }
  }
}
