import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studyflow/core/services/network_connection_service.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/l10n/app_localizations.dart';

/// Một Widget wrapper chặn người dùng truy cập các tính năng cần Internet khi offline.
/// Hiển thị một màn hình cảnh báo kính mờ (Glassmorphism) đẹp mắt yêu cầu kết nối mạng.
class OfflineFeatureBlocker extends StatelessWidget {
  /// Widget con hiển thị khi online
  final Widget child;

  /// Tên của tính năng bị khóa để hiển thị trong thông báo cảnh báo
  final String featureName;

  const OfflineFeatureBlocker({
    super.key,
    required this.child,
    required this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    // Theo dõi trạng thái mạng thông qua NetworkConnectionService
    final connectionService = context.watch<NetworkConnectionService>();
    final localizations = AppLocalizations.of(context)!;

    if (connectionService.isOnline) {
      return child;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: GlassCard(
              borderRadius: 24,
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      color: AppColors.accent,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    localizations.internetRequiredTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizations.offlineFeaturePrompt(featureName),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Kích hoạt check mạng thủ công
                      final isOnline = await connectionService.forceCheck();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isOnline
                                  ? localizations.connectionSuccess
                                  : localizations.connectionFailed,
                            ),
                            backgroundColor:
                                isOnline ? Colors.green : Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(localizations.retryConnection),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
