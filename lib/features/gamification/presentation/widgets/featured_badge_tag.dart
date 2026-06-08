import 'package:flutter/material.dart';

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

    // Sử dụng gradient vàng/cam neon sang trọng để làm nổi bật danh hiệu
    final gradientColors = isLarge
        ? [
            Colors.amber.shade400,
            Colors.orangeAccent.shade400,
          ]
        : [
            Colors.amber.shade300.withValues(alpha: 0.15),
            Colors.orangeAccent.shade200.withValues(alpha: 0.15),
          ];

    final textColor = isLarge ? Colors.black : Colors.amber.shade300;
    final borderColor = Colors.amber.shade400.withValues(alpha: 0.5);

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
            badgeName,
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
}
