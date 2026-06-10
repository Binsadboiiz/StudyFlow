import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:studyflow/core/theme/app_colors.dart';
import 'package:studyflow/core/theme/app_theme.dart';
import 'package:studyflow/core/widgets/glass_card.dart';
import 'package:studyflow/core/services/notification/local_notification_helper.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../../domain/entities/user_notification.dart';
import 'package:studyflow/l10n/app_localizations.dart';

/// Screen displaying the list of notifications logged in the database for the user.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isNotificationGranted = true;
  bool _isAlarmGranted = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationViewModel>().fetchNotifications();
      _checkPermissions();
    });
  }

  void _checkPermissions() async {
    final notificationStatus = await Permission.notification.isGranted;
    bool alarmStatus = true;
    if (Platform.isAndroid) {
      alarmStatus = await Permission.scheduleExactAlarm.isGranted;
    }
    if (mounted) {
      setState(() {
        _isNotificationGranted = notificationStatus;
        _isAlarmGranted = alarmStatus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ext = theme.extension<AppThemeExtension>()!;
    final vm = context.watch<NotificationViewModel>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.onSurface, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocalizations.of(context)!.notifications,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        actions: [
          if (vm.notifications.isNotEmpty)
            TextButton.icon(
              onPressed: () => _showClearAllConfirmDialog(context, vm),
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 18),
              label: Text(
                AppLocalizations.of(context)!.clearAll,
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_isNotificationGranted || !_isAlarmGranted)
              _buildPermissionWarningBanner(context),
            Expanded(
              child: vm.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                  : (vm.notifications.isEmpty
                      ? _buildEmptyState(ext)
                      : RefreshIndicator(
                          onRefresh: () => vm.fetchNotifications(),
                          color: AppColors.accent,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            itemCount: vm.notifications.length,
                            itemBuilder: (context, index) {
                              final notification = vm.notifications[index];
                              return _buildNotificationCard(context, notification, vm);
                            },
                          ),
                        )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionWarningBanner(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 12.0, bottom: 4.0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.withValues(alpha: 0.15),
              Colors.deepOrange.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.orangeAccent.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                await LocalNotificationHelper.requestPermissions();
                if (Platform.isAndroid) {
                  await Permission.scheduleExactAlarm.request();
                }
                _checkPermissions(); // Recheck status
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orangeAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.timezoneWarningTitle,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.timezoneWarningSubtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: ext.subtext,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.orangeAccent,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppThemeExtension ext) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 64,
            color: ext.subtext.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noNotification,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: ext.subtext),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.notificationsDescription,
            style: TextStyle(fontSize: 14, color: ext.subtext),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    UserNotification notification,
    NotificationViewModel vm,
  ) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;
    final isDark = theme.brightness == Brightness.dark;
    
    // Choose icon and color based on notification type
    IconData iconData = Icons.notifications_none_rounded;
    Color iconColor = AppColors.accent;
    if (notification.type == 'Daily') {
      iconData = Icons.today_rounded;
      iconColor = Colors.orangeAccent;
    } else if (notification.type == 'CustomTask') {
      iconData = Icons.notifications_active_rounded;
      iconColor = AppColors.accent;
    }

    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => vm.deleteNotification(notification.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: GlassCard(
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          color: isDark ? AppColors.surfaceDark : Colors.white,
          opacity: isDark ? 0.06 : 0.7,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        Text(
                          _formatTime(notification.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: ext.subtext,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearAllConfirmDialog(BuildContext context, NotificationViewModel vm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.deleteAllNotifications,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(AppLocalizations.of(context)!.deleteAllNotificationsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(
                color: Theme.of(context).extension<AppThemeExtension>()!.subtext,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              vm.clearAllNotifications();
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.clearAll,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final checkDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeStr = DateFormat('HH:mm').format(dateTime);

    if (checkDate == today) {
      return '${AppLocalizations.of(context)!.today}, $timeStr';
    } else if (checkDate == yesterday) {
      return '${AppLocalizations.of(context)!.yesterday}, $timeStr';
    } else {
      return '${DateFormat('dd MMM').format(dateTime)}, $timeStr';
    }
  }
}
