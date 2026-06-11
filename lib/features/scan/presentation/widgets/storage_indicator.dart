import 'package:flutter/material.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/features/scan/domain/entities/storage_usage_entity.dart';
import 'package:studyflow/l10n/app_localizations.dart';

/// Widget hiển thị thanh tiến trình dung lượng lưu trữ.
/// Màu thay đổi theo mức sử dụng: Xanh (< 70%), Vàng (70-90%), Đỏ (> 90%).
class StorageIndicator extends StatelessWidget {
  /// Entity chứa thông tin dung lượng.
  final StorageUsageEntity? storageUsage;

  const StorageIndicator({
    super.key,
    this.storageUsage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    // Nếu chưa có dữ liệu, hiển thị trạng thái mặc định
    if (storageUsage == null) {
      return GlassCard(
        borderRadius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.cloud_outlined,
              color: ext.subtext,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)!.scanLoadingStorage,
              style: TextStyle(
                fontSize: 12,
                color: ext.subtext,
              ),
            ),
          ],
        ),
      );
    }

    final usage = storageUsage!;
    final percentage = usage.usedPercentage.clamp(0.0, 100.0);
    final progressValue = percentage / 100.0;

    // Xác định màu thanh tiến trình dựa trên mức sử dụng
    final progressColor = _getProgressColor(percentage);

    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dòng 1: Icon + thông tin dung lượng + số tài liệu
          Row(
            children: [
              Icon(
                Icons.cloud_outlined,
                color: progressColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                usage.formattedUsageText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${usage.documentCount} tài liệu',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Dòng 2: Thanh tiến trình
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressValue,
              minHeight: 6,
              backgroundColor: ext.subtext.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }

  /// Xác định màu thanh tiến trình dựa trên phần trăm sử dụng.
  /// Xanh (< 70%), Vàng (70-90%), Đỏ (> 90%).
  Color _getProgressColor(double percentage) {
    if (percentage > 90) return Colors.redAccent;
    if (percentage > 70) return Colors.orangeAccent;
    return AppColors.accent;
  }
}
